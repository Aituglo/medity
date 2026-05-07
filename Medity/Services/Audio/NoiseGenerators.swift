import Foundation

// MARK: - Pure noise

/// Equal-energy noise across the spectrum. Reads as "tape hiss". Useful as a
/// focus aid; can be harsh at high volume.
final class WhiteNoiseGenerator: SoundGenerator, @unchecked Sendable {
    private var rng = XorshiftRNG()
    private let amplitude: Float

    init(amplitude: Float = 0.20) {
        self.amplitude = amplitude
    }

    func nextSample() -> Float {
        rng.next() * amplitude
    }
}

/// Voss-McCartney pink noise — equal energy per octave (drops 3 dB/octave).
/// Sounds gentler than white; classic "rainfall on a tent".
final class PinkNoiseGenerator: SoundGenerator, @unchecked Sendable {
    private var rng = XorshiftRNG()
    private var rows: [Float] = Array(repeating: 0, count: 16)
    private var counter: UInt64 = 0
    private var sum: Float = 0
    private let amplitude: Float

    init(amplitude: Float = 0.30) {
        self.amplitude = amplitude
    }

    func nextSample() -> Float {
        counter &+= 1
        let trailingZeros = counter.trailingZeroBitCount
        let index = min(trailingZeros, rows.count - 1)
        let oldValue = rows[index]
        let newValue = rng.next() / Float(rows.count)
        rows[index] = newValue
        sum += newValue - oldValue
        return sum * amplitude
    }
}

/// Brownian (red) noise — drops 6 dB/octave; deep and rumbly. Reads as
/// "low waterfall" or "gentle thunder".
final class BrownNoiseGenerator: SoundGenerator, @unchecked Sendable {
    private var rng = XorshiftRNG()
    private var last: Float = 0
    private let amplitude: Float

    init(amplitude: Float = 0.55) {
        self.amplitude = amplitude
    }

    func nextSample() -> Float {
        let delta = rng.next() * 0.02
        last = max(-1, min(1, last + delta))
        return last * amplitude
    }
}

// MARK: - Nature

/// Rain on a surface, achieved with white noise pushed through a one-pole
/// low-pass for body, then mixed back with raw white for the high "hiss".
/// `heavy: false` ≈ light shower; `heavy: true` ≈ steady downpour.
final class RainGenerator: SoundGenerator, @unchecked Sendable {
    private var rng = XorshiftRNG()
    private var lpfState: Float = 0
    private let intensity: Float

    init(heavy: Bool) {
        self.intensity = heavy ? 0.55 : 0.28
    }

    func nextSample() -> Float {
        let white = rng.next()
        // One-pole LPF — the "patter" body.
        lpfState = lpfState * 0.92 + white * 0.08
        let body = lpfState * 1.6
        let hiss = white * 0.30
        return (body + hiss) * intensity
    }
}

/// Ocean — slow LFO modulating the amplitude of brown noise. `slow: true`
/// gives long, lazy shore swells; `false` gives shorter wave breaks.
final class OceanGenerator: SoundGenerator, @unchecked Sendable {
    private var rng = XorshiftRNG()
    private var brown: Float = 0
    private var lfoPhase: Float = 0
    private let lfoFreq: Float
    private static let sampleRate: Float = 44_100

    init(slow: Bool) {
        // Period in seconds → frequency in Hz.
        self.lfoFreq = 1.0 / (slow ? 11.0 : 6.5)
    }

    func nextSample() -> Float {
        // Brown body
        let delta = rng.next() * 0.013
        brown = max(-1, min(1, brown + delta))

        // Slow swell envelope.
        lfoPhase += lfoFreq / Self.sampleRate
        if lfoPhase >= 1 { lfoPhase -= 1 }
        let lfo = (sin(lfoPhase * 2 * .pi) + 1) * 0.5     // 0…1
        let envelope = 0.18 + 0.82 * lfo

        return brown * envelope * 0.7
    }
}

/// Wind — pink noise modulated by a slower LFO than the ocean's. The pink
/// gives the right "rushing through trees" timbre; the LFO breathes.
final class WindGenerator: SoundGenerator, @unchecked Sendable {
    private let pink = PinkNoiseGenerator(amplitude: 0.55)
    private var lfoPhase: Float = 0
    private static let sampleRate: Float = 44_100
    private static let lfoFreq: Float = 1.0 / 9.0 // 9-second period

    func nextSample() -> Float {
        let pinkSample = pink.nextSample()
        lfoPhase += Self.lfoFreq / Self.sampleRate
        if lfoPhase >= 1 { lfoPhase -= 1 }
        let envelope = 0.30 + 0.70 * (sin(lfoPhase * 2 * .pi) + 1) * 0.5
        return pinkSample * envelope
    }
}

/// Fire — pink noise base for the bed of "embers", with random short
/// crackles layered on top (probability ≈ 4–5 per second). Each crackle
/// decays exponentially; multiple can overlap.
final class FireGenerator: SoundGenerator, @unchecked Sendable {
    private let pink = PinkNoiseGenerator(amplitude: 0.40)
    private var rng = XorshiftRNG()
    private var crackleAmp: Float = 0

    func nextSample() -> Float {
        let bed = pink.nextSample()

        // Trigger a new crackle ~4× per second on average.
        let r = (rng.next() + 1) * 0.5 // 0…1
        if r < 0.0001 {
            crackleAmp = 0.45 + abs(rng.next()) * 0.45
        }
        let crackle = crackleAmp * rng.next()
        crackleAmp *= 0.9985 // exponential decay

        return bed + crackle * 0.55
    }
}

/// River — brown noise with a midrange emphasis (water has bright detail
/// where stones break the flow). A subtle 4-second LFO breathes the body.
final class RiverGenerator: SoundGenerator, @unchecked Sendable {
    private var rng = XorshiftRNG()
    private var brown: Float = 0
    private var prevSample: Float = 0
    private var lfoPhase: Float = 0
    private static let sampleRate: Float = 44_100
    private static let lfoFreq: Float = 1.0 / 4.0

    func nextSample() -> Float {
        let delta = rng.next() * 0.015
        brown = max(-1, min(1, brown + delta))

        // First-difference HPF — adds the "splash" detail.
        let highBoost = brown - prevSample
        prevSample = brown

        lfoPhase += Self.lfoFreq / Self.sampleRate
        if lfoPhase >= 1 { lfoPhase -= 1 }
        let envelope = 0.85 + 0.15 * sin(lfoPhase * 2 * .pi)

        return (brown * 0.5 + highBoost * 0.6) * envelope * 0.65
    }
}

/// Forest — pink noise with very slow modulation. Without bird recordings
/// this reads as "wind in leaves" rather than a true forest — passable as
/// ambient bed, will be replaced with samples later.
final class ForestGenerator: SoundGenerator, @unchecked Sendable {
    private let pink = PinkNoiseGenerator(amplitude: 0.50)
    private var lfoPhase: Float = 0
    private static let sampleRate: Float = 44_100
    private static let lfoFreq: Float = 1.0 / 15.0

    func nextSample() -> Float {
        let pinkSample = pink.nextSample()
        lfoPhase += Self.lfoFreq / Self.sampleRate
        if lfoPhase >= 1 { lfoPhase -= 1 }
        let envelope = 0.70 + 0.30 * sin(lfoPhase * 2 * .pi)
        return pinkSample * envelope
    }
}
