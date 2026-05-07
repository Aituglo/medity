import SwiftUI

/// Focused presentation of a single achievement, shown as a `.medium`
/// detent sheet from `AchievementsView`. Mirrors the prototype's "marker
/// detail" — a centered icon, the title in serif, the detail copy, and
/// (when unlocked) the date earned.
struct AchievementDetailView: View {
    let status: AchievementStatus
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Backdrop(.day)
            VStack(spacing: 0) {
                Spacer().frame(height: 20)
                AuraView(size: 220, hue: status.isUnlocked ? .accent : .inkTertiary, intensity: 0.55)
                    .frame(maxWidth: .infinity)
                    .frame(height: 0)

                ZStack {
                    Circle()
                        .fill(status.isUnlocked ? Color.accent.opacity(0.10) : Color.ink.opacity(0.04))
                        .frame(width: 96, height: 96)
                    Image(systemName: status.achievement.sfSymbol)
                        .font(.system(size: 38, weight: .light))
                        .foregroundStyle(status.isUnlocked ? .accent : .inkTertiary)
                    if !status.isUnlocked {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(.inkTertiary)
                            .frame(width: 22, height: 22)
                            .background(Circle().fill(Color.appBackground))
                            .offset(x: 36, y: 36)
                    }
                }

                Text(status.achievement.displayName)
                    .font(Typography.display(size: 28, weight: .light))
                    .tracking(-0.3)
                    .foregroundStyle(.ink)
                    .padding(.top, 18)

                Text(status.achievement.detailCopy)
                    .font(Typography.body(size: 14))
                    .foregroundStyle(.inkSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 36)
                    .padding(.top, 8)

                statusLine
                    .padding(.top, 18)

                Spacer(minLength: 0)
            }
        }
    }

    @ViewBuilder
    private var statusLine: some View {
        if status.isUnlocked {
            HStack(spacing: 6) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(.accent)
                if let date = status.unlockedAt {
                    Text("Earned " + relativeDate(date))
                        .font(Typography.body(size: 13))
                        .foregroundStyle(.inkSecondary)
                } else {
                    Text("Unlocked")
                        .font(Typography.body(size: 13))
                        .foregroundStyle(.inkSecondary)
                }
            }
        } else if let hint = status.progressHint {
            Text(hint)
                .font(Typography.body(size: 13))
                .foregroundStyle(.inkSecondary)
        }
    }

    private func relativeDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

#Preview {
    AchievementDetailView(
        status: .init(
            achievement: .sevenDayStreak,
            isUnlocked: true,
            unlockedAt: .now,
            progressHint: nil
        )
    )
}
