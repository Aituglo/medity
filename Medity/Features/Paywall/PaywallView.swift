import StoreKit
import SwiftUI

/// Medity Plus paywall — one-time IAP, no subscription.
///
/// Connects to `StoreService` (StoreKit 2). Tapping "Unlock" triggers the
/// real Apple purchase sheet; on success the verified transaction's
/// `productID` matches the Plus product, and we set
/// `prefs.hasUnlockedPlus = true` so the rest of the app reads the user
/// as a paying member. The `Medity.storekit` config file in the project
/// root drives the local sandbox during development.
struct PaywallView: View {
    @Bindable var prefs: UserPreferences
    @Environment(\.dismiss) private var dismiss
    @Environment(StoreService.self) private var store
    @State private var isPurchasing = false
    @State private var errorMessage: String?

    private let benefits: [Benefit] = [
        Benefit(icon: "waveform",      title: "All sounds",     subtitle: "14 nature, music, and noise tracks."),
        Benefit(icon: "bell",          title: "All bells",      subtitle: "5 bell timbres, custom intervals."),
        Benefit(icon: "clock.arrow.circlepath", title: "Future updates", subtitle: "New sounds, on us."),
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
        .task {
            await store.loadProduct()
        }
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
            .disabled(isPurchasing)
        }
        .padding(.horizontal, Spacing.xl)
        .padding(.top, Spacing.l)
    }

    private var bottomCTA: some View {
        VStack(spacing: 14) {
            Button(action: { Task { await purchase() } }) {
                ZStack {
                    if isPurchasing {
                        ProgressView()
                    } else {
                        Text(buyLabel)
                            .font(Typography.body(size: 18, weight: .medium))
                            .tracking(0.2)
                            .foregroundStyle(.ink)
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 64)
                .glassSurface(radius: Radius.button, tint: 0.55, interactive: true)
            }
            .buttonStyle(.plain)
            .disabled(isPurchasing || store.product == nil)

            Button("Restore purchase") {
                Task { await restore() }
            }
            .buttonStyle(.plain)
            .font(Typography.body(size: 13))
            .foregroundStyle(.inkTertiary)
            .disabled(isPurchasing)

            if let errorMessage {
                Text(errorMessage)
                    .font(Typography.body(size: 12))
                    .foregroundStyle(.warmAccent)
                    .multilineTextAlignment(.center)
                    .transition(.opacity)
            }
        }
        .padding(.horizontal, 28)
        .padding(.bottom, Spacing.xxl)
    }

    /// Use the live App Store price when the product has loaded, fall back
    /// to a hard-coded label otherwise so the CTA never looks broken.
    private var buyLabel: String {
        if let price = store.product?.displayPrice {
            return "Unlock — \(price) once"
        }
        return "Unlock — €14.99 once"
    }

    // MARK: - Actions

    private func purchase() async {
        isPurchasing = true
        errorMessage = nil
        defer { isPurchasing = false }
        do {
            let success = try await store.purchase()
            if success {
                prefs.hasUnlockedPlus = true
                dismiss()
            } else {
                // Cancel / pending / unverified — silently abort, no error.
            }
        } catch {
            errorMessage = "Purchase failed. \(error.localizedDescription)"
        }
    }

    private func restore() async {
        isPurchasing = true
        errorMessage = nil
        defer { isPurchasing = false }
        await store.restore()
        let unlocked = await store.isPlusUnlocked()
        prefs.hasUnlockedPlus = unlocked
        if unlocked {
            dismiss()
        } else {
            errorMessage = "No prior purchase found to restore."
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
        .environment(StoreService())
}
