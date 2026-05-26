//
//  EntitlementOwnershipOption.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/5/26.
//

public enum EntitlementOwnershipOption: Codable, Sendable {
    case purchased, familyShared, unknown
}

import StoreKit

extension EntitlementOwnershipOption {
    init(type: Transaction.OwnershipType) {
        switch type {
        case .purchased:
            self = .purchased
        case .familyShared:
            self = .familyShared
        default:
            self = .unknown
        }
    }
}
