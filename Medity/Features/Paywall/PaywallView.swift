import SwiftUI

/// Medity Plus paywall — one-time IAP at €14.99 (no subscription).
///
/// **V1 status:** the unlock action is stubbed: tapping "Unlock" sets
/// `prefs.hasUnlockedPlus = true` after a short artificial delay. Real
/// StoreKit 2 wiring (`Product.purchase`, transaction listener,
/// `Product.subscriptions` for receipts, restore) lands in a follow-up
/// commit alongside the StoreKit configuration file.
struct PaywallView: View {
    @Bindable var prefs: UserPreferences
    @Environment(\.dismiss) private var dismiss
    @State private var isPurchasing = false

    private let benefits: [Benefit] = [
        Benefit(icon: "waveform",      title: "All sounds",     subtitle: "14 nature, sacred, and noise tracks."),
        Benefit(icon: "bell",          title: "All bells",      subtitle: "5 bell timbres, custom intervals."),
        Benefit(icon: "circle.dotted", title: "All themes",     subtitle: "Dawn, Dusk, Twilight, Monastery."),
        Benefit(icon: "clock.arrow.circlepath", title: "Future updates", subtitle: "New sounds and themes, on us."),
    ]

    var body: some View {
        ZStack {
            Backdrop(.dusk)

            VStack(spacing: 0) {
                topBar
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Spacer().frame(height: 28)

                        ZStack(alignment: .topLeading) {
                            AuraView(size: 320, intensity: 0.65)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .offset(y: -50)
                            VStack(alignment: .leading, spacing: 14) {
                                Text("Go\ndeeper.")
                                    .font(Typography.display(size: 60, weight: .light))
                                    .tracking(-1.5)
                                    .foregroundStyle(.ink)
                                    .lineSpacing(-4)

                                Text("Medity Plus opens the rest of the library. One time, no subscription.")
                                    .font(Typography.body(size: 17))
                                    .italic()
                                    .foregroundStyle(.inkSecondary)
                                    .lineSpacing(2)
                                    .frame(maxWidth: 280, alignment: .leading)
                            }
                        }

                        VStack(alignment: .leading, spacing: 22) {
                            ForEach(benefits) { BenefitRow(benefit: $0) }
                        }
                        .padding(.top, 36)
                    }
                    .padding(.horizontal, 28)
                    .padding(.bottom, 24)
                }
                .scrollIndicators(.hidden)

                bottomCTA
            }
        }
        .interactiveDismissDisabled(isPurchasing)
    }

    private var topBar: some View {
        HStack {
            Spacer()
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.ink)
                    .frame(width: 44, height: 44)
                    .glassSurface(radius: 22, interactive: true)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Spacing.xl)
        .padding(.top, Spacing.l)
    }

    private var bottomCTA: some View {
        VStack(spacing: 14) {
            Button(action: purchase) {
                ZStack {
                    if isPurchasing {
                        ProgressView()
                    } else {
                        Text("Unlock — €14.99 once")
                            .font(Typography.body(size: 18, weight: .medium))
                            .tracking(0.2)
                            .foregroundStyle(.ink)
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 64)
                .glassSurface(radius: Radius.button, tint: 0.55, interactive: true)
            }
            .buttonStyle(.plain)
            .disabled(isPurchasing)

            Button("Restore purchase") {
                // V1 stub — real StoreKit `restorePurchases` lands later.
                if prefs.hasUnlockedPlus { dismiss() }
            }
            .buttonStyle(.plain)
            .font(Typography.body(size: 13))
            .foregroundStyle(.inkTertiary)
        }
        .padding(.horizontal, 28)
        .padding(.bottom, Spacing.xxl)
    }

    /// Stub purchase flow — flips the local flag and dismisses. Replace
    /// with `Product.purchase(...)` + verification when StoreKit ships.
    private func purchase() {
        isPurchasing = true
        Task {
            try? await Task.sleep(for: .milliseconds(800))
            prefs.hasUnlockedPlus = true
            isPurchasing = false
            dismiss()
        }
    }
}

// MARK: - Benefit row

private struct Benefit: Identifiable, Hashable {
    let icon: String
    let title: String
    let subtitle: String
    var id: String { title }
}

private struct BenefitRow: View {
    let benefit: Benefit

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.white.opacity(0.5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(.hairline, lineWidth: 0.5)
                    )
                    .frame(width: 38, height: 38)
                Image(systemName: benefit.icon)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(.ink)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(benefit.title)
                    .font(Typography.display(size: 18, weight: .regular))
                    .foregroundStyle(.ink)
                Text(benefit.subtitle)
                    .font(Typography.body(size: 13))
                    .foregroundStyle(.inkSecondary)
            }
        }
    }
}

#Preview {
    @Previewable @State var prefs = UserPreferences()
    return PaywallView(prefs: prefs)
}
