import Foundation
import StoreKit

/// Service for handling in-app purchases with StoreKit 2
actor StoreService {
    static let shared = StoreService()

    private let productIDs: Set<String> = [
        "com.biblechallenge.premium.monthly",
        "com.biblechallenge.premium.lifetime"
    ]

    private(set) var products: [Product] = []
    private(set) var purchasedProductIDs: Set<String> = []

    private var transactionListener: Task<Void, Error>?

    init() {
        transactionListener = listenForTransactions()
    }

    deinit {
        transactionListener?.cancel()
    }

    // MARK: - Product Loading

    func loadProducts() async throws -> [Product] {
        let loadedProducts = try await Product.products(for: productIDs)
        products = loadedProducts.sorted { $0.price < $1.price }
        return products
    }

    // MARK: - Purchasing

    func purchase(_ product: Product) async throws -> Transaction {
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await updatePurchasedProducts()
            await transaction.finish()
            return transaction

        case .userCancelled:
            throw PurchaseError.userCancelled

        case .pending:
            throw PurchaseError.pending

        @unknown default:
            throw PurchaseError.unknown
        }
    }

    // MARK: - Purchase Status

    func isPurchased(_ productID: String) async -> Bool {
        await updatePurchasedProducts()
        return purchasedProductIDs.contains(productID)
    }

    var isPremium: Bool {
        get async {
            await updatePurchasedProducts()
            return !purchasedProductIDs.isEmpty
        }
    }

    func updatePurchasedProducts() async {
        var purchased: Set<String> = []

        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }

            if transaction.revocationDate == nil {
                purchased.insert(transaction.productID)
            }
        }

        purchasedProductIDs = purchased
    }

    // MARK: - Restore Purchases

    func restorePurchases() async throws {
        try await AppStore.sync()
        await updatePurchasedProducts()
    }

    // MARK: - Transaction Listener

    private func listenForTransactions() -> Task<Void, Error> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                guard let self = self else { return }

                if case .verified(let transaction) = result {
                    await self.updatePurchasedProducts()
                    await transaction.finish()
                }
            }
        }
    }

    // MARK: - Verification

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw PurchaseError.verificationFailed(error)
        case .verified(let safe):
            return safe
        }
    }
}

// MARK: - Errors

enum PurchaseError: LocalizedError {
    case userCancelled
    case pending
    case verificationFailed(Error)
    case productNotFound
    case unknown

    var errorDescription: String? {
        switch self {
        case .userCancelled:
            return "Purchase was cancelled."
        case .pending:
            return "Purchase is pending approval."
        case .verificationFailed(let error):
            return "Purchase verification failed: \(error.localizedDescription)"
        case .productNotFound:
            return "Product not found."
        case .unknown:
            return "An unknown error occurred."
        }
    }
}

// MARK: - Product Extensions

extension Product {
    var isSubscription: Bool {
        subscription != nil
    }

    var subscriptionPeriodText: String? {
        guard let period = subscription?.subscriptionPeriod else { return nil }

        switch period.unit {
        case .day:
            return period.value == 1 ? "daily" : "every \(period.value) days"
        case .week:
            return period.value == 1 ? "weekly" : "every \(period.value) weeks"
        case .month:
            return period.value == 1 ? "monthly" : "every \(period.value) months"
        case .year:
            return period.value == 1 ? "yearly" : "every \(period.value) years"
        @unknown default:
            return nil
        }
    }
}
