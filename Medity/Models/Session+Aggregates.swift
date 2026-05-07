import Foundation

extension Session {
    /// Sum of `actualDurationSeconds` across `sessions`.
    static func totalSeconds(in sessions: [Session]) -> Int {
        sessions.reduce(0) { $0 + $1.actualDurationSeconds }
    }

    /// Subset of `sessions` that ended within the current calendar week
    /// (locale-aware — Monday-start in fr-FR, Sunday-start in en-US).
    static func thisWeek(_ sessions: [Session], now: Date = Date()) -> [Session] {
        let calendar = Calendar.current
        guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start else {
            return []
        }
        return sessions.filter { $0.endedAt >= weekStart }
    }

    /// Mean `actualDurationSeconds` per session, rounded to integer seconds.
    /// Returns `0` when `sessions` is empty.
    static func averageSeconds(in sessions: [Session]) -> Int {
        guard !sessions.isEmpty else { return 0 }
        return totalSeconds(in: sessions) / sessions.count
    }

    /// Total minutes practiced per day for the trailing window of `days`
    /// days, oldest first. Days with no sessions yield `0`. The result
    /// always has length `days`.
    static func dailyMinutes(in sessions: [Session], days: Int, now: Date = Date()) -> [Int] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: now)
        guard let firstDay = calendar.date(byAdding: .day, value: -(days - 1), to: today) else {
            return Array(repeating: 0, count: days)
        }

        var totals = Array(repeating: 0, count: days)
        for session in sessions {
            let endDay = calendar.startOfDay(for: session.endedAt)
            let offset = calendar.dateComponents([.day], from: firstDay, to: endDay).day ?? -1
            if offset >= 0 && offset < days {
                totals[offset] += session.actualDurationSeconds / 60
            }
        }
        return totals
    }
}
