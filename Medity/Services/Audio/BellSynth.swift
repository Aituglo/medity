import AVFoundation
import Foundation

/// Offline bell synthesis. Real bells have an inharmonic partial structure —
/// not a clean integer harmonic series — and very long, partial-specific
/// decays. We render five sine partials with exponential envelopes plus a
/// short attack ramp into a single PCM buffer that the engine schedules
/// once at the start, and again at the end, of every session.
enum BellSynth {
    /// Renders ~4 seconds of bell into an `AVAudioPCMBuffer` matching `format`.
    static func renderBuffer(format: AVAudioFormat) -> AVAudioPCMBuffer? {
        let sampleRate = format.sampleRate
        let duration: Double = 4.0
        let frameCapacity = AVAudioFrameCount(sampleRate * duration)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCapacity),
              let channels = buffer.floatChannelData
        else { return nil }
        buffer.frameLength = frameCapacity

        // (frequency, amplitude, decayInSeconds). Inharmonic ratios picked
        // for a warm Tibetan-bowl-leaning sound rather than a brass bell.
        let partials: [(freq: Double, amp: Double, decay: Double)] = [
            (220,  0.55, 3.5),  // fundamental
            (440,  0.40, 2.8),  // octave
            (1100, 0.20, 1.8),  // 5× — gives the "metallic" cue
            (1760, 0.10, 1.3),  // 8× — light shimmer
            (2640, 0.05, 0.9),  // 12× — air on top
        ]

        let frames = Int(frameCapacity)
        let attackSeconds: Double = 0.008
        let masterGain: Double = 0.45

        for frame in 0..<frames {
            let t = Double(frame) / sampleRate
            var sample: Double = 0
            for partial in partials {
                let envelope = exp(-t / partial.decay)
                sample += sin(2 * .pi * partial.freq * t) * partial.amp * envelope
            }
            let attack = min(1.0, t / attackSeconds)
            let final = Float(sample * attack * masterGain)
            for channel in 0..<Int(format.channelCount) {
                channels[channel][frame] = final
            }
        }

        return buffer
    }
}
