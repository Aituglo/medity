import Foundation
import SwiftData

/// Singleton-shaped preferences record. There's only ever one instance —
/// `current(in:)` fetches it or creates one on first access.
///
/// Modeled as SwiftData rather than `@AppStorage` so reminder schedule,
/// hasUnlockedPlus, and future fields can sync via CloudKit alongside
/// `Session` records on the same private database.
@Model
final class UserPreferences {
    /// Default duration the timer ring lands on when the home screen opens, in minutes.
    var defaultDurationMinutes: Int = 20

    /// Default background sound identifier (see `SoundCatalog`).
    /// `nil` or `"silence"` resolve to silence.
    var defaultSoundIdentifier: String? = "rain.light"

    /// Default bell timbre identifier.
    var defaultBellIdentifier: String = "tibetan-bowl"

    /// Default interval bells in minutes. `nil` = off.
    var defaultIntervalBellsMinutes: Int? = nil

    /// Whether daily reminder notifications are enabled.
    var reminderEnabled: Bool = false

    /// Hour of the daily reminder, 0–23.
    var reminderHour: Int = 7

    /// Minute of the daily reminder, 0–59.
    var reminderMinute: Int = 0

    /// Bitfield of weekdays on which to fire the reminder.
    /// Bit 0 = Sunday, bit 6 = Saturday. Default = all seven days.
    var reminderDaysBitmask: Int = 0b1111111

    init() {}
}

extension UserPreferences {
    /// Fetches the singleton preferences from `context`, creating and
    /// inserting one with built-in defaults if none exists yet. Idempotent.
    @MainActor
    static func current(in context: ModelContext) -> UserPreferences {
        let descriptor = FetchDescriptor<UserPreferences>()
        if let existing = try? context.fetch(descriptor).first {
            return existing
        }
        let prefs = UserPreferences()
        context.insert(prefs)
        try? context.save()
        return prefs
    }
}
