import Foundation

extension Session {
    /// Number of consecutive days, counted back from the most recent session.
    ///
    /// Tolerant in one specific way: if the user's last session was yesterday
    /// (gap of one calendar day), the streak still counts — they have until
    /// the end of today to keep it going. A gap of two days or more breaks it.
    ///
    /// Sessions in the array don't need to be sorted; the function buckets
    /// them by `startOfDay(of: endedAt)` first.
    static func currentStreak(from sessions: [Session], now: Date = Date()) -> Int {
        let calendar = Calendar.current
        let sessionDays = Set(sessions.map { calendar.startOfDay(for: $0.endedAt) })
        let sortedDays = sessionDays.sorted(by: >)

        guard let mostRecentDay = sortedDays.first else { return 0 }
        let today = calendar.startOfDay(for: now)
        let gapDays = calendar.dateComponents([.day], from: mostRecentDay, to: today).day ?? Int.max
        guard gapDays <= 1 else { return 0 }

        var streak = 0
        var expectedDay = mostRecentDay
        while sessionDays.contains(expectedDay) {
            streak += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: expectedDay) else { break }
            expectedDay = previous
        }
        return streak
    }
}
