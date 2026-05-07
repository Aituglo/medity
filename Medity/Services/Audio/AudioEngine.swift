import AVFoundation
import Observation

/// Mutable state shared between the main thread (writes) and the audio
/// render thread (reads).
///
/// Defined at file scope rather than inside `AudioEngine` so it does NOT
/// inherit `@MainActor` isolation — the render thread reads
/// `generator` / `volume` every frame and would trigger a libdispatch
/// "block expected to execute on queue" assertion if either property was
/// main-actor isolated. `@unchecked Sendable` opts out of the compile-time
/// isolation check; correctness comes from the fact that class-reference
/// and `Float` writes are atomic on ARM64, and one stale frame on a swap
/// is inaudible (~23 µs at 44.1 kHz).
private final class AmbientControl: @unchecked Sendable {
    var generator: SoundGenerator?
    var volume: Float = 1.0
}

/// Single audio engine for the whole app.
///
/// The graph is built **once** in `init` and never mutated again — playing a
/// new sound just swaps a class-typed reference (`AmbientControl.generator`)
/// that the render block reads every frame. Mutating the graph (attach /
/// connect / disconnect) while the engine is running can throw an Obj-C
/// exception that Swift can't catch and crashes the process; this design
/// avoids the situation entirely.
///
/// Two volume knobs:
///   - `AmbientControl.volume` — applied per-sample in the source node, used
///     for ducking and end-of-session fade.
///   - `bellPlayer.volume` — separate path direct to the main mixer, so the
///     bell stays at full level while the ambient is ducked under it.
@MainActor
@Observable
final class AudioEngine {
    private let engine = AVAudioEngine()
    private let bellPlayer = AVAudioPlayerNode()
    private let ambient = AmbientControl()
    private var sourceNode: AVAudioSourceNode!
    private var bellBuffer: AVAudioPCMBuffer?
    private let format: AVAudioFormat

    /// Currently-playing background sound id (or `nil`). Exposed for
    /// diagnostics — the actual playback is driven by `ambient.generator`.
    private(set) var currentSoundId: String?

    init() {
        // Mono is enough for everything we play — generators output one
        // channel and the bell partials don't need spread.
        self.format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)!

