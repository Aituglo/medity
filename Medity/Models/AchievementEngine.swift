import Foundation

/// Pure-function evaluation of every achievement against a session history.
///
/// All conditions are recomputed on demand — `isUnlocked` is derived state,
/// not a persisted flag. That way migrating the storage or recomputing
/// after a CloudKit sync simply works.
enum AchievementEngine {

    /// Returns the status of every achievement in `Achievement.allCases`,
    /// in the same order, against the supplied history.
    static func evaluateAll(
        against sessions: [Session],
        now: Date = Date()
    ) -> [AchievementStatus] {
        Achievement.allCases.map { evaluate($0, against: sessions, now: now) }
    }

    /// Number of unlocked achievements over the catalog total.
    static func summary(
        against sessions: [Session],
        now: Date = Date()
    ) -> (unlocked: Int, total: Int) {
        let evaluations = evaluateAll(against: sessions, now: now)
        let unlocked = evaluations.filter(\.isUnlocked).count
        return (unlocked, evaluations.count)
    }

    static func evaluate(
        _ achievement: Achievement,
        against sessions: [Session],
        now: Date = Date()
    ) -> AchievementStatus {
        switch achievement {
        case .firstSession:    return firstSession(sessions, now: now)
        case .sevenDayStreak:  return streak(threshold: 7, achievement: .sevenDayStreak, sessions: sessions, now: now)
        case .thirtyDayStreak: return streak(threshold: 30, achievement: .thirtyDayStreak, sessions: sessions, now: now)
        case .tenHours:        return totalHours(threshold: 10, achievement: .tenHours, sessions: sessions, now: now)
        case .fiftyHours:      return totalHours(threshold: 50, achievement: .fiftyHours, sessions: sessions, now: now)
        case .earlyBird:       return earlyBird(sessions, now: now)
        case .nightOwl:        return nightOwl(sessions, now: now)
        case .hundredSessions: return hundredSessions(sessions, now: now)
        case .marathon:        return marathon(sessions, now: now)
        }
    }

    // MARK: - Individual evaluators

    private static func firstSession(_ sessions: [Session], now: Date) -> AchievementStatus {
        let earliest = sessions.min(by: { $0.endedAt < $1.endedAt })
        return AchievementStatus(
            achievement: .firstSession,
            isUnlocked: earliest != nil,
            unlockedAt: earliest?.endedAt,
            progressHint: earliest == nil ? "Complete one session" : nil
        )
    }

    private static func streak(
        threshold: Int,
        achievement: Achievement,
        sessions: [Session],
        now: Date
    ) -> AchievementStatus {
        let current = Session.currentStreak(from: sessions, now: now)
        let unlocked = current >= threshold
        // Unlock date is the day the streak reached `threshold`. Approximate
        // it by walking history; for V1 use "today" if currently meeting.
        let unlockedAt: Date? = unlocked ? now : nil
        let hint: String? = {
            guard !unlocked else { return nil }
            let remaining = threshold - current
            return "In \(remaining) day\(remaining == 1 ? "" : "s")"
        }()
        return AchievementStatus(
            achievement: achievement,
            isUnlocked: unlocked,
            unlockedAt: unlockedAt,
            progressHint: hint
        )
    }

    private static func totalHours(
        threshold: Int,
        achievement: Achievement,
        sessions: [Session],
        now: Date
    ) -> AchievementStatus {
        let totalSeconds = Session.totalSeconds(in: sessions)
        let hours = Double(totalSeconds) / 3600.0
        let unlocked = hours >= Double(threshold)
        let hint: String? = {
            guard !unlocked else { return nil }
            let remainingMinutes = Int(ceil(Double(threshold) * 60 - Double(totalSeconds) / 60))
            let h = remainingMinutes / 60
            let m = remainingMinutes % 60
            if h > 0 { return "\(h)h \(m)m left" }
            return "\(m)m left"
        }()
        return AchievementStatus(
            achievement: achievement,
            isUnlocked: unlocked,
            unlockedAt: unlocked ? now : nil,
            progressHint: hint
        )
    }

    private static func earlyBird(_ sessions: [Session], now: Date) -> AchievementStatus {
        let calendar = Calendar.current
        let match = sessions.first { session in
            let hour = calendar.component(.hour, from: session.startedAt)
            return hour < 7
        }
        return AchievementStatus(
            achievement: .earlyBird,
            isUnlocked: match != nil,
            unlockedAt: match?.endedAt,
            progressHint: match == nil ? "A session before 7 am" : nil
        )
    }

    private static func nightOwl(_ sessions: [Session], now: Date) -> AchievementStatus {
        let calendar = Calendar.current
        let lateSessions = sessions.filter { session in
            let hour = calendar.component(.hour, from: session.startedAt)
            return hour >= 22
        }
        let count = lateSessions.count
        let unlocked = count >= 5
        let hint: String? = unlocked ? nil : "\(count) / 5 after 10 pm"
        return AchievementStatus(
            achievement: .nightOwl,
            isUnlocked: unlocked,
            unlockedAt: unlocked ? lateSessions.sorted(by: { $0.endedAt < $1.endedAt })[4].endedAt : nil,
            progressHint: hint
        )
    }

    private static func hundredSessions(_ sessions: [Session], now: Date) -> AchievementStatus {
        let count = sessions.count
        let unlocked = count >= 100
        let hint: String? = unlocked ? nil : "\(count) / 100"
        return AchievementStatus(
            achievement: .hundredSessions,
            isUnlocked: unlocked,
            unlockedAt: unlocked ? sessions.sorted(by: { $0.endedAt < $1.endedAt })[99].endedAt : nil,
            progressHint: hint
        )
    }

    private static func marathon(_ sessions: [Session], now: Date) -> AchievementStatus {
        let match = sessions.first { $0.actualDurationSeconds >= 3600 }
        return AchievementStatus(
            achievement: .marathon,
            isUnlocked: match != nil,
            unlockedAt: match?.endedAt,
            progressHint: match == nil ? "60-min session" : nil
        )
    }
}
