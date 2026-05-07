import Foundation
import SwiftData

/// Populates the SwiftData store with realistic-looking sessions for App
/// Store screenshots. Triggered by launching the app with the launch
/// argument `-seedMockSessions YES` (which UserDefaults exposes as a Bool
/// for the key `seedMockSessions`). No-op outside that context.
@MainActor
enum MockDataSeeder {
    static func seedIfRequested(in context: ModelContext) {
        guard UserDefaults.standard.bool(forKey: "seedMockSessions") else { return }
        // Idempotent — only seed if we don't already have a respectable
        // amount of history. Otherwise repeated launches keep stacking.
        let descriptor = FetchDescriptor<Session>()
        let existing = (try? context.fetch(descriptor)) ?? []
        guard existing.count < 10 else { return }

        seedHistory(in: context)
        seedPreferences(in: context)
        try? context.save()
    }

    /// Insert a 12-day-streak history with varying daily volumes — gives
    /// the heatmap a recognisable "hotter recently, cooler before" shape.
    private static func seedHistory(in context: ModelContext) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        // A loose pattern: streak of 12 days with 1–3 sessions per day,
        // then a few sparser days further back.
        let perDay: [Int] = [
            // last 12 days — current streak
            2, 1, 2, 3, 1, 2, 1, 1, 2, 1, 1, 1,
            // gap day (day 13)
            0,
            // earlier sparse days
            1, 0, 1, 0, 1, 0, 0, 1, 0, 1, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1
        ]
        let durations = [10, 15, 20, 25, 30]
        for (offset, count) in perDay.enumerated() {
            guard count > 0,
                  let day = calendar.date(byAdding: .day, value: -offset, to: today)
            else { continue }
            for i in 0..<count {
                let hour = 7 + (i * 6)        // 7am, 1pm, 7pm…
                let duration = durations[(offset + i) % durations.count]
                let started = calendar.date(byAdding: .hour, value: hour, to: day) ?? day
                let ended = started.addingTimeInterval(TimeInterval(duration * 60))
                let session = Session(
                    startedAt: started,
                    endedAt: ended,
                    plannedDurationSeconds: duration * 60,
                    actualDurationSeconds: duration * 60,
                    soundIdentifier: "rain.light",
                    bellIdentifier: "tibetan-bowl"
                )
                context.insert(session)
            }
        }
    }

    private static func seedPreferences(in context: ModelContext) {
        let descriptor = FetchDescriptor<UserPreferences>()
        if (try? context.fetch(descriptor).first) == nil {
            let prefs = UserPreferences()
            prefs.defaultDurationMinutes = 20
            prefs.defaultSoundIdentifier = "rain.light"
            prefs.defaultBellIdentifier = "tibetan-bowl"
            context.insert(prefs)
        }
    }
}
