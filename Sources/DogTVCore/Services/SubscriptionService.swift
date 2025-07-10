// swiftlint:disable import_organization mark_usage file_length
import Foundation
import StoreKit
import Combine
// swiftlint:enable import_organization

/// Comprehensive subscription and monetization service for DogTV+
/// Handles subscriptions, in-app purchases, family sharing, and revenue optimization
@available(iOS 17.0, tvOS 17.0, macOS 10.15, *)
@MainActor
public final class SubscriptionService: ObservableObject {
    
    // MARK: - Shared Instance
    
    public static let shared = SubscriptionService()
    
    // MARK: - Published Properties
    
    @Published public private(set) var subscriptionStatus: SubscriptionStatus = .notSubscribed
    @Published public private(set) var availableProducts: [Product] = []
    @Published public private(set) var currentSubscription: SubscriptionInfo?
    @Published public private(set) var purchaseState: PurchaseState = .idle
    @Published public private(set) var familySharing: FamilySharingInfo?
    @Published public private(set) var isRestoring: Bool = false
    
    // MARK: - Private Properties
    
    private var cancellables = Set<AnyCancellable>()
    private var updateListenerTask: Task<Void, Error>?
    private let businessIntelligence = BusinessIntelligenceService.shared
    
    // MARK: - Product Identifiers
    
    private enum ProductIdentifier: String, CaseIterable {
        case monthlySubscription = "com.dogtv.plus.monthly"
        case yearlySubscription = "com.dogtv.plus.yearly"
        case familySubscription = "com.dogtv.plus.family"
        case premiumContent = "com.dogtv.plus.premium"
        case scenePackForest = "com.dogtv.plus.forest_pack"
        case scenePackOcean = "com.dogtv.plus.ocean_pack"
        case scenePackStars = "com.dogtv.plus.stars_pack"
    }
    
    private init() {
        setupStoreKitListener()
        Task {
            await loadProducts()
            await updateSubscriptionStatus()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Public API
    
    /// Load available products from the App Store
    public func loadProducts() async {
        do {
            let products = try await Product.products(for: ProductIdentifier.allCases.map { $0.rawValue })
            self.availableProducts = products.sorted { $0.price < $1.price }
            
            print("📱 [Subscription] Loaded \(products.count) products")
        } catch {
            print("❌ [Subscription] Failed to load products: \(error)")
        }
    }
    
    /// Purchase a subscription or product
    public func purchase(_ product: Product) async -> PurchaseResult {
        purchaseState = .purchasing
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                await handleSuccessfulPurchase(verification: verification)
                purchaseState = .purchased
                
                // Track business event
                businessIntelligence.trackBusinessEvent(.purchase, metadata: [
                    "product_id": product.id,
                    "price": product.price,
                    "currency": product.priceFormatStyle.currencyCode ?? "USD"
                ])
                
                return .success
                
            case .userCancelled:
                purchaseState = .idle
                return .cancelled
                
            case .pending:
                purchaseState = .pending
                return .pending
                
            @unknown default:
                purchaseState = .failed
                return .failed
            }
        } catch {
            purchaseState = .failed
            print("❌ [Subscription] Purchase failed: \(error)")
            return .failed
        }
    }
    
    /// Restore previous purchases
    public func restorePurchases() async {
        isRestoring = true
        
        do {
            try await AppStore.sync()
            await updateSubscriptionStatus()
            
            businessIntelligence.trackBusinessEvent(.userLogin, metadata: [
                "action": "restore_purchases"
            ])
            
            print("✅ [Subscription] Purchases restored")
        } catch {
            print("❌ [Subscription] Failed to restore purchases: \(error)")
        }
        
        isRestoring = false
    }
    
    /// Check subscription status
    public func updateSubscriptionStatus() async {
        await checkActiveSubscriptions()
        await checkFamilySharing()
    }
    
    /// Get localized price for a product
    public func localizedPrice(for productID: String) -> String? {
        guard let product = availableProducts.first(where: { $0.id == productID }) else {
            return nil
        }
        return product.displayPrice
    }
    
    /// Check if user has access to premium features
    public func hasPremiumAccess() -> Bool {
        switch subscriptionStatus {
        case .subscribed, .familyShared:
            return true
        case .notSubscribed, .expired, .inGracePeriod:
            return false
        }
    }
    
