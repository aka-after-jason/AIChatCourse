//
//  PaywallView.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/5/26.
//

import StoreKit
import SwiftUI

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

struct PaywallView: View {
    @Environment(LogManager.self) private var logManager
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        StoreKitPaywallView(
            onInAppPurchaseStart: onPurchaseStart,
            onInAppPurchaseCompletion: onPurchaseComplete
        )
        .appearAnalyticsViewModifier(name: "Paywall")
    }

    private func onPurchaseStart(product: StoreKit.Product) {
        let product = AnyProduct(storeKitProduct: product)
        logManager.trackEvent(event: Event.purchaseStart(product: product))
    }

    private func onPurchaseComplete(product: Product, result: Result<Product.PurchaseResult, any Error>) {
        let product = AnyProduct(storeKitProduct: product)
        switch result {
        case .success(let value):
            switch value {
            case .success:
                logManager.trackEvent(event: Event.purchaseSuccess(product: product))
                dismiss()
            case .pending:
                logManager.trackEvent(event: Event.purchasePending(product: product))
            case .userCancelled:
                logManager.trackEvent(event: Event.purchaseUserCancelled(product: product))
            default:
                logManager.trackEvent(event: Event.purchaseUnknown(product: product))
            }
        case .failure(let error):
            logManager.trackEvent(event: Event.purchaseFail(error: error))
        }
    }
}

struct StoreKitPaywallView: View {
    var onInAppPurchaseStart: ((Product) async -> Void)?
    var onInAppPurchaseCompletion: ((Product, Result<Product.PurchaseResult, any Error>) async -> Void)?
    var body: some View {
        SubscriptionStoreView(productIDs: EntitlementOption.allProductIds) {
            VStack(spacing: 8) {
                Text("AI Chat 🤗")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                Text("Get premium access to unlock all features.")
                    .font(.subheadline)
            }
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
            .containerBackground(Color.accent.gradient, for: .subscriptionStore)
        }
        .storeButton(.visible, for: .restorePurchases)
        .subscriptionStoreControlStyle(.prominentPicker)
        .onInAppPurchaseStart(perform: onInAppPurchaseStart)
        .onInAppPurchaseCompletion(perform: onInAppPurchaseCompletion)
    }
}

extension PaywallView {
    enum Event: LoggableEvent {
        case purchaseStart(product: AnyProduct)
        case purchaseSuccess(product: AnyProduct)
        case purchasePending(product: AnyProduct)
        case purchaseUserCancelled(product: AnyProduct)
        case purchaseUnknown(product: AnyProduct)
        case purchaseFail(error: Error)
        
        var eventName: String {
            switch self {
            case .purchaseStart: return "PaywallView_Purchase_Start"
            case .purchaseSuccess: return "PaywallView_Purchase_Success"
            case .purchasePending: return "PaywallView_Purchase_Pending"
            case .purchaseUserCancelled: return "PaywallView_Purchase_UserCancelled"
            case .purchaseUnknown: return "PaywallView_Purchase_Unknown"
            case .purchaseFail: return "PaywallView_Purchase_Fail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .purchaseFail(error: let error):
                return error.eventParameters
            case .purchaseStart(product: let product), .purchasePending(product: let product), .purchaseSuccess(product: let product), .purchaseUnknown(product: let product), .purchaseUserCancelled(product: let product):
                return product.eventParameters
            }
        }
        
        var type: CustomLogType {
            switch self {
            case .purchaseFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
}

#Preview {
    PaywallView()
        .previewEnvironment()
}
