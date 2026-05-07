import SwiftData
import SwiftUI

@main
struct MedityApp: App {
    /// Persisted across launches via `UserDefaults`. Flipped to `true` when
    /// the user finishes onboarding — by tapping the final CTA or "Skip".
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    /// Shared services injected via `.environment` so any view can read them.
    @State private var healthStore = HealthStore()
    @State private var audioEngine = AudioEngine()

    /// Persistence container — CloudKit-backed when the device is signed
    /// in to iCloud and the container is reachable; falls back to local
    /// SQLite when CloudKit can't initialise (free dev account on a real
    /// device, no network during first launch, etc.).
    private let modelContainer = MedityApp.makeModelContainer()

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
        .modelContainer(modelContainer)
    }

    /// Builds the SwiftData container, preferring CloudKit-private
    /// synchronisation. The first attempt declares the iCloud container
    /// explicitly; if that fails for any reason we fall back to a local
    /// store so the app still runs (data just doesn't sync). A second
    /// failure is fatal — at that point the device can't even create a
    /// local SQLite, and there's nothing meaningful for us to do.
    private static func makeModelContainer() -> ModelContainer {
        let schema = Schema([Session.self, UserPreferences.self])
        let cloudConfig = ModelConfiguration(
            schema: schema,
            cloudKitDatabase: .private("iCloud.com.aituglo.medity")
        )
        do {
            return try ModelContainer(for: schema, configurations: [cloudConfig])
        } catch {
            print("CloudKit container failed (\(error)) — falling back to local store")
            let localConfig = ModelConfiguration(schema: schema)
            do {
                return try ModelContainer(for: schema, configurations: [localConfig])
            } catch {
                fatalError("Failed to create even a local ModelContainer: \(error)")
            }
        }
    }
}
