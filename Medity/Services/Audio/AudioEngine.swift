import AVFoundation
import Observation

/// Single audio engine for the whole app. Owns one `AVAudioEngine` graph,
/// a permanent player node for bells, and a transient source node for the
/// active background sound. Procedurally generates the supported sounds —
/// no bundled audio files required.
///
/// Two volume domains:
///   - `ambientMixer` — only the background sound feeds into it. Ducked
///     when a bell rings; faded out at the end of a session.
///   - `bellPlayer`   — connects directly to the main mixer so bells
///     remain at full volume during ducking.
@MainActor
@Observable
final class AudioEngine {
    private let engine = AVAudioEngine()
    private let ambientMixer = AVAudioMixerNode()
    private let bellPlayer = AVAudioPlayerNode()
    private var ambientNode: AVAudioSourceNode?
    private var bellBuffer: AVAudioPCMBuffer?
    private let format: AVAudioFormat

    /// Currently-playing background sound id (or `nil` if silent). Exposed
    /// for diagnostics.
    private(set) var currentSoundId: String?

    init() {
        // Mono sample stream is plenty — none of our generators are stereo
        // and bell partials read fine in mono.
        self.format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)!
        configureSession()
        setupGraph()
    }

    // MARK: - Public API

    /// Start playing the sound whose id is `soundId` (see `SoundCatalog`).
    /// Replaces any current background sound. `nil` or `"silence"` mean
    /// "don't play anything".
    func playBackground(soundId: String?) {
        stopBackground()
        guard let soundId, soundId != "silence",
              let generator = makeGenerator(for: soundId)
        else {
            currentSoundId = nil
            return
        }

        let format = self.format
        let node = AVAudioSourceNode(format: format) { _, _, frameCount, audioBufferList in
            // Render thread. Must be RT-safe: no allocations, no locks.
            let bufferList = UnsafeMutableAudioBufferListPointer(audioBufferList)
            for buffer in bufferList {
                let buf = UnsafeMutableBufferPointer<Float>(buffer)
                for frame in 0..<Int(frameCount) {
                    buf[frame] = generator.nextSample()
                }
            }
            return noErr
        }
        engine.attach(node)
        engine.connect(node, to: ambientMixer, format: format)
        ambientNode = node
        currentSoundId = soundId
        ambientMixer.outputVolume = 1.0
        ensureRunning()
    }

    /// Disconnect and tear down the current background source. Idempotent.
    func stopBackground() {
        if let ambientNode {
            engine.disconnectNodeOutput(ambientNode)
            engine.detach(ambientNode)
            self.ambientNode = nil
        }
        currentSoundId = nil
    }

    /// Schedule one ring of the bell. Multiple rings can overlap (the player
    /// node queues them). Always at full volume — ducks the ambient instead
    /// of competing with it.
    func playBell() {
        guard let buffer = bellBuffer else { return }
        ensureRunning()
        bellPlayer.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
        if !bellPlayer.isPlaying {
            bellPlayer.play()
        }
        Task { await duckAmbient() }
    }

    /// Smoothly drops the background to silence over `duration`, then stops.
    /// Used at the end of a session so the room returns to quiet without a
    /// hard cut.
    func fadeOutBackground(over duration: TimeInterval) async {
        guard ambientNode != nil else { return }
        let steps = max(20, Int(duration * 30))   // ~30 Hz updates
        let interval = duration / Double(steps)
        let initial = ambientMixer.outputVolume
        for i in 1...steps {
            let progress = Float(i) / Float(steps)
            ambientMixer.outputVolume = initial * (1 - progress)
            try? await Task.sleep(for: .seconds(interval))
        }
        stopBackground()
    }

    /// Stops everything and tears the engine down. Call when leaving any
    /// surface that owned audio (the session, the sound preview).
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
        // `.playback` keeps audio going when the screen locks — meditation
        // shouldn't stop because the user put the phone down.
        try? session.setCategory(.playback, mode: .default, options: [])
        try? session.setActive(true)
    }

    private func setupGraph() {
        engine.attach(ambientMixer)
        engine.attach(bellPlayer)
        // Ambient routes through its own mixer so we can duck it without
        // affecting the bell.
        engine.connect(ambientMixer, to: engine.mainMixerNode, format: format)
        engine.connect(bellPlayer, to: engine.mainMixerNode, format: format)
        bellBuffer = BellSynth.renderBuffer(format: format)
    }

    private func ensureRunning() {
        guard !engine.isRunning else { return }
        do {
            try engine.start()
        } catch {
            // Audio failures shouldn't kill the meditation — log and
            // continue silently.
            print("AudioEngine: engine.start() failed: \(error)")
        }
    }

    // MARK: - Bell ducking

    /// Quickly drops ambient volume to 40 %, holds while the bell sustains,
    /// then restores to full. Mirrors the curve documented in the design's
    /// "Sound & touch" sheet.
    private func duckAmbient() async {
        let target: Float = 0.4

        // Drop over ~600 ms.
        let dropSteps = 24
        let dropInterval: TimeInterval = 0.025
        let initial = ambientMixer.outputVolume
        for i in 1...dropSteps {
            let p = Float(i) / Float(dropSteps)
            ambientMixer.outputVolume = initial * (1 - p) + target * p
            try? await Task.sleep(for: .seconds(dropInterval))
        }
        // Hold ~1 s while the bell is at peak amplitude.
        try? await Task.sleep(for: .seconds(1.0))
        // Rise over ~1.2 s.
        let riseSteps = 36
        let riseInterval: TimeInterval = 1.2 / Double(riseSteps)
        for i in 1...riseSteps {
            let p = Float(i) / Float(riseSteps)
            ambientMixer.outputVolume = target * (1 - p) + 1.0 * p
            try? await Task.sleep(for: .seconds(riseInterval))
        }
    }

    // MARK: - Generator selection

    /// Routes a `SoundCatalog` identifier to its generator. Sounds that need
    /// real recordings — Tibetan Bowls, Om Chant, Temple Ambience — return
    /// `nil` and fall back to silence until assets ship.
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
