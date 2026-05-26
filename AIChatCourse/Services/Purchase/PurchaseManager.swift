//
//  PurchaseManager.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/5/26.
//

import SwiftUI

protocol PurchaseService {
    func listenForTransactions(onTransactionUpdated: ([PurchasedEntitlement]) -> Void) async
    func getUserEntitlements() async -> [PurchasedEntitlement]
}

struct MockPurchaseService: PurchaseService {
    
    let activeEntitlements: [PurchasedEntitlement]
    
    init(activeEntitlements: [PurchasedEntitlement] = []) {
        self.activeEntitlements = activeEntitlements
    }
    
    func listenForTransactions(onTransactionUpdated: ([PurchasedEntitlement]) -> Void) async {
        onTransactionUpdated(activeEntitlements)
    }
    
    func getUserEntitlements() async -> [PurchasedEntitlement] {
        activeEntitlements
    }
}

import StoreKit

struct StoreKitPurchaseService: PurchaseService {
    func listenForTransactions(onTransactionUpdated: ([PurchasedEntitlement]) -> Void) async {
        for await update in Transaction.updates {
            if let transaction = try? update.payloadValue {
                let entitlements = await getUserEntitlements()
                onTransactionUpdated(entitlements)
                await transaction.finish()
            }
        }
    }

    func getUserEntitlements() async -> [PurchasedEntitlement] {
        var activeTransactions: [PurchasedEntitlement] = []
        for await verificationResult in Transaction.currentEntitlements {
            switch verificationResult {
            case .verified(let transaction):
                let isActive: Bool
                if let expirationDate = transaction.expirationDate {
                    isActive = expirationDate >= Date.now
                } else {
                    isActive = transaction.revocationDate == nil
                }
                activeTransactions.append(
                    PurchasedEntitlement(
                        id: String(transaction.id),
                        productId: transaction.productID,
                        expirationDate: transaction.expirationDate,
                        isActive: isActive,
                        originalPurchaseDate: transaction.originalPurchaseDate,
                        latestPurchaseDate: transaction.purchaseDate,
                        ownershipType: EntitlementOwnershipOption(type: transaction.ownershipType),
                        isSandbox: transaction.environment == .sandbox,
                        isVerified: true
                    )
                )
            case .unverified:
                break
            }
        }
        return activeTransactions
    }
}

@MainActor
@Observable
final class PurchaseManager {
    
    private let service: PurchaseService
    private let logManager: LogManager?
    
    /// User's purchased entitlements sorted by most recent
    private(set) var entitlements: [PurchasedEntitlement] = []
    
    init(service: PurchaseService, logManager: LogManager? = nil) {
        self.service = service
        self.logManager = logManager
        self.configure()
    }
    
    private func configure() {
        Task {
            let entitlements = await service.getUserEntitlements()
            updateActiveEntitlements(entitlements: entitlements)
        }
        Task {
            await service.listenForTransactions { entitlements in
                updateActiveEntitlements(entitlements: entitlements)
            }
        }
    }
    
    private func updateActiveEntitlements(entitlements: [PurchasedEntitlement]) {
        self.entitlements = entitlements.sortedByKeyPath(keyPath: \.expirationDateCalc, ascending: false)
        logManager?.addUserProperties(dict: entitlements.eventParameters, isHighPriority: false)
    }
}
