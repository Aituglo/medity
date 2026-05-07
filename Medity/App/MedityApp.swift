import SwiftUI
import SwiftData

@main
struct MedityApp: App {
    /// Persisted across launches via `UserDefaults`. Flipped to `true` when
    /// the user finishes onboarding — by tapping the final CTA or "Skip".
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    /// Shared services injected via `.environment` so any view can read them.
    @State private var healthStore = HealthStore()
    @State private var audioEngine = AudioEngine()

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
            .environment(healthStore)
            .environment(audioEngine)
        }
        // Local-only persistence in V1. Switching to CloudKit-synced is a
        // single-line change to a `ModelConfiguration` once the developer
        // account has provisioned an iCloud container.
        .modelContainer(for: [Session.self, UserPreferences.self])
    }
}