    /// Get subscription benefits description
    public func getSubscriptionBenefits() -> [SubscriptionBenefit] {
        return [
            SubscriptionBenefit(
                title: "Unlimited Content Access",
                description: "Access to all premium scenes and content",
                icon: "infinity.circle.fill"
            ),
            SubscriptionBenefit(
                title: "Advanced Audio Features",
                description: "High-quality spatial audio and noise reduction",
                icon: "spatial.audio.fill"
            ),
            SubscriptionBenefit(
                title: "AI-Powered Recommendations",
                description: "Personalized content recommendations for your dog",
                icon: "brain.head.profile"
            ),
            SubscriptionBenefit(
                title: "Family Sharing",
                description: "Share with up to 6 family members",
                icon: "person.3.fill"
            ),
            SubscriptionBenefit(
                title: "Offline Mode",
                description: "Download content for offline viewing",
                icon: "arrow.down.circle.fill"
            ),
            SubscriptionBenefit(
                title: "Priority Support",
                description: "Get faster customer support response",
                icon: "headphones.circle.fill"
            )
        ]
    }
    
    /// Calculate savings for yearly subscription
    public func calculateYearlySavings() -> (savings: Double, percentage: Double)? {
        guard let monthly = availableProducts.first(where: { $0.id == ProductIdentifier.monthlySubscription.rawValue }),
              let yearly = availableProducts.first(where: { $0.id == ProductIdentifier.yearlySubscription.rawValue }) else {
            return nil
        }
        
        let monthlyAnnualCost = monthly.price * 12
        let savings = monthlyAnnualCost - yearly.price
        let percentage = (savings / monthlyAnnualCost) * 100
        
        return (savings: savings, percentage: percentage)
    }
    
    /// Manage subscription (upgrade, downgrade, cancel)
    public func manageSubscription() async {
        do {
            try await AppStore.showManageSubscriptions(in: nil)
        } catch {
            print("❌ [Subscription] Failed to show manage subscriptions: \(error)")
        }
    }
    
    // MARK: - Private Methods
    
    private func setupStoreKitListener() {
        updateListenerTask = listenForTransactions()
    }
    
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    await self.updateSubscriptionStatus()
                    await transaction.finish()
                } catch {
                    print("❌ [Subscription] Transaction verification failed: \(error)")
                }
            }
        }
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw SubscriptionError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    private func handleSuccessfulPurchase(verification: VerificationResult<Transaction>) async {
        do {
            let transaction = try checkVerified(verification)
            
            // Update subscription info
            currentSubscription = SubscriptionInfo(
                productID: transaction.productID,
                purchaseDate: transaction.purchaseDate,
                expirationDate: transaction.expirationDate,
                isAutoRenewing: transaction.isUpgraded == false,
                transactionID: String(transaction.id)
            )
            
            subscriptionStatus = .subscribed
            
            // Finish the transaction
            await transaction.finish()
            
            print("✅ [Subscription] Purchase completed: \(transaction.productID)")
            
        } catch {
            print("❌ [Subscription] Failed to handle successful purchase: \(error)")
        }
    }
    
    private func checkActiveSubscriptions() async {
        var hasActiveSubscription = false
        
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                
                if let expirationDate = transaction.expirationDate {
                    if expirationDate > Date() {
                        hasActiveSubscription = true
                        
                        currentSubscription = SubscriptionInfo(
                            productID: transaction.productID,
                            purchaseDate: transaction.purchaseDate,
                            expirationDate: transaction.expirationDate,
                            isAutoRenewing: transaction.isUpgraded == false,
                            transactionID: String(transaction.id)
                        )
                    } else {
                        // Subscription expired, check grace period
                        let gracePeriod: TimeInterval = 16 * 24 * 60 * 60 // 16 days
                        if Date().timeIntervalSince(expirationDate) < gracePeriod {
                            subscriptionStatus = .inGracePeriod
                        } else {
                            subscriptionStatus = .expired
                        }
                    }
                } else {
                    // Non-consumable purchase
                    hasActiveSubscription = true
                }
            } catch {
                print("❌ [Subscription] Failed to verify transaction: \(error)")
            }
        }
        
        if hasActiveSubscription && subscriptionStatus != .inGracePeriod {
            subscriptionStatus = .subscribed
        } else if !hasActiveSubscription && subscriptionStatus != .inGracePeriod {
            subscriptionStatus = .notSubscribed
            currentSubscription = nil
        }
    }
    
    private func checkFamilySharing() async {
        // Check if subscription is shared via Family Sharing
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                
                if transaction.ownershipType == .familyShared {
                    familySharing = FamilySharingInfo(
                        isShared: true,
                        organizerID: transaction.appAccountToken?.description ?? "unknown",
                        memberCount: 1 // StoreKit doesn't provide member count
                    )
                    
                    if subscriptionStatus == .notSubscribed {
                        subscriptionStatus = .familyShared
                    }
                } else {
                    familySharing = FamilySharingInfo(
                        isShared: false,
                        organizerID: nil,
                        memberCount: 1
                    )
                }
            } catch {
                print("❌ [Subscription] Failed to check family sharing: \(error)")
            }
        }
    }
}

