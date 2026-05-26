//
//  EntitlementOption.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/5/26.
//

enum EntitlementOption: Codable, CaseIterable {
    case yearly

    var productId: String {
        switch self {
        case .yearly:
            return "com.aka.AIChat.release.yearly"
        }
    }

    static var allProductIds: [String] {
        EntitlementOption.allCases.map { $0.productId }
    }
}
