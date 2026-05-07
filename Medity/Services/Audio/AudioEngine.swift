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
/// The graph is built once in `init` and never mutated again. To play a
/// sound we either:
///   1. Schedule a bundled file on `filePlayer` (preferred when available)
///   2. Swap the procedural generator on `AmbientControl` (fallback)
///
/// Bundled audio files take priority — drop a `rain-light.caf` (or `.m4a`,
/// `.mp3`, `.wav`) into `Medity/Resources/Sounds/` whose name matches the
/// `fileName` declared in `SoundCatalog`, regenerate the project, and
/// future sessions will play the recording instead of the synth.
///
/// Three volume knobs:
///   - `AmbientControl.volume` — applied per-sample in the source node.
///   - `filePlayer.volume`     — separate path direct to the main mixer.
///   - `bellPlayer.volume`     — bell stays at full level during ducking.
@MainActor
@Observable
final class AudioEngine {
    private let engine = AVAudioEngine()
    private let bellPlayer = AVAudioPlayerNode()
    private let filePlayer = AVAudioPlayerNode()
    private let ambient = AmbientControl()
    private var sourceNode: AVAudioSourceNode!
    private var bellBuffer: AVAudioPCMBuffer?
    private let format: AVAudioFormat

    /// Currently-playing background sound id (or `nil`). Exposed for
    /// diagnostics; the actual playback state lives on the nodes above.
    private(set) var currentSoundId: String?

    init() {
        // Mono 44.1 kHz is enough for everything we synth — generators
        // output one channel and the bell partials don't need spread.
        self.format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)!

