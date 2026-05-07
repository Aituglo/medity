import Foundation
import Testing
@testable import Medity

@Suite("Session aggregates")
struct SessionAggregatesTests {

    @Test("Total seconds sums actualDurationSeconds")
    func totalSeconds() {
        let sessions = [
            session(actualSeconds: 1200),
            session(actualSeconds: 600),
            session(actualSeconds: 300),
        ]
        #expect(Session.totalSeconds(in: sessions) == 2100)
    }

    @Test("Average seconds is mean of actual durations")
    func averageSeconds() {
        let sessions = [
            session(actualSeconds: 1200),
            session(actualSeconds: 600),
        ]
        #expect(Session.averageSeconds(in: sessions) == 900)
    }

    @Test("Average of empty list is zero, not NaN")
    func averageOfEmpty() {
        #expect(Session.averageSeconds(in: []) == 0)
    }

    @Test("This-week filter keeps only sessions inside the current week")
    func thisWeekFiltering() {
        // Reference: Thursday May 7, 2026.
        let now = day(2026, 5, 7, hour: 12)
        let calendar = Calendar.current
        guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start else {
            Issue.record("could not derive week start"); return
        }
        let inside = session(endedAt: weekStart.addingTimeInterval(3600))
        let earlierToday = session(endedAt: now.addingTimeInterval(-1800))
        let lastWeek = session(endedAt: weekStart.addingTimeInterval(-3600))
        let thisWeek = Session.thisWeek([inside, earlierToday, lastWeek], now: now)
        #expect(thisWeek.count == 2)
        #expect(!thisWeek.contains(where: { $0.endedAt < weekStart }))
    }

    @Test("Daily minutes returns a window of the requested length, oldest first")
    func dailyMinutesWindowLength() {
        let now = day(2026, 5, 7, hour: 9)
        let result = Session.dailyMinutes(in: [], days: 30, now: now)
        #expect(result.count == 30)
        #expect(result.allSatisfy { $0 == 0 })
    }

    @Test("Daily minutes places sessions on their end-day")
    func dailyMinutesPlacement() {
        let now = day(2026, 5, 7, hour: 9)
        // A 20-min session today, a 15-min session yesterday, two 5-min sessions
        // yesterday too (so yesterday total = 25), nothing else.
        let today20 = session(endedAt: day(2026, 5, 7, hour: 8), actualSeconds: 1200)
        let yesterday15 = session(endedAt: day(2026, 5, 6, hour: 18), actualSeconds: 900)
        let yesterday5a = session(endedAt: day(2026, 5, 6, hour: 7),  actualSeconds: 300)
        let yesterday5b = session(endedAt: day(2026, 5, 6, hour: 22), actualSeconds: 300)

        let result = Session.dailyMinutes(
            in: [today20, yesterday15, yesterday5a, yesterday5b],
            days: 7,
            now: now
        )
        #expect(result.count == 7)
        // Window is 7 days, ending today. So index 6 = today, index 5 = yesterday.
        #expect(result[6] == 20)        // today
        #expect(result[5] == 15 + 5 + 5) // yesterday
        // Earlier days are zero.
        #expect(result[0..<5].allSatisfy { $0 == 0 })
    }

    // MARK: - Helpers

    private func day(_ year: Int, _ month: Int, _ day: Int, hour: Int) -> Date {
        var c = DateComponents()
        c.year = year; c.month = month; c.day = day; c.hour = hour
        return Calendar.current.date(from: c)!
    }

    private func session(endedAt: Date = Date(), actualSeconds: Int = 1200) -> Session {
        Session(
            startedAt: endedAt.addingTimeInterval(-Double(actualSeconds)),
            endedAt: endedAt,
            plannedDurationSeconds: actualSeconds,
            actualDurationSeconds: actualSeconds
        )
    }
}
