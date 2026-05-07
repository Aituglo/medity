import Foundation
import HealthKit
import Observation

/// Wrapper around `HKHealthStore` exposing only the operations Medity needs:
/// authorization, writing a Mindful Minutes sample at the end of a session,
/// and (eventually) reading heart-rate metrics for the completion summary.
///
/// All public methods are safe to call on any state — when HealthKit isn't
/// available (rare on iPhone, more common on iPad/Mac Catalyst) they no-op.
@MainActor
@Observable
final class HealthStore {
    /// Whether the device exposes HealthKit at all.
    static let isAvailable = HKHealthStore.isHealthDataAvailable()

    /// Whether the user has granted us write authorization for Mindful
    /// Minutes. Read-only; updated after `requestAuthorization`.
    private(set) var canWriteMindfulMinutes: Bool = false

    private let store = HKHealthStore()

    private static let mindfulSessionType: HKCategoryType? =
        HKObjectType.categoryType(forIdentifier: .mindfulSession)

    /// Surfaces the system permission sheet for our HealthKit needs.
    /// Idempotent — calling it after the user already chose simply
    /// re-checks the current authorization status.
    func requestAuthorization() async {
        guard Self.isAvailable, let mindful = Self.mindfulSessionType else { return }

        var typesToRead: Set<HKObjectType> = [mindful]
        if let hr = HKObjectType.quantityType(forIdentifier: .heartRate) {
            typesToRead.insert(hr)
        }
        if let hrv = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN) {
            typesToRead.insert(hrv)
        }
        let typesToWrite: Set<HKSampleType> = [mindful]

        do {
            try await store.requestAuthorization(toShare: typesToWrite, read: typesToRead)
            canWriteMindfulMinutes = store.authorizationStatus(for: mindful) == .sharingAuthorized
        } catch {
            canWriteMindfulMinutes = false
        }
    }

    /// Writes a Mindful Minutes sample for the time window the user actually
    /// meditated. Silently fails when authorization is missing or HealthKit
    /// isn't available — meditation shouldn't be blocked by the OS.
    func saveSession(start: Date, end: Date) async {
        guard Self.isAvailable, let mindful = Self.mindfulSessionType else { return }
        guard end > start else { return }
        let sample = HKCategorySample(
            type: mindful,
            value: HKCategoryValue.notApplicable.rawValue,
            start: start,
            end: end
        )
        try? await store.save(sample)
    }
}
