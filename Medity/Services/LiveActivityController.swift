@preconcurrency import ActivityKit
import Foundation

/// Owns the lifecycle of the session's Live Activity. Wraps the
/// `ActivityKit` API so view code only sees three verbs: start, update,
/// end. Silently no-ops when Live Activities are disabled in system
/// settings or the device doesn't support them.
@MainActor
final class LiveActivityController {
    private var activity: Activity<SessionActivityAttributes>?

    /// Start the activity. Idempotent — calling twice replaces the
    /// previous activity.
    func start(
        totalSeconds: Int,
        soundName: String,
        bellName: String,
        remainingSeconds: Int
    ) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        if activity != nil { Task { await end() } }

        let attributes = SessionActivityAttributes(
            totalSeconds: totalSeconds,
            soundDisplayName: soundName,
            bellDisplayName: bellName
        )
        let initialState = SessionActivityAttributes.SessionState(
            remainingSeconds: remainingSeconds,
            isPaused: false
        )
        do {
            activity = try Activity<SessionActivityAttributes>.request(
                attributes: attributes,
                content: .init(state: initialState, staleDate: nil),
                pushType: nil
            )
        } catch {
            print("LiveActivity: start failed: \(error)")
        }
    }

    /// Push a state update so the Lock Screen / Dynamic Island reflect
    /// the latest countdown / pause state.
    func update(remainingSeconds: Int, isPaused: Bool) async {
        guard let activity else { return }
        let state = SessionActivityAttributes.SessionState(
            remainingSeconds: remainingSeconds,
            isPaused: isPaused
        )
        await activity.update(.init(state: state, staleDate: nil))
    }

    /// End the activity and remove it from the Lock Screen immediately.
    func end() async {
        guard let activity else { return }
        self.activity = nil
        await activity.end(activity.content, dismissalPolicy: .immediate)
    }
}
