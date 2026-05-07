import SwiftUI
import WidgetKit

/// Streak widget — three sizes (small, medium, large) plus an inline
/// lock-screen accessory variant. All read from the `SharedStore`
/// (App Group UserDefaults) which the main app keeps fresh after each
/// completed session.
struct StreakWidget: Widget {
    let kind = "MedityStreakWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StreakProvider()) { entry in
            StreakWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Medity Streak")
        .description("Your current meditation streak.")
        .supportedFamilies([
            .systemSmall, .systemMedium, .systemLarge,
            .accessoryInline, .accessoryRectangular,
        ])
    }
}

// MARK: - Timeline

struct StreakEntry: TimelineEntry {
    let date: Date
    let streak: Int
    let totalMinutes: Int
    let weekMinutes: Int
    let sessionsThisWeek: Int
    let lastSessionMinutes: Int
    let lastSessionEndedAt: Date?
}

struct StreakProvider: TimelineProvider {
    func placeholder(in context: Context) -> StreakEntry {
        StreakEntry(date: .now, streak: 12, totalMinutes: 2520, weekMinutes: 144,
                    sessionsThisWeek: 6, lastSessionMinutes: 20, lastSessionEndedAt: .now)
    }

    func getSnapshot(in context: Context, completion: @escaping (StreakEntry) -> Void) {
        completion(currentEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StreakEntry>) -> Void) {
        // The widget is refreshed manually via `WidgetCenter.shared.reloadAllTimelines()`
        // each time the app finishes a session. We still pad the timeline
        // with a few hourly entries so the displayed values don't go stale
        // if the user never reopens the app.
        let now = Date()
        let entry = currentEntry(at: now)
        let next = Calendar.current.date(byAdding: .hour, value: 1, to: now) ?? now
        completion(Timeline(entries: [entry], policy: .after(next)))
    }

    private func currentEntry(at date: Date = .now) -> StreakEntry {
        StreakEntry(
            date: date,
            streak: SharedStore.streak,
            totalMinutes: SharedStore.totalMinutes,
            weekMinutes: SharedStore.weekMinutes,
            sessionsThisWeek: SharedStore.sessionsThisWeek,
            lastSessionMinutes: SharedStore.lastSessionDurationMinutes,
            lastSessionEndedAt: SharedStore.lastSessionEndedAt
        )
    }
}

// MARK: - Views

struct StreakWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: StreakEntry

    var body: some View {
        switch family {
        case .accessoryInline:      inlineAccessory
        case .accessoryRectangular: rectangularAccessory
        case .systemMedium:         mediumView
        case .systemLarge:          largeView
        default:                    smallView
        }
    }

    // MARK: small

    private var smallView: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: "flame")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundStyle(Color(hex: 0xC68B5C))
                Text("STREAK")
                    .font(.system(size: 10, weight: .medium))
                    .tracking(2)
                    .foregroundStyle(Color(hex: 0xA8B0BF))
            }
            Spacer(minLength: 0)
            Text("\(entry.streak)")
                .font(.system(size: 76, weight: .ultraLight, design: .default))
                .tracking(-2)
                .foregroundStyle(Color(hex: 0x0F1B2D))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            Text(entry.streak == 1 ? "day" : "days")
                .font(.system(size: 11))
                .foregroundStyle(Color(hex: 0x6B7891))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: medium

    private var mediumView: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                eyebrow("STREAK")
                Spacer(minLength: 0)
                Text("\(entry.streak)")
                    .font(.system(size: 64, weight: .ultraLight))
                    .tracking(-2)
                    .foregroundStyle(Color(hex: 0x0F1B2D))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                Text("\(entry.streak == 1 ? "day" : "days") · \(entry.sessionsThisWeek) this week")
                    .font(.system(size: 11))
                    .foregroundStyle(Color(hex: 0x6B7891))
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Rectangle()
                .fill(Color(hex: 0x0F1B2D, opacity: 0.06))
                .frame(width: 0.5)

            VStack(alignment: .leading, spacing: 14) {
                infoBlock(
                    title: "LAST SESSION",
                    value: entry.lastSessionMinutes > 0 ? "\(entry.lastSessionMinutes) min" : "—",
                    subtitle: entry.lastSessionEndedAt.map(relativeDay) ?? ""
                )
                infoBlock(
                    title: "THIS WEEK",
                    value: "\(entry.weekMinutes)",
                    subtitle: "min"
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: large

    private var largeView: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    eyebrow("STREAK")
                    Text("\(entry.streak) \(Text(entry.streak == 1 ? "day" : "days").font(.system(size: 14)).foregroundStyle(Color(hex: 0x6B7891)))")
                        .font(.system(size: 56, weight: .ultraLight))
                        .tracking(-1.5)
                        .foregroundStyle(Color(hex: 0x0F1B2D))
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    eyebrow("WEEK")
                    Text("\(entry.weekMinutes) min")
                        .font(.system(size: 22, weight: .regular))
                        .foregroundStyle(Color(hex: 0x0F1B2D))
                }
            }

            Spacer(minLength: 0)

            HStack {
                statTile("Today",    entry.lastSessionMinutes > 0 ? "\(entry.lastSessionMinutes) min" : "—")
                statTile("Sessions", "\(entry.sessionsThisWeek)/wk")
                statTile("Total",    hoursValue(minutes: entry.totalMinutes) + " hrs")
            }
        }
    }

    // MARK: lock screen accessory

    private var inlineAccessory: some View {
        Text("\(entry.streak) day streak")
            .widgetAccentable()
    }

    private var rectangularAccessory: some View {
        HStack(spacing: 8) {
            Image(systemName: "flame")
                .widgetAccentable()
            VStack(alignment: .leading, spacing: 2) {
                Text("\(entry.streak) day streak")
                    .font(.system(size: 16, weight: .semibold))
                Text("\(entry.sessionsThisWeek) this week")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: helpers

    private func eyebrow(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .medium))
            .tracking(2)
            .foregroundStyle(Color(hex: 0xA8B0BF))
    }

    private func infoBlock(title: String, value: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            eyebrow(title)
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(value)
                    .font(.system(size: 22, weight: .light))
                    .foregroundStyle(Color(hex: 0x0F1B2D))
                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.system(size: 11))
                        .foregroundStyle(Color(hex: 0x6B7891))
                }
            }
        }
    }

    private func statTile(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            eyebrow(title)
            Text(value)
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(Color(hex: 0x0F1B2D))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func hoursValue(minutes: Int) -> String {
        let hours = Double(minutes) / 60.0
        if hours >= 100 {
            return String(format: "%.0f", hours)
        }
        return String(format: "%.1f", hours)
    }

    private func relativeDay(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: .now)
    }
}

#Preview("Small", as: .systemSmall) {
    StreakWidget()
} timeline: {
    StreakEntry(date: .now, streak: 12, totalMinutes: 2520, weekMinutes: 144,
                sessionsThisWeek: 6, lastSessionMinutes: 20, lastSessionEndedAt: .now)
}

#Preview("Medium", as: .systemMedium) {
    StreakWidget()
} timeline: {
    StreakEntry(date: .now, streak: 12, totalMinutes: 2520, weekMinutes: 144,
                sessionsThisWeek: 6, lastSessionMinutes: 20, lastSessionEndedAt: .now)
}
