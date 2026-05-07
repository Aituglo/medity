import ActivityKit
import Foundation

/// Live Activity payload describing an in-progress meditation session.
///
/// Shared between the main app (which starts/updates/ends the activity)
/// and the widget extension (which renders the Lock Screen + Dynamic
/// Island UI). Compiled into both targets via xcodegen.
struct SessionActivityAttributes: ActivityAttributes {
    public typealias ContentState = SessionState

    /// Static attributes — fixed at session start.
    let totalSeconds: Int
    let soundDisplayName: String
    let bellDisplayName: String

    /// Dynamic state — updated as the session ticks.
    public struct SessionState: Codable, Hashable, Sendable {
        var remainingSeconds: Int
        var isPaused: Bool

        /// Convenience for the widget UI.
        public var formattedTime: String {
            let m = remainingSeconds / 60
            let s = remainingSeconds % 60
            return String(format: "%02d:%02d", m, s)
        }

        public var progress: Double {
            // Avoid division by zero — the widget can recover even from
            // bizarre states.
            max(0, min(1, Double(remainingSeconds) / 1.0))
        }
    }
}
