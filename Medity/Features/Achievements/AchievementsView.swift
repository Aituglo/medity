import SwiftData
import SwiftUI

/// Achievements grid — the design calls them "Markers". Three columns of
/// circular badges, each tappable to open a focused detail sheet.
///
/// Status is derived from the live `Session` query via `AchievementEngine`,
/// so achievements update reactively when a new session completes while the
/// view is open.
struct AchievementsView: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Session.endedAt, order: .reverse) private var sessions: [Session]
    @State private var detailSelection: Achievement?

    private var statuses: [AchievementStatus] {
        AchievementEngine.evaluateAll(against: sessions)
    }

    private var summary: (unlocked: Int, total: Int) {
        AchievementEngine.summary(against: sessions)
    }

    var body: some View {
        ZStack {
            Backdrop(.day)
            VStack(spacing: 0) {
                topBar
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("\(summary.unlocked) of \(summary.total)")
                            .font(Typography.display(size: 30, weight: .regular))
                            .tracking(-0.3)
                            .foregroundStyle(.ink)
                            .padding(.horizontal, 20)
                            .padding(.top, 8)

                        Text("Quiet acknowledgements of practice.")
                            .font(Typography.body(size: 13.5))
                            .foregroundStyle(.inkSecondary)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 18)

                        grid
                            .padding(.horizontal, 16)
                            .padding(.bottom, 24)
                    }
                }
                .scrollIndicators(.hidden)
            }
        }
        .sheet(item: $detailSelection) { achievement in
            AchievementDetailView(
                status: AchievementEngine.evaluate(achievement, against: sessions)
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }

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
            Text("Markers")
                .font(Typography.body(size: 18))
                .foregroundStyle(.ink)
            Spacer()
            Color.clear.frame(width: 44, height: 44)
        }
        .padding(.horizontal, Spacing.xl)
        .padding(.top, Spacing.l)
    }

    private var grid: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3),
            spacing: 10
        ) {
            ForEach(statuses, id: \.achievement) { status in
                BadgeCard(status: status)
                    .onTapGesture {
                        detailSelection = status.achievement
                    }
            }
        }
    }
}

// MARK: - Badge card

private struct BadgeCard: View {
    let status: AchievementStatus

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(status.isUnlocked ? Color.accent.opacity(0.10) : Color.ink.opacity(0.04))
                    .frame(width: 56, height: 56)

                Image(systemName: status.achievement.sfSymbol)
                    .font(.system(size: 22, weight: .light))
                    .foregroundStyle(status.isUnlocked ? .accent : .inkTertiary)

                if !status.isUnlocked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 9))
                        .foregroundStyle(.inkTertiary)
                        .frame(width: 18, height: 18)
                        .background(Circle().fill(Color.appBackground))
                        .offset(x: 22, y: 22)
                }
            }

            Text(status.achievement.displayName)
                .font(Typography.body(size: 13.5))
                .foregroundStyle(.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(detailLine)
                .font(Typography.body(size: 10.5))
                .foregroundStyle(.inkTertiary)
                .lineLimit(1)
        }
        .padding(.vertical, 18)
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity)
        .glassSurface(radius: 18, tint: status.isUnlocked ? 0.10 : 0)
        .opacity(status.isUnlocked ? 1 : 0.6)
        .contentShape(Rectangle())
    }

    private var detailLine: String {
        if status.isUnlocked {
            if let date = status.unlockedAt {
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM d"
                return formatter.string(from: date)
            }
            return "Unlocked"
        }
        return status.progressHint ?? "Locked"
    }
}

#Preview {
    AchievementsView()
        .modelContainer(for: [Session.self, UserPreferences.self], inMemory: true)
}
