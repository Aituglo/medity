import Foundation
import Observation
import StoreKit

/// Thin wrapper around StoreKit 2. Loads the Medity Plus product, performs
/// purchases / restores, and listens for unverified transactions in the
/// background. Callers (`PaywallView`, `SettingsView`, `HomeView`) write
/// the resulting entitlement to `UserPreferences.hasUnlockedPlus`, which
/// stays the single source of truth for gating premium content.
@Observable
final class StoreService: @unchecked Sendable {
    /// Apple-side product identifier. Must match the `productID` declared
    /// in `Medity.storekit` (and, in production, in App Store Connect).
    static let plusProductID = "com.aituglo.medity.plus"

    /// The loaded `Product`. `nil` until `loadProduct()` succeeds.
    private(set) var product: Product?

    private var transactionListenerTask: Task<Void, Never>?

    init() {
        // Detached listener — even if no view ever calls `purchase()`, an
        // ASD-side state change (renewal, refund, family sharing, …) gets
        // a chance to finish its transaction. Without `finish()` Apple's
        // queue keeps re-delivering the same update.
        transactionListenerTask = Task.detached { [weak self] in
            await self?.listenForTransactions()
        }
    }

    deinit {
        transactionListenerTask?.cancel()
    }

    // MARK: - Product loading

    /// Fetch the Plus product from StoreKit. Idempotent — once loaded, the
    /// cached product is reused. Call from `PaywallView`'s `.task`.
    func loadProduct() async {
        guard product == nil else { return }
        do {
            let products = try await Product.products(for: [Self.plusProductID])
            await MainActor.run { [weak self] in
                self?.product = products.first
            }
        } catch {
            print("StoreService: failed to load product — \(error)")
        }
    }

    // MARK: - Purchase / Restore

    /// Triggers Apple's purchase sheet. Returns `true` on a verified
    /// transaction, `false` on cancel / pending / unverified.
    func purchase() async throws -> Bool {
        guard let product else { return false }
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            switch verification {
            case .verified(let transaction):
                await transaction.finish()
                return true
            case .unverified:
                // The signature doesn't match Apple's expected JWS. Treat
                // as not-purchased and let the user retry.
                return false
            }
        case .userCancelled, .pending:
            return false
        @unknown default:
            return false
        }
    }

    /// Sync local entitlements with the App Store. Use after the user
    /// taps "Restore purchases".
    func restore() async {
        try? await AppStore.sync()
    }

    /// Walks `Transaction.currentEntitlements` and returns whether the
    /// Plus product is currently owned. Cheap and idempotent — call on
    /// app launch and after restore.
    func isPlusUnlocked() async -> Bool {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == Self.plusProductID {
                return true
            }
        }
        return false
    }

    // MARK: - Background updates

    private func listenForTransactions() async {
        for await update in Transaction.updates {
            if case .verified(let transaction) = update {
                await transaction.finish()
                // The view layer refreshes its entitlement on the next
                // foreground / paywall open, so we don't need to push
                // state from here.
            }
        }
    }
}
