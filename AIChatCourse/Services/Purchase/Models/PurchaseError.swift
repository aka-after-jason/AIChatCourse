//
//  PurchaseError.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/5/27.
//

import SwiftUI

enum PurchaseError: LocalizedError {
    case productNotFound, userCancelledPurchase, failedToPurchase
}
