//
//  PurchaseService.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/5/27.
//

protocol PurchaseService {
    func listenForTransactions(onTransactionUpdated: ([PurchasedEntitlement]) -> Void) async
    func getUserEntitlements() async throws -> [PurchasedEntitlement]
    func getProducts(productIds: [String]) async throws -> [AnyProduct]
    func restorePurchase() async throws -> [PurchasedEntitlement]
    func purchaseProduct(productId: String) async throws -> [PurchasedEntitlement]
    func logIn(userId: String) async throws -> [PurchasedEntitlement]
    func updateProfileAttributes(attributes: PurchaseProfileAttributes) async throws
    func logOut() async throws
}
