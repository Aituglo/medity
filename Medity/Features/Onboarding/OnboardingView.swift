import SwiftUI
import UserNotifications

/// Three-step first-run flow: brand → features → permissions.
///
/// Pages are mounted exclusively via a `switch` on `page`, so SwiftUI gives
/// us a clean crossfade between them when `withAnimation` wraps the index
/// change. The dots and CTA are pinned at the bottom and don't transition.
struct OnboardingView: View {
    /// Called when the user finishes (either by tapping the final CTA or
    /// "Skip for now"). The host should set its onboarding flag and unmount
    /// this view.
    let onComplete: () -> Void

    @State private var page: Int = 0
    @Environment(HealthStore.self) private var healthStore

    var body: some View {
        ZStack {
            Backdrop(backdropMood)
                .animation(.easeInOut(duration: 0.4), value: page)

            VStack(spacing: 0) {
                pageContent
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .id(page)
                    .transition(.opacity)

                pageDots
                    .padding(.bottom, 18)

                cta
                    .padding(.horizontal, 28)
                    .padding(.bottom, Spacing.xxl)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: page)
    }

    // MARK: - Pages

    @ViewBuilder
    private var pageContent: some View {
        switch page {
        case 0: BrandPage()
        case 1: FeaturesPage()
        case 2: PermissionsPage()
        default: EmptyView()
        }
    }

    private var backdropMood: Backdrop.Mood {
        switch page {
        case 1: return .day
        default: return .dawn
        }
    }

    // MARK: - Bottom chrome

    private var pageDots: some View {
        HStack(spacing: 6) {
            ForEach(0..<3, id: \.self) { i in
                let active = i == page
                Capsule()
                    .fill(active ? Color.ink : Color.ink.opacity(0.20))
                    .frame(width: active ? 18 : 6, height: 6)
                    .animation(.easeInOut(duration: 0.25), value: page)
            }
        }
    }

    @ViewBuilder
    private var cta: some View {
        switch page {
        case 0:
            PrimaryButton("Begin", icon: .arrow) { advance() }
        case 1:
            PrimaryButton("Continue", icon: .arrow) { advance() }
        case 2:
            VStack(spacing: 14) {
                PrimaryButton("Allow & begin", icon: .arrow) {
                    Task {
                        await requestPermissions()
                        onComplete()
                    }
                }
                Button("Skip for now") {
                    onComplete()
                }
                .buttonStyle(.plain)
                .font(Typography.body(size: 13.5, weight: .medium))
                .foregroundStyle(.inkSecondary)
            }
        default:
            EmptyView()
        }
    }

    // MARK: - Actions

    private func advance() {
        guard page < 2 else { onComplete(); return }
        page += 1
    }

    /// Surfaces the two system permission sheets sequentially: notifications
    /// first (cheap, almost always granted), then HealthKit. `Skip for now`
    /// bypasses both — the rest of the app degrades gracefully when neither
    /// is granted.
    private func requestPermissions() async {
        let center = UNUserNotificationCenter.current()
        _ = try? await center.requestAuthorization(options: [.alert, .sound])
        await healthStore.requestAuthorization()
    }
}

// MARK: - Page 1 · Brand

private struct BrandPage: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            ZStack {
                AuraView(size: 420)
                CairnMark()
                    .fill(Color.ink)
                    .frame(width: 80, height: 84)
            }
            Text("Medity")
                .font(Typography.display(size: 64, weight: .thin))
                .tracking(-1)
                .foregroundStyle(.ink)
                .padding(.top, 28)
            Text("A quieter mind, daily.")
                .font(Typography.body(size: 19, weight: .light))
                .italic()
                .foregroundStyle(.inkSecondary)
                .padding(.top, 18)
            Spacer()
        }
    }
}

// MARK: - Page 2 · Features

private struct FeaturesPage: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer().frame(maxHeight: 80)

            Text("Three\nsimple things.")
                .font(Typography.display(size: 38, weight: .light))
                .tracking(-0.5)
                .foregroundStyle(.ink)
                .lineSpacing(2)

            VStack(alignment: .leading, spacing: 38) {
                FeatureRow(
                    title: "Timer",
                    subtitle: "Set any length. The ring is the dial.",
                    icon: { TimerGlyph() }
                )
                FeatureRow(
                    title: "Sounds",
                    subtitle: "Rain, ocean, bowls, or silence.",
                    icon: { SoundsGlyph() }
                )
                FeatureRow(
                    title: "Stats",
                    subtitle: "A small calendar of practice.",
                    icon: { StatsGlyph() }
                )
            }
            .padding(.top, 56)

            Spacer()
        }
        .padding(.horizontal, 36)
    }
}

private struct FeatureRow<Icon: View>: View {
    let title: String
    let subtitle: String
    @ViewBuilder var icon: () -> Icon

    var body: some View {
        HStack(alignment: .top, spacing: 22) {
            icon()
                .frame(width: 48, height: 48)
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(Typography.display(size: 24, weight: .regular))
                    .foregroundStyle(.ink)
                Text(subtitle)
                    .font(Typography.body(size: 15))
                    .foregroundStyle(.inkSecondary)
                    .lineSpacing(1.5)
            }
        }
    }
}

private struct TimerGlyph: View {
    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    Color.ink,
                    style: StrokeStyle(lineWidth: 1, lineCap: .round, dash: [3, 3])
                )
                .frame(width: 28, height: 28)
            Circle()
                .trim(from: 0, to: 0.18)
                .stroke(.accent, style: StrokeStyle(lineWidth: 1.6, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .frame(width: 28, height: 28)
            Circle()
                .fill(.accent)
                .frame(width: 4, height: 4)
                .offset(y: -14)
        }
    }
}

