import Foundation

/// A real-time-safe sample generator. The audio engine pulls one frame at a
/// time on a dedicated render thread, so implementations must not allocate,
/// lock, or call into the system. Float output is expected in `[-1, 1]`.
protocol SoundGenerator: AnyObject, Sendable {
    /// Produce the next sample, in `[-1, 1]`. Called on the audio render thread.
    func nextSample() -> Float
}

/// Tiny, RT-safe pseudo-random generator used by every noise source.
/// Xorshift32 — fast, no syscalls, no locks. Per-instance state means each
/// generator is independent.
struct XorshiftRNG: Sendable {
    private var state: UInt32

    init(seed: UInt32? = nil) {
        // 0 is the only invalid xorshift seed; clamp it.
        let raw = seed ?? UInt32.random(in: 1...UInt32.max)
        self.state = max(1, raw)
    }

    /// Returns a `Float` in `[-1, 1]`.
    @inlinable
    mutating func next() -> Float {
        var x = state
        x ^= x << 13
        x ^= x >> 17
        x ^= x << 5
        state = x
        return Float(x) / Float(UInt32.max) * 2 - 1
    }
}
