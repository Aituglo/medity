import Foundation

/// Static catalog of achievements ("Markers" in the UI). Each case carries
/// a stable identifier, display copy, and icon kind. Whether an achievement
/// is unlocked is derived from session history at query time — no separate
/// persisted flag, so we never have to fix "lost" badges after migrations.
enum Achievement: String, CaseIterable, Identifiable, Hashable {
    case firstSession      = "first-session"
    case sevenDayStreak    = "seven-day-streak"
    case tenHours          = "ten-hours"
    case thirtyDayStreak   = "thirty-day-streak"
    case earlyBird         = "early-bird"
    case nightOwl          = "night-owl"
    case hundredSessions   = "hundred-sessions"
    case marathon          = "marathon"
    case fiftyHours        = "fifty-hours"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .firstSession:    return "First session"
        case .sevenDayStreak:  return "7 day streak"
        case .tenHours:        return "10 hours"
        case .thirtyDayStreak: return "30 day streak"
        case .earlyBird:       return "Early bird"
        case .nightOwl:        return "Night owl"
        case .hundredSessions: return "100 sessions"
        case .marathon:        return "Marathon"
        case .fiftyHours:      return "50 hours"
        }
    }

    /// One-line description shown on the detail sheet.
    var detailCopy: String {
        switch self {
        case .firstSession:    return "The first stone of the cairn."
        case .sevenDayStreak:  return "A full week of practice."
        case .tenHours:        return "Ten hours of stillness."
        case .thirtyDayStreak: return "A month, unbroken."
        case .earlyBird:       return "A session before 7 in the morning."
        case .nightOwl:        return "Five sessions after 10 at night."
        case .hundredSessions: return "One hundred returns to the cushion."
        case .marathon:        return "A single session of 60 minutes."
        case .fiftyHours:      return "Fifty hours of practice."
        }
    }

    /// SF Symbol used in the grid + detail. We pick recognisable defaults;
    /// custom artwork can replace them later without touching the model.
    var sfSymbol: String {
        switch self {
        case .firstSession:    return "sparkles"
        case .sevenDayStreak:  return "7.circle"
        case .tenHours:        return "clock"
        case .thirtyDayStreak: return "30.circle"
        case .earlyBird:       return "sun.max"
        case .nightOwl:        return "moon.stars"
        case .hundredSessions: return "100.circle"
        case .marathon:        return "figure.mind.and.body"
        case .fiftyHours:      return "50.circle"
        }
    }
}

/// Result of evaluating an achievement against a user's session history.
struct AchievementStatus: Hashable {
    let achievement: Achievement
    let isUnlocked: Bool
    /// Day the condition was first satisfied. `nil` until unlocked.
    let unlockedAt: Date?
    /// Human-friendly hint for locked achievements ("In 18 days",
    /// "60-min session", "7h 50m left"). `nil` once unlocked.
    let progressHint: String?
}
