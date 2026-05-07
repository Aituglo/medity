import SwiftUI

/// Placeholder home screen — bootstrap target.
///
/// V1 of this view will host the timer ring (the app's signature element),
/// duration presets, sound/bells pills, and the begin CTA. For now it just
/// confirms the design system pieces compose correctly: ambient backdrop,
/// aura, cairn, type, and the primary button.
struct HomeView: View {
    var body: some View {
        ZStack {
            Backdrop(.dawn)

            VStack(spacing: 28) {
                Spacer()

                ZStack {
                    AuraView(size: 320)
                    CairnMark()
                        .fill(Color.ink)
                        .frame(width: 96, height: 100)
                }

                VStack(spacing: 12) {
                    Text("Medity")
                        .font(Typography.display(size: 64, weight: .thin))
                        .tracking(-1)
                        .foregroundStyle(.ink)

                    Text("A quieter mind, daily.")
                        .font(Typography.body(size: 17, weight: .light))
                        .italic()
                        .foregroundStyle(.inkSecondary)
                }

                Spacer()

                PrimaryButton("Begin", icon: .arrow) {
                    // wired up in the next iteration
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 36)
            }
        }
    }
}

#Preview {
    HomeView()
}