        configureSession()
        sourceNode = makeSourceNode()
        setupGraph()
    }

    // MARK: - Public API

    /// Start playing the sound whose id is `soundId` (see `SoundCatalog`).
    /// `nil` or `"silence"` mean "play nothing", and previously-running
    /// sounds stop. Bundled files take precedence over procedural
    /// generators when both exist.
    func playBackground(soundId: String?) {
        // Stop whichever path was active.
        ambient.generator = nil
        if filePlayer.isPlaying { filePlayer.stop() }

        guard let soundId, soundId != "silence" else {
            currentSoundId = nil
            return
        }

        // 1) Bundled audio file, looped.
        if let buffer = loadBundledLoop(for: soundId) {
            filePlayer.scheduleBuffer(buffer, at: nil, options: [.loops], completionHandler: nil)
            ensureRunning()
            if !filePlayer.isPlaying { filePlayer.play() }
            setAmbientVolume(1.0)
            currentSoundId = soundId
            return
        }

        // 2) Procedural generator.
        if let generator = makeGenerator(for: soundId) {
            ambient.generator = generator
            setAmbientVolume(1.0)
            currentSoundId = soundId
            ensureRunning()
            return
        }

        // 3) No file, no generator — silent fallback.
        currentSoundId = nil
    }

    /// Stop the background sound. The graph stays running so the bell
    /// player can fire instantly when needed.
    func stopBackground() {
        ambient.generator = nil
        if filePlayer.isPlaying { filePlayer.stop() }
        currentSoundId = nil
    }

    /// Schedule one bell ring. Multiple rings can overlap — the player
    /// node queues them. Ducks the ambient instead of fighting it.
    func playBell() {
        guard let buffer = bellBuffer else { return }
        ensureRunning()
        bellPlayer.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
        if !bellPlayer.isPlaying { bellPlayer.play() }
        Task { await duckAmbient() }
    }

    /// Fade the ambient (file OR procedural) to silence over `duration`.
    /// Used at session end so the room returns to quiet without a hard cut.
    func fadeOutBackground(over duration: TimeInterval) async {
        guard ambient.generator != nil || filePlayer.isPlaying else { return }
        let steps = max(20, Int(duration * 30))
        let interval = duration / Double(steps)
        let initial = ambient.volume
        for i in 1...steps {
            let progress = Float(i) / Float(steps)
            setAmbientVolume(initial * (1 - progress))
            try? await Task.sleep(for: .seconds(interval))
        }
        stopBackground()
        setAmbientVolume(1.0)
    }

    /// Stop everything including the engine. Call when the audio surface
    /// is leaving (session ending, sound preview sheet dismissing).
    func stopAll() {
        stopBackground()
        bellPlayer.stop()
        if engine.isRunning { engine.stop() }
    }

    // MARK: - Setup

    private func configureSession() {
        let session = AVAudioSession.sharedInstance()
        // `.playback` keeps audio playing when the screen locks.
        try? session.setCategory(.playback, mode: .default, options: [])
        try? session.setActive(true, options: [])
    }

    /// Build the permanent procedural source node. Captures `ambient` by
    /// reference so any later swap is picked up on the next render frame
    /// without touching the graph.
    private func makeSourceNode() -> AVAudioSourceNode {
        let ambient = self.ambient
        let format = self.format
        return AVAudioSourceNode(format: format) { _, _, frameCount, audioBufferList in
            let buffers = UnsafeMutableAudioBufferListPointer(audioBufferList)
            // Snapshot once per render call so mid-call swaps from main
            // can't make the loop see two different generators.
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
        engine.attach(filePlayer)
        engine.attach(bellPlayer)
        engine.connect(sourceNode, to: engine.mainMixerNode, format: format)
        // `format: nil` lets the file player negotiate its own format with
        // the main mixer — files can be any sample rate / channel count.
        engine.connect(filePlayer, to: engine.mainMixerNode, format: nil)
        engine.connect(bellPlayer, to: engine.mainMixerNode, format: format)
        bellBuffer = BellSynth.renderBuffer(format: format)
    }

    private func ensureRunning() {
        guard !engine.isRunning else { return }
        do {
            try engine.start()
        } catch {
            print("AudioEngine: engine.start() failed: \(error)")
        }
    }

    // MARK: - Volume

    /// Apply a single ambient gain to both playback paths.
    private func setAmbientVolume(_ v: Float) {
        ambient.volume = v
        filePlayer.volume = v
    }

    // MARK: - Bell ducking

    /// Quickly drops ambient to 40 %, holds while the bell sustains, then
    /// restores. Mirrors the curve in the design's "Sound & touch" sheet.
    private func duckAmbient() async {
        let target: Float = 0.4
        let initial = ambient.volume

        let dropSteps = 24
        let dropInterval: TimeInterval = 0.025
        for i in 1...dropSteps {
            let p = Float(i) / Float(dropSteps)
            setAmbientVolume(initial * (1 - p) + target * p)
            try? await Task.sleep(for: .seconds(dropInterval))
        }
        try? await Task.sleep(for: .seconds(1.0))
        let riseSteps = 36
        let riseInterval: TimeInterval = 1.2 / Double(riseSteps)
        for i in 1...riseSteps {
            let p = Float(i) / Float(riseSteps)
            setAmbientVolume(target * (1 - p) + 1.0 * p)
            try? await Task.sleep(for: .seconds(riseInterval))
        }
    }

    // MARK: - File loading

    /// Loads the bundled looping audio for `soundId`, if one exists.
    /// Tried extensions are `.caf` (preferred for size + decode speed),
    /// `.m4a`, `.mp3`, `.wav`.
    private func loadBundledLoop(for soundId: String) -> AVAudioPCMBuffer? {
        guard let name = SoundCatalog.sound(for: soundId)?.fileName else { return nil }
        let extensions = ["caf", "m4a", "mp3", "wav"]
        for ext in extensions {
            if let url = Bundle.main.url(forResource: name, withExtension: ext) {
                return loadFileAsBuffer(url: url)
            }
        }
        return nil
    }

    /// Reads an audio file fully into memory. Required for seamless
    /// looping via `scheduleBuffer(.loops)` — `scheduleFile` doesn't
    /// support loops, and short buffers ≤ a few minutes fit comfortably.
    private func loadFileAsBuffer(url: URL) -> AVAudioPCMBuffer? {
        guard let file = try? AVAudioFile(forReading: url) else { return nil }
        let frameCount = AVAudioFrameCount(file.length)
        guard frameCount > 0,
              let buffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: frameCount)
        else { return nil }
        do {
            try file.read(into: buffer)
            return buffer
        } catch {
            print("AudioEngine: failed to read \(url.lastPathComponent): \(error)")
            return nil
        }
    }

    // MARK: - Generator selection

    /// Routes a `SoundCatalog` identifier to its procedural generator.
    /// Returns `nil` for sounds whose only good rendering is from a real
    /// recording (Sacred bowls / Om / Temple) — those stay silent until
    /// you drop a matching audio file in `Resources/Sounds/`.
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
