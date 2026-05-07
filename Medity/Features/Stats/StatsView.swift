import SwiftData
import SwiftUI

/// Practice — stats home, presented from the chart icon on `HomeView`.
///
/// Top to bottom when populated:
///   1. Streak hero card
///   2. 26-week heatmap with session count
///   3. 2×2 metric tiles (total / this week / avg / sessions)
///   4. 30-day daily-minutes line graph
///
/// Empty state (no recorded sessions yet) replaces the populated stack
/// with the "first stone" cairn intro and a CTA back to home.
struct StatsView: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Session.endedAt, order: .reverse) private var sessions: [Session]
    @State private var isPresentingAchievements = false

    var body: some View {
        ZStack {
            Backdrop(.day)
            VStack(spacing: 0) {
                topBar
                if sessions.isEmpty {
                    EmptyStateView { dismiss() }
                } else {
                    populated
                }
            }
        }
        .fullScreenCover(isPresented: $isPresentingAchievements) {
            AchievementsView()
        }
    }

    // MARK: - Chrome

    private var topBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.ink)
                    .frame(width: 44, height: 44)
                    .glassSurface(radius: 22, interactive: true)
            }
            .buttonStyle(.plain)
            Spacer()
            Text("Practice")
                .font(Typography.body(size: 18))
                .foregroundStyle(.ink)
            Spacer()
            Button { isPresentingAchievements = true } label: {
                Image(systemName: "rosette")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(.ink)
                    .frame(width: 44, height: 44)
                    .glassSurface(radius: 22, interactive: true)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Spacing.xl)
        .padding(.top, Spacing.l)
    }

    // MARK: - Populated content

    private var populated: some View {
        ScrollView {
            VStack(spacing: 14) {
                StreakHero(streak: Session.currentStreak(from: sessions))
                HeatmapCard(sessions: sessions)
                metricsGrid
                LineGraphCard(values: Session.dailyMinutes(in: sessions, days: 30))
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 30)
        }
        .scrollIndicators(.hidden)
    }

    private var metricsGrid: some View {
        let total = Session.totalSeconds(in: sessions)
        let week = Session.totalSeconds(in: Session.thisWeek(sessions))
        let avg = Session.averageSeconds(in: sessions)
        let weekCount = Session.thisWeek(sessions).count

        return LazyVGrid(
            columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)],
            spacing: 10
        ) {
            MetricTile(label: "Total time", duration: total, sub: nil)
            MetricTile(label: "This week", duration: week, sub: nil)
            MetricTile(label: "Avg session", duration: avg, sub: nil)
            MetricTile(
                label: "Sessions",
                value: "\(sessions.count)",
                unit: nil,
                sub: weekCount > 0 ? "\(weekCount) this week" : nil
            )
        }
    }
}

// MARK: - Streak hero

private struct StreakHero: View {
    let streak: Int

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 0) {
                Text("CURRENT")
                    .font(Typography.eyebrow())
                    .tracking(3)
                    .foregroundStyle(.inkTertiary)
                HStack(alignment: .lastTextBaseline, spacing: 10) {
                    Text("\(streak)")
                        .font(Typography.display(size: 88, weight: .thin))
                        .tracking(-3)
                        .foregroundStyle(.ink)
                    Text(streak == 1 ? "day streak" : "day streak")
                        .font(Typography.body(size: 19, weight: .regular))
                        .italic()
                        .foregroundStyle(.inkSecondary)
                }
                .padding(.top, 6)
            }
            Spacer()
            ZStack {
                Circle()
                    .fill(.warmAccentSoft.opacity(0.40))
                    .frame(width: 64, height: 64)
                Image(systemName: "flame")
                    .font(.system(size: 26, weight: .light))
                    .foregroundStyle(.warmAccent)
            }
        }
        .padding(24)
        .glassSurface(radius: 28)
    }
}

// MARK: - Heatmap

private struct HeatmapCard: View {
    let sessions: [Session]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("SIX MONTHS")
                    .font(Typography.eyebrow())
                    .tracking(2.5)
                    .foregroundStyle(.inkTertiary)
                Spacer()
                Text("\(sessions.count) session\(sessions.count == 1 ? "" : "s")")
                    .font(Typography.body(size: 11))
                    .foregroundStyle(.inkTertiary)
            }
            Heatmap(sessions: sessions)
                .padding(.top, 12)
            legend
                .padding(.top, 8)
        }
        .padding(18)
        .glassSurface(radius: 24)
    }

    private var legend: some View {
        HStack(spacing: 6) {
            Text("Less")
                .font(Typography.body(size: 10))
                .foregroundStyle(.inkTertiary)
            ForEach(0..<5, id: \.self) { level in
                RoundedRectangle(cornerRadius: 2)
                    .fill(Heatmap.color(for: level))
                    .frame(width: 9, height: 9)
            }
            Text("More")
                .font(Typography.body(size: 10))
                .foregroundStyle(.inkTertiary)
        }
    }
}

