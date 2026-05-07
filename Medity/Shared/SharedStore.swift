import Foundation

/// Thin wrapper around the shared App Group `UserDefaults`. Used by the
/// main app to publish small bits of state (current streak, last session
/// duration) and by the widget extension to read them.
///
/// Only stores **derived** numbers — the source of truth stays in the
/// app's SwiftData store. Each time a session ends, the app refreshes
/// these values; widgets reload via `WidgetCenter`.
enum SharedStore {
    static let appGroupId = "group.com.aituglo.medity"

    private static var defaults: UserDefaults? {
        UserDefaults(suiteName: appGroupId)
    }

    enum Keys {
        static let streak = "streak"
        static let totalMinutes = "totalMinutes"
        static let weekMinutes = "weekMinutes"
        static let sessionsThisWeek = "sessionsThisWeek"
        static let lastSessionDurationMinutes = "lastSessionDurationMinutes"
        static let lastSessionEndedAt = "lastSessionEndedAt"
    }

    // MARK: - Read

    static var streak: Int { defaults?.integer(forKey: Keys.streak) ?? 0 }
    static var totalMinutes: Int { defaults?.integer(forKey: Keys.totalMinutes) ?? 0 }
    static var weekMinutes: Int { defaults?.integer(forKey: Keys.weekMinutes) ?? 0 }
    static var sessionsThisWeek: Int { defaults?.integer(forKey: Keys.sessionsThisWeek) ?? 0 }
    static var lastSessionDurationMinutes: Int { defaults?.integer(forKey: Keys.lastSessionDurationMinutes) ?? 0 }
    static var lastSessionEndedAt: Date? {
        guard let ts = defaults?.object(forKey: Keys.lastSessionEndedAt) as? TimeInterval else {
            return nil
        }
        return Date(timeIntervalSince1970: ts)
    }

    // MARK: - Write

    /// Snapshot the values used by widgets. Call after any change to
    /// session history (e.g. end of a session).
    static func write(
        streak: Int,
        totalMinutes: Int,
        weekMinutes: Int,
        sessionsThisWeek: Int,
        lastSessionDurationMinutes: Int?,
        lastSessionEndedAt: Date?
    ) {
        guard let defaults else { return }
        defaults.set(streak, forKey: Keys.streak)
        defaults.set(totalMinutes, forKey: Keys.totalMinutes)
        defaults.set(weekMinutes, forKey: Keys.weekMinutes)
        defaults.set(sessionsThisWeek, forKey: Keys.sessionsThisWeek)
        if let lastSessionDurationMinutes {
            defaults.set(lastSessionDurationMinutes, forKey: Keys.lastSessionDurationMinutes)
        }
        if let lastSessionEndedAt {
            defaults.set(lastSessionEndedAt.timeIntervalSince1970, forKey: Keys.lastSessionEndedAt)
        }
    }
}
