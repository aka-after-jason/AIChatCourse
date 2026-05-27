//
//  PaywallView.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/5/26.
//

import StoreKit
import SwiftUI

struct PaywallView: View {
    @Environment(PurchaseManager.self) private var purchaseManager
    @Environment(LogManager.self) private var logManager
    @Environment(\.dismiss) private var dismiss
    @State private var products: [AnyProduct] = []
    @State private var productIds: [String] = EntitlementOption.allProductIds
    @State private var showAlert: AnyAppAlertItem?
    var body: some View {
        ZStack {
            RevenueCatPaywallView()

//            if products.isEmpty {
//                ProgressView()
//            } else {
//                CustomPaywallView(
//                    onBackButtonPressed: onBackButtonPressed,
//                    onRestorePurchasePressed: onRestorePurchasePressed,
//                    onPurchaseProductPressed: onPurchaseProductPressed,
//                    products: products
//                )
//            }
        }
//        StoreKitPaywallView(
//            productIds: productIds,
//            onInAppPurchaseStart: onPurchaseStart,
//            onInAppPurchaseCompletion: onPurchaseComplete
//        )
        .appearAnalyticsViewModifier(name: "Paywall")
        .showCustomAlert(alertItem: $showAlert)
        .task {
            await onLoadProducts()
        }
    }

    private func onLoadProducts() async {
        logManager.trackEvent(event: Event.loadProductsStart)
        do {
            products = try await purchaseManager.getProducts(productIds: productIds)
        } catch {
            showAlert = AnyAppAlertItem(error: error)
        }
    }

    private func onBackButtonPressed() {
        logManager.trackEvent(event: Event.backButtonPressed)
        dismiss()
    }

    private func onRestorePurchasePressed() {
        logManager.trackEvent(event: Event.restorePurchaseStart)
        Task {
            do {
                let entitlements = try await purchaseManager.restorePurchase()
                if entitlements.hasActiveEntitlement {
                    dismiss()
                }
            } catch {
                showAlert = AnyAppAlertItem(error: error)
            }
        }
    }

    private func onPurchaseProductPressed(product: AnyProduct) {
        logManager.trackEvent(event: Event.purchaseStart(product: product))
        Task {
            do {
                let entitlements = try await purchaseManager.purchaseProduct(productId: product.id)
                logManager.trackEvent(event: Event.purchaseSuccess(product: product))
                if entitlements.hasActiveEntitlement {
                    dismiss()
                }

            } catch {
                showAlert = AnyAppAlertItem(error: error)
                logManager.trackEvent(event: Event.purchaseFail(error: error))
            }
        }
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

extension PaywallView {
    enum Event: LoggableEvent {
        case purchaseStart(product: AnyProduct)
        case purchaseSuccess(product: AnyProduct)
        case purchasePending(product: AnyProduct)
        case purchaseUserCancelled(product: AnyProduct)
        case purchaseUnknown(product: AnyProduct)
        case purchaseFail(error: Error)
        case loadProductsStart
        case restorePurchaseStart
        case backButtonPressed

        var eventName: String {
            switch self {
            case .purchaseStart: return "PaywallView_Purchase_Start"
            case .purchaseSuccess: return "PaywallView_Purchase_Success"
            case .purchasePending: return "PaywallView_Purchase_Pending"
            case .purchaseUserCancelled: return "PaywallView_Purchase_UserCancelled"
            case .purchaseUnknown: return "PaywallView_Purchase_Unknown"
            case .purchaseFail: return "PaywallView_Purchase_Fail"
            case .loadProductsStart: return "PaywallView_LoadProducts_Start"
            case .restorePurchaseStart: return "PaywallView_RestorePurchase_Start"
            case .backButtonPressed: return "PaywallView_BackButton_Pressed"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .purchaseFail(error: let error):
                return error.eventParameters
            case .purchaseStart(product: let product), .purchasePending(product: let product), .purchaseSuccess(product: let product), .purchaseUnknown(product: let product), .purchaseUserCancelled(product: let product):
                return product.eventParameters
            default:
                return nil
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
