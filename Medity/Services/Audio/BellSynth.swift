import AVFoundation
import Foundation

/// Offline bell synthesis. Real bells have an inharmonic partial structure —
/// not a clean integer harmonic series — and very long, partial-specific
/// decays. We render a handful of sine partials with exponential envelopes
/// plus a short attack ramp into a single PCM buffer, scheduled once on the
/// engine's bell player at the appropriate moment.
///
/// `Preset` selects a partial profile chosen to evoke a particular timbre.
enum BellSynth {

    enum Preset: String, Hashable {
        case tibetanBowl
        case japaneseBell
        case softChime
        case deepBell

        /// (frequency Hz, amplitude 0-1, decay seconds). Inharmonic ratios
        /// picked per timbre — Tibetan bowl leans warm, Japanese bell leans
        /// brighter, soft chime sits high and short, deep bell rumbles long.
        var partials: [(freq: Double, amp: Double, decay: Double)] {
            switch self {
            case .tibetanBowl:
                return [
                    (220,  0.55, 3.5),
                    (440,  0.40, 2.8),
                    (1100, 0.20, 1.8),
                    (1760, 0.10, 1.3),
                    (2640, 0.05, 0.9),
                ]
            case .japaneseBell:
                return [
                    (440,  0.50, 2.5),
                    (880,  0.40, 2.0),
                    (1320, 0.25, 1.5),
                    (2200, 0.10, 1.0),
                ]
            case .softChime:
                return [
                    (660,  0.45, 1.8),
                    (1320, 0.30, 1.4),
                    (1980, 0.15, 1.0),
                ]
            case .deepBell:
                return [
                    (110,  0.60, 5.0),
                    (220,  0.45, 4.0),
                    (660,  0.20, 2.5),
                    (1100, 0.10, 1.5),
                ]
            }
        }

        /// Buffer length (longest partial decay rounded up).
        var renderDuration: Double {
            let longest = partials.map(\.decay).max() ?? 4.0
            return min(6.0, ceil(longest))
        }
    }

    /// Render the requested bell preset into a PCM buffer at `format`.
    static func renderBuffer(format: AVAudioFormat, preset: Preset = .tibetanBowl) -> AVAudioPCMBuffer? {
        let sampleRate = format.sampleRate
        let duration = preset.renderDuration
        let frameCapacity = AVAudioFrameCount(sampleRate * duration)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCapacity),
              let channels = buffer.floatChannelData
        else { return nil }
        buffer.frameLength = frameCapacity

        let frames = Int(frameCapacity)
        let attackSeconds: Double = 0.008
        let masterGain: Double = 0.45
        let partials = preset.partials

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