// MARK: - Supporting Types

/// Subscription status
public enum SubscriptionStatus: String, Codable, CaseIterable {
    case notSubscribed = "not_subscribed"
    case subscribed = "subscribed"
    case expired = "expired"
    case inGracePeriod = "in_grace_period"
    case familyShared = "family_shared"
}

/// Purchase state
public enum PurchaseState: String, Codable, CaseIterable {
    case idle = "idle"
    case purchasing = "purchasing"
    case purchased = "purchased"
    case pending = "pending"
    case failed = "failed"
}

/// Purchase result
public enum PurchaseResult {
    case success
    case cancelled
    case pending
    case failed
}

/// Subscription information
public struct SubscriptionInfo: Codable, Sendable {
    public let productID: String
    public let purchaseDate: Date
    public let expirationDate: Date?
    public let isAutoRenewing: Bool
    public let transactionID: String
    
    public init(productID: String, purchaseDate: Date, expirationDate: Date?, isAutoRenewing: Bool, transactionID: String) {
        self.productID = productID
        self.purchaseDate = purchaseDate
        self.expirationDate = expirationDate
        self.isAutoRenewing = isAutoRenewing
        self.transactionID = transactionID
    }
    
    public var isValid: Bool {
        guard let expirationDate = expirationDate else { return true }
        return expirationDate > Date()
    }
    
    public var daysUntilExpiration: Int? {
        guard let expirationDate = expirationDate else { return nil }
        return Calendar.current.dateComponents([.day], from: Date(), to: expirationDate).day
    }
}

/// Family sharing information
public struct FamilySharingInfo: Codable, Sendable {
    public let isShared: Bool
    public let organizerID: String?
    public let memberCount: Int
    
    public init(isShared: Bool, organizerID: String?, memberCount: Int) {
        self.isShared = isShared
        self.organizerID = organizerID
        self.memberCount = memberCount
    }
}

/// Subscription benefit
public struct SubscriptionBenefit: Codable, Identifiable, Sendable {
    public let id = UUID()
    public let title: String
    public let description: String
    public let icon: String
    
    public init(title: String, description: String, icon: String) {
        self.title = title
        self.description = description
        self.icon = icon
    }
}

/// Subscription errors
public enum SubscriptionError: Error, LocalizedError {
    case failedVerification
    case noProductsAvailable
    case purchaseInProgress
    case unknownError
    
    public var errorDescription: String? {
        switch self {
        case .failedVerification:
            return "Unable to verify the purchase. Please try again."
        case .noProductsAvailable:
            return "No subscription products are available."
        case .purchaseInProgress:
            return "A purchase is already in progress."
        case .unknownError:
            return "An unknown error occurred. Please try again."
        }
    }
}

// MARK: - Extensions

@available(iOS 17.0, tvOS 17.0, macOS 10.15, *)
extension Product {
    /// Formatted price with currency symbol
    var displayPrice: String {
        return priceFormatStyle.format(price)
    }
    
    /// Check if this is a subscription product
    var isSubscription: Bool {
        return type == .autoRenewable
    }
    
    /// Get subscription period description
    var subscriptionPeriodDescription: String? {
        guard let subscription = subscription else { return nil }
        
        let period = subscription.subscriptionPeriod
        let value = period.value
        
        switch period.unit {
        case .day:
            return value == 1 ? "Daily" : "\(value) Days"
        case .week:
            return value == 1 ? "Weekly" : "\(value) Weeks"
        case .month:
            return value == 1 ? "Monthly" : "\(value) Months"
        case .year:
            return value == 1 ? "Yearly" : "\(value) Years"
        @unknown default:
            return nil
        }
    }
}
// swiftlint:enable import_organization mark_usage file_length
