//
//  RevenueCatPurchaseService.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/5/27.
//
import RevenueCat

struct RevenueCatPurchaseService: PurchaseService {
    /// https://www.revenuecat.com/docs/getting-started/making-purchases
    /// 注意点: 需要在 revenuecat 控制台
    /// 1. 添加商品,RevenueCat can automatically import Products from App Store Connect
    /// 2. 添加 entitlement, 这里添加了一个 "unlock_premium"
    init(apiKey: String, logLevel: LogLevel = .warn) {
        Purchases.configure(withAPIKey: apiKey)
        Purchases.logLevel = logLevel
        Purchases.shared.attribution.collectDeviceIdentifiers()
    }
    
    func listenForTransactions(onTransactionUpdated: ([PurchasedEntitlement]) -> Void) async {
        for await customerInfo in Purchases.shared.customerInfoStream {
            let entitlements = customerInfo.entitlements.all.asPurchasedEntitlements()
            onTransactionUpdated(entitlements)
        }
    }
    
    func getUserEntitlements() async throws -> [PurchasedEntitlement] {
        let customerInfo = try await Purchases.shared.customerInfo()
        return customerInfo.entitlements.all.asPurchasedEntitlements()
    }
    
    func getProducts(productIds: [String]) async throws -> [AnyProduct] {
        let products = await Purchases.shared.products(productIds)
        return products.map { AnyProduct(revenueCatProduct: $0) }
    }
    
    func restorePurchase() async throws -> [PurchasedEntitlement] {
        let customerInfo = try await Purchases.shared.restorePurchases()
        return customerInfo.entitlements.all.asPurchasedEntitlements()
    }
    
    func purchaseProduct(productId: String) async throws -> [PurchasedEntitlement] {
        let products = await Purchases.shared.products([productId])
        guard let product = products.first else {
            throw PurchaseError.productNotFound
        }
        let result = try await Purchases.shared.purchase(product: product)
        let customerInfo = result.customerInfo
        return customerInfo.entitlements.all.asPurchasedEntitlements()
    }
    
    func logIn(userId: String) async throws -> [PurchasedEntitlement] {
        let (customerInfo, _) = try await Purchases.shared.logIn(userId)
        return customerInfo.entitlements.all.asPurchasedEntitlements()
    }
    
    func updateProfileAttributes(attributes: PurchaseProfileAttributes) async throws {
        if let email = attributes.email {
            Purchases.shared.attribution.setEmail(email)
        }
        
        if let firebaseAppInstanceID = attributes.firebaseAppInstanceID {
            Purchases.shared.attribution.setFirebaseAppInstanceID(firebaseAppInstanceID)
        }
        
        if let mixpanelDistinctID = attributes.mixpanelDistinctID {
            Purchases.shared.attribution.setMixpanelDistinctID(mixpanelDistinctID)
        }
    }
    
    func logOut() async throws {
        _ = try await Purchases.shared.logOut()
    }
}
