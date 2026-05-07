import Foundation
import Testing
@testable import Medity

/// Encodes the streak contract — the unit is the **day**, not the session.
///
/// All tests pin `now` to a fixed date so they're stable across days and
/// time zones. Sessions are constructed at concrete hours within target
/// days; the function under test only looks at `startOfDay(of: endedAt)`.
@Suite("Session.currentStreak")
struct SessionStreakTests {

    @Test("No sessions yields zero")
    func emptyHistoryYieldsZero() {
        #expect(Session.currentStreak(from: []) == 0)
    }

    @Test("A single session today yields one")
    func singleSessionToday() {
        let now = day(2026, 5, 7, hour: 9)
        let session = session(endedAt: day(2026, 5, 7, hour: 8))
        #expect(Session.currentStreak(from: [session], now: now) == 1)
    }

    @Test("Multiple sessions on the same day still count as one day")
    func multipleSessionsOneDayCountsOnce() {
        let now = day(2026, 5, 7, hour: 22)
        let morning = session(endedAt: day(2026, 5, 7, hour: 7))
        let noon    = session(endedAt: day(2026, 5, 7, hour: 12))
        let evening = session(endedAt: day(2026, 5, 7, hour: 21))
        #expect(Session.currentStreak(from: [morning, noon, evening], now: now) == 1)
    }

    @Test("Sessions today and yesterday yield two")
    func twoConsecutiveDays() {
        let now = day(2026, 5, 7, hour: 9)
        let yesterday = session(endedAt: day(2026, 5, 6, hour: 19))
        let today     = session(endedAt: day(2026, 5, 7, hour: 8))
        #expect(Session.currentStreak(from: [yesterday, today], now: now) == 2)
    }

    @Test("Last session yesterday and none today still counts (grace day)")
    func graceDayKeepsStreakAlive() {
        let now = day(2026, 5, 7, hour: 9)
        let yesterday = session(endedAt: day(2026, 5, 6, hour: 19))
        #expect(Session.currentStreak(from: [yesterday], now: now) == 1)
    }

    @Test("A two-day gap breaks the streak")
    func twoDayGapResetsToZero() {
        let now = day(2026, 5, 7, hour: 9)
        let twoDaysAgo = session(endedAt: day(2026, 5, 5, hour: 19))
        #expect(Session.currentStreak(from: [twoDaysAgo], now: now) == 0)
    }

    @Test("A long, unbroken run counts every day")
    func longUnbrokenRun() {
        let now = day(2026, 5, 7, hour: 9)
        let history = (0..<10).map { offset -> Session in
            session(endedAt: day(2026, 5, 7 - offset, hour: 8))
        }
        #expect(Session.currentStreak(from: history, now: now) == 10)
    }

    @Test("A break in the middle only counts the recent run")
    func gapInMiddleOnlyCountsRecentRun() {
        let now = day(2026, 5, 7, hour: 9)
        // Today, yesterday, then a 3-day gap, then a few earlier days.
        let recent = [
            session(endedAt: day(2026, 5, 7, hour: 8)),
            session(endedAt: day(2026, 5, 6, hour: 8)),
        ]
        let earlier = [
            session(endedAt: day(2026, 5, 2, hour: 8)),
            session(endedAt: day(2026, 5, 1, hour: 8)),
        ]
        #expect(Session.currentStreak(from: recent + earlier, now: now) == 2)
    }

    // MARK: - Helpers

    /// Builds a `Date` for the given calendar components in the current
    /// calendar / time zone — same context as the production code.
    private func day(_ year: Int, _ month: Int, _ day: Int, hour: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        return Calendar.current.date(from: components)!
    }

    /// 20-minute completed session ending at `endedAt`.
    private func session(endedAt: Date) -> Session {
        Session(
            startedAt: endedAt.addingTimeInterval(-1200),
            endedAt: endedAt,
            plannedDurationSeconds: 1200,
            actualDurationSeconds: 1200
        )
    }
}