private struct SoundsGlyph: View {
    var body: some View {
        VStack(spacing: 4) {
            Wave().stroke(Color.ink, style: StrokeStyle(lineWidth: 1.2, lineCap: .round))
                .frame(width: 32, height: 12)
            Wave().stroke(Color.inkSecondary.opacity(0.6), style: StrokeStyle(lineWidth: 1, lineCap: .round))
                .frame(width: 32, height: 8)
        }
    }

    private struct Wave: Shape {
        func path(in rect: CGRect) -> Path {
            var p = Path()
            let segments = 4
            let segWidth = rect.width / CGFloat(segments)
            let amplitude = rect.height / 2
            p.move(to: CGPoint(x: 0, y: rect.midY))
            for i in 0..<segments {
                let x1 = CGFloat(i) * segWidth + segWidth / 2
                let x2 = CGFloat(i + 1) * segWidth
                let dir: CGFloat = i.isMultiple(of: 2) ? -1 : 1
                p.addQuadCurve(
                    to: CGPoint(x: x2, y: rect.midY),
                    control: CGPoint(x: x1, y: rect.midY + amplitude * dir)
                )
            }
            return p
        }
    }
}

private struct StatsGlyph: View {
    var body: some View {
        VStack(spacing: 2) {
            ForEach(0..<4, id: \.self) { row in
                HStack(spacing: 2) {
                    ForEach(0..<4, id: \.self) { col in
                        RoundedRectangle(cornerRadius: 1.5)
                            .fill(.accent.opacity(opacity(row: row, col: col)))
                            .frame(width: 6, height: 6)
                    }
                }
            }
        }
    }

    private func opacity(row: Int, col: Int) -> Double {
        // Same noisy-but-deterministic pattern as the heatmap preview tile
        // in the design.
        0.15 + Double((row + col) % 4) * 0.18
    }
}

// MARK: - Page 3 · Permissions

private struct PermissionsPage: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer().frame(maxHeight: 80)

            Text("Quietly,\nwith your permission.")
                .font(Typography.display(size: 38, weight: .thin))
                .tracking(-0.8)
                .foregroundStyle(.ink)
                .lineSpacing(2)

            Text("One nudge a day. Sessions saved to Health. Both optional, both reversible.")
                .font(Typography.body(size: 14.5))
                .foregroundStyle(.inkSecondary)
                .lineSpacing(2)
                .frame(maxWidth: 300, alignment: .leading)
                .padding(.top, 14)

            permissionsCard
                .padding(.top, 36)

            Spacer()
        }
        .padding(.horizontal, 28)
    }

    private var permissionsCard: some View {
        VStack(spacing: 0) {
            illustration
                .frame(height: 120)

            VStack(alignment: .leading, spacing: 14) {
                PermRow(
                    color: .accent,
                    title: "Mindful Minutes",
                    subtitle: "Sessions count toward your day in Apple Health."
                )
                Rectangle()
                    .fill(.hairline)
                    .frame(height: 0.5)
                PermRow(
                    color: .warmAccent,
                    title: "Gentle reminders",
                    subtitle: "One soft notification, at your chosen hour."
                )
            }
            .padding(.top, 18)
        }
        .padding(24)
        .glassSurface(radius: 28, tint: 0.30)
    }

    /// Two motifs: a heart pulse on the left (Health), shimmer rings around
    /// a dot on the right (the bell). Stays simple — the card is the focal
    /// point, the illustration is mood, not message.
    private var illustration: some View {
        ZStack {
            AuraView(size: 180)

            HStack(spacing: 30) {
                ZStack {
                    PulseLine()
                        .stroke(.accent.opacity(0.7), style: StrokeStyle(lineWidth: 1.4, lineCap: .round))
                        .frame(width: 90, height: 30)
                    Image(systemName: "heart.fill")
                        .foregroundStyle(.accent.opacity(0.85))
                        .font(.system(size: 14))
                        .offset(x: 50)
                }

                ZStack {
                    ForEach([30.0, 22.0, 14.0], id: \.self) { r in
                        let ratio = (r - 14) / (30 - 14)
                        Circle()
                            .stroke(.warmAccent.opacity(0.5 - ratio * 0.35), lineWidth: 0.7)
                            .frame(width: r * 2, height: r * 2)
                    }
                    Circle()
                        .fill(.warmAccent)
                        .frame(width: 12, height: 12)
                }
                .frame(width: 60, height: 60)
            }
        }
    }
}

private struct PulseLine: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let mid = rect.midY
        p.move(to: CGPoint(x: 0, y: mid))
        // baseline → spike up → spike down → spike up → baseline
        p.addLine(to: CGPoint(x: rect.width * 0.30, y: mid))
        p.addLine(to: CGPoint(x: rect.width * 0.40, y: mid - rect.height * 0.45))
        p.addLine(to: CGPoint(x: rect.width * 0.50, y: mid + rect.height * 0.50))
        p.addLine(to: CGPoint(x: rect.width * 0.60, y: mid - rect.height * 0.45))
        p.addLine(to: CGPoint(x: rect.width * 0.70, y: mid))
        p.addLine(to: CGPoint(x: rect.width, y: mid))
        return p
    }
}

private struct PermRow: View {
    let color: Color
    let title: String
    let subtitle: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
                .padding(.top, 6)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(Typography.body(size: 14.5, weight: .medium))
                    .foregroundStyle(.ink)
                Text(subtitle)
                    .font(Typography.body(size: 12.5))
                    .foregroundStyle(.inkSecondary)
                    .lineSpacing(1.5)
            }
        }
    }
}

#Preview("Onboarding") {
    OnboardingView { }
        .environment(HealthStore())
}
