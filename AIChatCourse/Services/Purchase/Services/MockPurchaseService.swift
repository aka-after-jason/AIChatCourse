//
//  MockPurchaseService.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/5/27.
//

struct MockPurchaseService: PurchaseService {
    let activeEntitlements: [PurchasedEntitlement]
    
    init(activeEntitlements: [PurchasedEntitlement] = []) {
        self.activeEntitlements = activeEntitlements
    }
    
    func listenForTransactions(onTransactionUpdated: ([PurchasedEntitlement]) -> Void) async {
        onTransactionUpdated(activeEntitlements)
    }
    
    func getUserEntitlements() async throws -> [PurchasedEntitlement] {
        activeEntitlements
    }
    
    func getProducts(productIds: [String]) async throws -> [AnyProduct] {
        return AnyProduct.mocks.filter { product in
            productIds.contains(product.id)
        }
    }
    
    func restorePurchase() async throws -> [PurchasedEntitlement] {
        activeEntitlements
    }
    
    func purchaseProduct(productId: String) async throws -> [PurchasedEntitlement] {
        activeEntitlements
    }
    
    func logIn(userId: String) async throws -> [PurchasedEntitlement] {
        activeEntitlements
    }
    
    func updateProfileAttributes(attributes: PurchaseProfileAttributes) async throws {}
    
    func logOut() async throws {}
}
