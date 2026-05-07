import Foundation
import Observation

/// State machine driving an in-progress meditation session.
///
/// Time tracking uses a wall-clock anchor (`startDate`) plus an accumulated
/// pause budget rather than naive decrement, so the displayed countdown stays
/// accurate even if the system briefly throttles our tick task. The 1-second
/// poll just samples that anchor.
@MainActor
@Observable
final class SessionViewModel {
    enum Phase: Equatable {
        case running
        case paused
        case completed
    }

    /// Planned duration in seconds. Set at construction, never changes.
    let totalSeconds: Int

    /// Interval bell period in seconds, or `nil` when interval bells are
    /// disabled. Set at construction.
    let intervalBellSeconds: Int?

    /// Remaining time displayed in the UI. Updated each tick.
    private(set) var remainingSeconds: Int

    /// Current state. Drives view branching.
    private(set) var phase: Phase = .running

    /// Monotonic counter incremented every time an interval bell is due.
    /// Views observe this with `.onChange` to fire `audio.playBell()`.
    private(set) var intervalBellCount: Int = 0

    // Wall-clock bookkeeping — see `tick()` for the model.
    private(set) var startDate: Date?
    private var pauseStartDate: Date?
    private var accumulatedPauseSeconds: TimeInterval = 0
    private var lastIntervalBellAtElapsed: Int = 0

    private var tickTask: Task<Void, Never>?

    init(minutes: Int, intervalBellMinutes: Int? = nil) {
        let total = max(1, minutes) * 60
        self.totalSeconds = total
        self.remainingSeconds = total
        self.intervalBellSeconds = intervalBellMinutes.flatMap { $0 > 0 ? $0 * 60 : nil }
    }

    // No deinit cancel: the tick task captures `self` weakly, so once the
    // view model deallocates the loop short-circuits on its next wake-up.
    // The cost is at most one wasted second of sleep before the Task exits.

    // MARK: - Lifecycle

    /// Starts the session. Idempotent.
    func start() {
        guard tickTask == nil else { return }
        startDate = Date()
        phase = .running
        tickTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                // Task inherits the enclosing main-actor context, so `tick`
                // can be called synchronously — no actor hop needed.
                self?.tick()
            }
        }
    }

    /// Pause if running, resume if paused. No-op when completed.
    func togglePause() {
        switch phase {
        case .running:
            pauseStartDate = Date()
            phase = .paused
        case .paused:
            if let pauseStartDate {
                accumulatedPauseSeconds += Date().timeIntervalSince(pauseStartDate)
            }
            pauseStartDate = nil
            phase = .running
        case .completed:
            break
        }
    }

    /// User asked to end the session early. Skips straight to `.completed`.
    func end() {
        // If currently paused, fold the open pause window into the budget so
        // the recorded elapsed time excludes it.
        if phase == .paused, let pauseStartDate {
            accumulatedPauseSeconds += Date().timeIntervalSince(pauseStartDate)
            self.pauseStartDate = nil
        }
        complete()
    }

    /// How long the user actually meditated, in seconds — total minus pauses
    /// minus what was left on the clock. Used by the completion summary.
    var elapsedSeconds: Int {
        totalSeconds - remainingSeconds
    }

    // MARK: - Display helpers

    /// "mm:ss" countdown, zero-padded — drives the big serif numerals.
    var formattedTime: String {
        let m = remainingSeconds / 60
        let s = remainingSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }

    /// Fraction of session elapsed (0 = just started, 1 = finished).
    var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return Double(totalSeconds - remainingSeconds) / Double(totalSeconds)
    }

    // MARK: - Private

    private func tick() {
        guard phase == .running, let startDate else { return }
        let elapsed = Date().timeIntervalSince(startDate) - accumulatedPauseSeconds
        let new = max(0, totalSeconds - Int(elapsed))
        if new != remainingSeconds {
            remainingSeconds = new
        }
        if new == 0 {
            complete()
            return
        }

        // Interval bell trigger. Fire only while the session is mid-flight
        // (skip the first second to avoid stacking with the start bell, and
        // skip the final second so we don't collide with the end bell).
        if let period = intervalBellSeconds {
            let elapsedInt = totalSeconds - new
            let dueAt = lastIntervalBellAtElapsed + period
            if elapsedInt >= dueAt && elapsedInt > 1 && new > 1 {
                lastIntervalBellAtElapsed = elapsedInt
                intervalBellCount += 1
            }
        }
    }

    private func complete() {
        tickTask?.cancel()
        tickTask = nil
        phase = .completed
    }
}
