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
///
/// **Not `@MainActor`** — historically that caused libdispatch assertions
/// when AVFoundation invoked back into our state from its own queues. The
/// type is `@unchecked Sendable` instead; we treat all public methods as
/// effectively single-threaded (called from the SwiftUI view layer, which
/// is always on main) and protect cross-thread state through
/// `AmbientControl` (file-scope, non-isolated, atomic-on-ARM64 fields).
@Observable
final class AudioEngine: @unchecked Sendable {
    private let engine = AVAudioEngine()
    private let bellPlayer = AVAudioPlayerNode()
    private let filePlayer = AVAudioPlayerNode()
    private let ambient = AmbientControl()
    private var sourceNode: AVAudioSourceNode!
    /// Bell buffers keyed by `BellCatalog.Bell.id`. Lazy-populated on first
    /// `playBell` for each timbre and kept around — buffers are small
    /// (≤ 5 s mono, ~880 KB) and bells are tapped repeatedly.
    private var bellBuffers: [String: AVAudioPCMBuffer] = [:]
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
        // The engine has to be running before we touch the player nodes —
        // scheduling a buffer or calling `play()` on a node attached to a
        // stopped engine has tripped libdispatch queue assertions in the
        // past. Bring it up first, then mutate state.
        ensureRunning()

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

    /// Schedule one bell ring of the given timbre. Multiple rings can
    /// overlap — the player node queues them. Ducks the ambient instead of
    /// fighting it. Pass `nil` to use the catalog's default (Tibetan bowl).
    func playBell(id: String? = nil) {
        let bellId = id ?? "tibetan-bowl"
        guard let buffer = bellBuffer(for: bellId) else { return }
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
        // Pin the file player's output to our standard mono format. With
        // `format: nil`, the negotiated format defaults to the main mixer's
        // input (stereo) and `scheduleBuffer` raises an NSException when
        // we hand it a mono buffer. The format mismatch path is closed by
        // running everything through `AVAudioConverter` at load time.
        engine.connect(filePlayer, to: engine.mainMixerNode, format: format)
        engine.connect(bellPlayer, to: engine.mainMixerNode, format: format)
    }

    /// Returns (and caches) the buffer for the bell with `id`. Each timbre
    /// is rendered once; subsequent rings reuse the cached PCM.
    private func bellBuffer(for id: String) -> AVAudioPCMBuffer? {
        if let cached = bellBuffers[id] { return cached }
        guard let bell = BellCatalog.bell(for: id) else {
            return fallbackBellBuffer()
        }
        let buffer: AVAudioPCMBuffer? = {
            switch bell.kind {
            case .file(let name):
                return loadBundledFile(named: name)
            case .synth(let preset):
                return BellSynth.renderBuffer(format: format, preset: preset)
            }
        }()
        let final = buffer ?? fallbackBellBuffer()
        if let final { bellBuffers[id] = final }
        return final
    }

    /// Last-resort buffer when a bell id resolves to nothing — keeps the
    /// session audible rather than going silent.
    private func fallbackBellBuffer() -> AVAudioPCMBuffer? {
        BellSynth.renderBuffer(format: format, preset: .tibetanBowl)
    }

    /// Look up a bundled audio asset by base name. Tried extensions match
    /// `loadFileAsBuffer`'s priority order.
    private func loadBundledFile(named name: String) -> AVAudioPCMBuffer? {
        for ext in ["caf", "m4a", "mp3", "wav"] {
            if let url = Bundle.main.url(forResource: name, withExtension: ext) {
                return loadFileAsBuffer(url: url)
            }
        }
        return nil
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

    /// Reads an audio file fully into memory **in the engine's standard
    /// playback format**. Required for seamless looping via
    /// `scheduleBuffer(.loops)`, and required so the buffer matches
    /// `filePlayer`'s connection format (mismatch → NSException).
    /// Conversion is a no-op for files already encoded as mono 44.1 kHz.
    private func loadFileAsBuffer(url: URL) -> AVAudioPCMBuffer? {
        guard let file = try? AVAudioFile(forReading: url) else { return nil }
        let sourceFormat = file.processingFormat
        let totalFrames = AVAudioFrameCount(file.length)
        guard totalFrames > 0,
              let sourceBuffer = AVAudioPCMBuffer(pcmFormat: sourceFormat, frameCapacity: totalFrames)
        else { return nil }
        do {
            try file.read(into: sourceBuffer)
        } catch {
            print("AudioEngine: failed to read \(url.lastPathComponent): \(error)")
            return nil
        }

        // Fast path — bundled files are already in the right format.
        if sourceFormat.sampleRate == format.sampleRate
            && sourceFormat.channelCount == format.channelCount
            && sourceFormat.commonFormat == format.commonFormat {
            return sourceBuffer
        }
        return convert(buffer: sourceBuffer, to: format)
    }

    /// One-shot conversion of a PCM buffer to `target`. Used as a safety
    /// net for any future audio asset that doesn't ship as mono 44.1 kHz.
    private func convert(buffer source: AVAudioPCMBuffer, to target: AVAudioFormat) -> AVAudioPCMBuffer? {
        guard let converter = AVAudioConverter(from: source.format, to: target) else { return nil }
        let ratio = target.sampleRate / source.format.sampleRate
        let outFrames = AVAudioFrameCount(Double(source.frameLength) * ratio + 1024)
        guard let dest = AVAudioPCMBuffer(pcmFormat: target, frameCapacity: outFrames) else { return nil }

        var consumed = false
        var error: NSError?
        converter.convert(to: dest, error: &error) { _, status in
            if consumed {
                status.pointee = .endOfStream
                return nil
            }
            consumed = true
            status.pointee = .haveData
            return source
        }
        if let error {
            print("AudioEngine: format conversion failed: \(error)")
            return nil
        }
        return dest
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