private struct Heatmap: View {
    let sessions: [Session]

    private static let weeks = 26
    /// Gap is expressed as a fraction of cell side. With a constant ratio,
    /// the aspect ratio of the whole grid stays fixed regardless of width,
    /// so we can lock it once and let the cells scale to fit.
    private static let gapRatio: CGFloat = 0.20
    private static let aspectRatio: CGFloat =
        (CGFloat(weeks) + CGFloat(weeks - 1) * gapRatio) /
        (7 + 6 * gapRatio)

    var body: some View {
        let columns = buildColumns()
        Canvas { context, size in
            // Total width = weeks·cell + (weeks-1)·gap, gap = gapRatio·cell.
            let cell = size.width / (CGFloat(Self.weeks) + CGFloat(Self.weeks - 1) * Self.gapRatio)
            let gap = cell * Self.gapRatio
            let radius = cell * 0.22

            for week in 0..<Self.weeks {
                for day in 0..<7 {
                    let x = CGFloat(week) * (cell + gap)
                    let y = CGFloat(day) * (cell + gap)
                    let rect = CGRect(x: x, y: y, width: cell, height: cell)
                    let path = Path(roundedRect: rect, cornerRadius: radius)
                    context.fill(path, with: .color(Self.color(for: columns[week][day])))
                }
            }
        }
        .aspectRatio(Self.aspectRatio, contentMode: .fit)
    }

    /// 26 columns × 7 rows, each cell carrying its level (0–4) based on
    /// total minutes practiced that day.
    private func buildColumns() -> [[Int]] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let totalDays = Self.weeks * 7

        // Bucket session minutes by start-of-day.
        var minutesByDay: [Date: Int] = [:]
        for session in sessions {
            let day = calendar.startOfDay(for: session.endedAt)
            minutesByDay[day, default: 0] += session.actualDurationSeconds / 60
        }

        guard let firstDay = calendar.date(byAdding: .day, value: -(totalDays - 1), to: today) else {
            return Array(repeating: Array(repeating: 0, count: 7), count: Self.weeks)
        }

        var current = firstDay
        var columns: [[Int]] = []
        for _ in 0..<Self.weeks {
            var column: [Int] = []
            for _ in 0..<7 {
                let minutes = minutesByDay[current] ?? 0
                column.append(level(forMinutes: minutes))
                current = calendar.date(byAdding: .day, value: 1, to: current) ?? current
            }
            columns.append(column)
        }
        return columns
    }

    private func level(forMinutes m: Int) -> Int {
        // Tuned for typical practice volumes — even a single 5-min session
        // should register as more than the lightest tint, and 30+ minutes
        // (a substantial daily practice) lands at the top.
        switch m {
        case 0: return 0
        case 1..<6: return 1
        case 6..<16: return 2
        case 16..<31: return 3
        default: return 4
        }
    }

    static func color(for level: Int) -> Color {
        switch level {
        case 0: return Color.ink.opacity(0.05)
        case 1: return Color.accent.opacity(0.18)
        case 2: return Color.accent.opacity(0.36)
        case 3: return Color.accent.opacity(0.58)
        default: return Color.accent.opacity(0.85)
        }
    }
}

// MARK: - Metric tile

private struct MetricTile: View {
    let label: String
    let value: String
    let unit: String?
    let sub: String?

    init(label: String, value: String, unit: String?, sub: String?) {
        self.label = label
        self.value = value
        self.unit = unit
        self.sub = sub
    }

    /// Convenience initializer for duration-shaped tiles — formats the
    /// passed seconds into a human-friendly value/unit pair.
    init(label: String, duration seconds: Int, sub: String?) {
        let formatted = MetricTile.formatDuration(seconds: seconds)
        self.init(label: label, value: formatted.value, unit: formatted.unit, sub: sub)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(label.uppercased())
                .font(Typography.eyebrow())
                .tracking(2.5)
                .foregroundStyle(.inkTertiary)
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(value)
                    .font(Typography.display(size: 36, weight: .light))
                    .tracking(-1)
                    .foregroundStyle(.ink)
                if let unit {
                    Text(unit)
                        .font(Typography.body(size: 13))
                        .foregroundStyle(.inkSecondary)
                }
            }
            .padding(.top, 10)
            if let sub {
                Text(sub)
                    .font(Typography.body(size: 12))
                    .foregroundStyle(.inkTertiary)
                    .padding(.top, 6)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .glassSurface(radius: 20)
    }

