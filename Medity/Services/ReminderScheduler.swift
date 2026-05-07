import Foundation
import UserNotifications

/// Schedules and cancels the daily meditation reminder.
///
/// One `UNCalendarNotificationTrigger` is registered per active weekday
/// (using the bitmask in `UserPreferences.reminderDaysBitmask`), all
/// repeating at the configured hour/minute. iOS allows up to 64 pending
/// notifications per app — seven is well within budget.
@MainActor
struct ReminderScheduler {
    /// Identifier prefix; the weekday number is appended to make each
    /// per-day request individually addressable.
    static let identifierPrefix = "medity.reminder"

    /// Replaces all pending reminder notifications with a fresh schedule
    /// computed from the parameters. Call this any time the user toggles
    /// or edits the reminder.
    func schedule(hour: Int, minute: Int, daysBitmask: Int) async {
        await cancel()

        let center = UNUserNotificationCenter.current()
        let content = makeContent()

        // Calendar weekday: 1 = Sunday … 7 = Saturday. Bitmask: bit 0 = Sunday.
        for weekday in 1...7 {
            let bitIndex = weekday - 1
            guard daysBitmask & (1 << bitIndex) != 0 else { continue }

            var components = DateComponents()
            components.weekday = weekday
            components.hour = hour
            components.minute = minute

            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            let request = UNNotificationRequest(
                identifier: "\(Self.identifierPrefix).\(weekday)",
                content: content,
                trigger: trigger
            )
            try? await center.add(request)
        }
    }

    /// Removes every pending Medity reminder. Safe to call when nothing is
    /// scheduled — `removePendingNotificationRequests` is a no-op then.
    func cancel() async {
        let identifiers = (1...7).map { "\(Self.identifierPrefix).\($0)" }
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    private func makeContent() -> UNNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "Medity"
        content.body = "A quiet moment, on you."
        content.sound = .default
        content.interruptionLevel = .passive
        return content
    }
}