        configureSession()
        sourceNode = makeSourceNode()
        setupGraph()
    }

    // MARK: - Public API

    /// Start playing the sound whose id is `soundId` (see `SoundCatalog`).
    /// `nil` or `"silence"` mean "play nothing", and previously-running
    /// sounds stop.
    func playBackground(soundId: String?) {
        guard let soundId, soundId != "silence",
              let generator = makeGenerator(for: soundId)
        else {
            ambient.generator = nil
            currentSoundId = nil
            return
        }
        ambient.generator = generator
        ambient.volume = 1.0
        currentSoundId = soundId
        ensureRunning()
    }

    /// Stop the background sound. The graph stays running so the bell
    /// player can fire instantly when needed.
    func stopBackground() {
        ambient.generator = nil
        currentSoundId = nil
    }

    /// Schedule one bell ring. Multiple rings can overlap (the player node
    /// queues them). Always at full level — ducks the ambient instead of
    /// fighting it.
    func playBell() {
        guard let buffer = bellBuffer else { return }
        ensureRunning()
        bellPlayer.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
        if !bellPlayer.isPlaying {
            bellPlayer.play()
        }
        Task { await duckAmbient() }
    }

    /// Fade the background to silence over `duration`, then stop it. Used
    /// at session end so the room returns to quiet without a hard cut.
    func fadeOutBackground(over duration: TimeInterval) async {
        guard ambient.generator != nil else { return }
        let steps = max(20, Int(duration * 30))   // ~30 Hz updates
        let interval = duration / Double(steps)
        let initial = ambient.volume
        for i in 1...steps {
            let progress = Float(i) / Float(steps)
            ambient.volume = initial * (1 - progress)
            try? await Task.sleep(for: .seconds(interval))
        }
        stopBackground()
        ambient.volume = 1.0
    }

    /// Stop everything including the engine. Call when the audio surface
    /// is leaving (session ending, sound preview sheet dismissing).
    func stopAll() {
        stopBackground()
        bellPlayer.stop()
        if engine.isRunning {
            engine.stop()
        }
    }

    // MARK: - Setup

    private func configureSession() {
        let session = AVAudioSession.sharedInstance()
        // `.playback` keeps audio playing when the screen locks.
        try? session.setCategory(.playback, mode: .default, options: [])
        try? session.setActive(true, options: [])
    }

    /// Build the permanent source node. Captures `ambient` by reference, so
    /// any later change to `ambient.generator` / `ambient.volume` is picked
    /// up on the next render frame without touching the graph.
    private func makeSourceNode() -> AVAudioSourceNode {
        let ambient = self.ambient
        let format = self.format
        return AVAudioSourceNode(format: format) { _, _, frameCount, audioBufferList in
            let buffers = UnsafeMutableAudioBufferListPointer(audioBufferList)
            // Snapshot once per render call so a mid-call swap from the main
            // thread can't make the loop see two different generators.
            let generator = ambient.generator
            let volume = ambient.volume
            for buffer in buffers {
                guard let raw = buffer.mData else { continue }
                let ptr = raw.assumingMemoryBound(to: Float.self)
                if let generator {
                    for frame in 0..<Int(frameCount) {
                        ptr[frame] = generator.nextSample() * volume
                    }
                } else {
                    // No active sound — fill with zeros (silence).
                    for frame in 0..<Int(frameCount) {
                        ptr[frame] = 0
                    }
                }
            }
            return noErr
        }
    }

    private func setupGraph() {
        engine.attach(sourceNode)
        engine.attach(bellPlayer)
        // Both nodes go straight to the main mixer. We don't add a separate
        // ambient mixer because Obj-C exceptions from `engine.connect` while
        // running can crash the app — keeping the graph fixed at one shape
        // sidesteps the problem and the per-sample volume in the source
        // node gives us all the ducking control we need.
        engine.connect(sourceNode, to: engine.mainMixerNode, format: format)
        engine.connect(bellPlayer, to: engine.mainMixerNode, format: format)
        bellBuffer = BellSynth.renderBuffer(format: format)
    }

    private func ensureRunning() {
        guard !engine.isRunning else { return }
        do {
            try engine.start()
        } catch {
            // Audio failures shouldn't kill the meditation. Logging
            // surfaces the issue during dev without bringing the app down.
            print("AudioEngine: engine.start() failed: \(error)")
        }
    }

    // MARK: - Bell ducking

    /// Quickly drops ambient volume to 40 %, holds while the bell sustains,
    /// then restores it. Mirrors the curve in the design's "Sound & touch".
    private func duckAmbient() async {
        let target: Float = 0.4

        // Drop over ~600 ms.
        let dropSteps = 24
        let dropInterval: TimeInterval = 0.025
        let initial = ambient.volume
        for i in 1...dropSteps {
            let p = Float(i) / Float(dropSteps)
            ambient.volume = initial * (1 - p) + target * p
            try? await Task.sleep(for: .seconds(dropInterval))
        }
        // Hold ~1 s while the bell is at peak amplitude.
        try? await Task.sleep(for: .seconds(1.0))
        // Rise over ~1.2 s.
        let riseSteps = 36
        let riseInterval: TimeInterval = 1.2 / Double(riseSteps)
        for i in 1...riseSteps {
            let p = Float(i) / Float(riseSteps)
            ambient.volume = target * (1 - p) + 1.0 * p
            try? await Task.sleep(for: .seconds(riseInterval))
        }
    }

    // MARK: - Generator selection

    /// Routes a `SoundCatalog` identifier to its generator. Sounds that
    /// need real recordings (Tibetan Bowls, Om Chant, Temple Ambience)
    /// return `nil` and fall back to silence.
    private func makeGenerator(for soundId: String) -> SoundGenerator? {
        switch soundId {
        case "noise.white":  return WhiteNoiseGenerator()
        case "noise.pink":   return PinkNoiseGenerator()
        case "noise.brown":  return BrownNoiseGenerator()
        case "rain.light":   return RainGenerator(heavy: false)
        case "rain.heavy":   return RainGenerator(heavy: true)
        case "ocean.waves":  return OceanGenerator(slow: false)
        case "ocean.shore":  return OceanGenerator(slow: true)
        case "wind":         return WindGenerator()
        case "fire":         return FireGenerator()
        case "river":        return RiverGenerator()
        case "forest":       return ForestGenerator()
        default:             return nil
        }
    }
}