    /// Picks the most legible representation given session totals: hours
    /// when ≥ 1, minutes otherwise.
    static func formatDuration(seconds: Int) -> (value: String, unit: String) {
        let hours = Double(seconds) / 3600.0
        if hours >= 100 {
            return (String(format: "%.0f", hours), "hrs")
        } else if hours >= 1 {
            return (String(format: "%.1f", hours), "hrs")
        } else {
            let minutes = max(0, seconds) / 60
            return ("\(minutes)", "min")
        }
    }
}

// MARK: - Line graph

private struct LineGraphCard: View {
    let values: [Int]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("MINUTES PER DAY")
                    .font(Typography.eyebrow())
                    .tracking(2.5)
                    .foregroundStyle(.inkTertiary)
                Spacer()
                Text("Last 30")
                    .font(Typography.body(size: 11))
                    .foregroundStyle(.inkTertiary)
            }
            LineGraph(values: values)
                .frame(height: 70)
                .padding(.top, 14)
        }
        .padding(18)
        .glassSurface(radius: 24)
    }
}

private struct LineGraph: View {
    let values: [Int]

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let maxValue = max(1.0, Double(values.max() ?? 0)) * 1.1
            let points = values.enumerated().map { i, v in
                CGPoint(
                    x: w * CGFloat(i) / CGFloat(max(1, values.count - 1)),
                    y: h - h * CGFloat(Double(v) / maxValue)
                )
            }
            ZStack {
                fillUnder(points: points, w: w, h: h)
                stroke(points: points)
                dots(points: points)
            }
        }
    }

    private func fillUnder(points: [CGPoint], w: CGFloat, h: CGFloat) -> some View {
        Path { path in
            guard let first = points.first else { return }
            path.move(to: first)
            for p in points.dropFirst() { path.addLine(to: p) }
            path.addLine(to: CGPoint(x: w, y: h))
            path.addLine(to: CGPoint(x: 0, y: h))
            path.closeSubpath()
        }
        .fill(
            LinearGradient(
                colors: [.accent.opacity(0.25), .accent.opacity(0)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    private func stroke(points: [CGPoint]) -> some View {
        Path { path in
            guard let first = points.first else { return }
            path.move(to: first)
            for p in points.dropFirst() { path.addLine(to: p) }
        }
        .stroke(.accent, style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
    }

    private func dots(points: [CGPoint]) -> some View {
        ForEach(Array(points.enumerated()), id: \.offset) { i, p in
            if i.isMultiple(of: 4) {
                Circle()
                    .fill(.accent)
                    .frame(width: 4, height: 4)
                    .position(p)
            }
        }
    }
}

// MARK: - Empty state

private struct EmptyStateView: View {
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(maxHeight: 60)

            ZStack {
                AuraView(size: 300)
                // A single low stone — the first one in the cairn.
                Ellipse()
                    .fill(Color.ink.opacity(0.18))
                    .frame(width: 56, height: 18)
                    .offset(y: 6)
                Ellipse()
                    .fill(Color.ink.opacity(0.10))
                    .frame(width: 80, height: 24)
                    .offset(y: 22)
            }

            Text("The first stone.")
                .font(Typography.display(size: 36, weight: .thin))
                .tracking(-1)
                .foregroundStyle(.ink)
                .padding(.top, 36)

            Text("A single session begins your practice. The cairn grows from here — one stone, one quiet day at a time.")
                .font(Typography.body(size: 14.5))
                .foregroundStyle(.inkSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(2)
                .frame(maxWidth: 280)
                .padding(.top, 14)

            VStack(alignment: .leading, spacing: 8) {
                hint("Sessions appear as squares on a calendar")
                hint("Streak begins on day two")
            }
            .padding(.top, 40)

            Spacer()

            PrimaryButton("First session", icon: .play, action: onDismiss)
                .padding(.horizontal, 28)
                .padding(.bottom, Spacing.xxl)
        }
    }

    private func hint(_ text: String) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(.inkTertiary)
                .frame(width: 6, height: 6)
            Text(text)
                .font(Typography.body(size: 12.5))
                .foregroundStyle(.inkTertiary)
        }
    }
}

#Preview("Stats — populated") {
    StatsView()
        .modelContainer(for: [Session.self, UserPreferences.self], inMemory: true)
}
