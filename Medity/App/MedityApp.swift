import SwiftUI

@main
struct MedityApp: App {
    /// Persisted across launches via `UserDefaults`. Flipped to `true` when
    /// the user finishes onboarding — by tapping the final CTA or "Skip".
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some Scene {
        WindowGroup {
            Group {
                if hasCompletedOnboarding {
                    HomeView()
                } else {
                    OnboardingView {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            hasCompletedOnboarding = true
                        }
                    }
                }
            }
            .animation(.easeInOut(duration: 0.5), value: hasCompletedOnboarding)
        }
    }
}
