//
//  PurchasedEntitlement+RevenueCat.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/5/27.
//

import RevenueCat

// [String: EntitlementInfo] 转成 [PurchasedEntitlement]
extension Dictionary where Key == String, Value == EntitlementInfo {
    func asPurchasedEntitlements() -> [PurchasedEntitlement] {
        map({ PurchasedEntitlement(entitlement: $0.value) })
    }
}

extension PurchasedEntitlement {
    init(entitlement: EntitlementInfo) {
        self.init(
            id: entitlement.id,
            productId: entitlement.productIdentifier,
            expirationDate: entitlement.expirationDate,
            isActive: entitlement.isActive,
            originalPurchaseDate: entitlement.originalPurchaseDate,
            latestPurchaseDate: entitlement.latestPurchaseDate,
            ownershipType: EntitlementOwnershipOption(type: entitlement.ownershipType),
            isSandbox: entitlement.isSandbox,
            isVerified: entitlement.verification.isVerified
        )
    }
}

extension EntitlementOwnershipOption {
    init(type: PurchaseOwnershipType) { // from revenuecat
        switch type {
        case .purchased:
            self = .purchased
        case .familyShared:
            self = .familyShared
        case .unknown:
            self = .unknown
        }
    }
}
