//
//  PaywallViewModel.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/6/7.
//
import SwiftUI
import StoreKit

@MainActor
protocol PaywallViewModelInteractor {
    var activeABTestModel: ActiveABTestModel { get }
    func trackEvent(event: LoggableEvent)
    func getProducts(productIds: [String]) async throws -> [AnyProduct]
    func restorePurchase() async throws -> [PurchasedEntitlement]
    func purchaseProduct(productId: String) async throws -> [PurchasedEntitlement]
}

extension CoreInteractor: PaywallViewModelInteractor {}

@MainActor
@Observable
final class PaywallViewModel {
    private let interactor: PaywallViewModelInteractor
    init(interactor: PaywallViewModelInteractor) {
        self.interactor = interactor
    }

    private(set) var products: [AnyProduct] = []
    private(set) var productIds: [String] = EntitlementOption.allProductIds
    var showAlert: AnyAppAlertItem?

    var activeABTestModel: ActiveABTestModel {
        interactor.activeABTestModel
    }

    func onLoadProducts() async {
        interactor.trackEvent(event: Event.loadProductsStart)
        do {
            products = try await interactor.getProducts(productIds: productIds)
        } catch {
            showAlert = AnyAppAlertItem(error: error)
        }
    }

    func onBackButtonPressed(onDismiss: () -> Void) {
        interactor.trackEvent(event: Event.backButtonPressed)
        onDismiss()
    }

    func onRestorePurchasePressed(onDismiss: @escaping () -> Void) {
        interactor.trackEvent(event: Event.restorePurchaseStart)
        Task {
            do {
                let entitlements = try await interactor.restorePurchase()
                if entitlements.hasActiveEntitlement {
                    onDismiss()
                }
            } catch {
                showAlert = AnyAppAlertItem(error: error)
            }
        }
    }

    func onPurchaseProductPressed(product: AnyProduct, onDismiss: @escaping () -> Void) {
        interactor.trackEvent(event: Event.purchaseStart(product: product))
        Task {
            do {
                let entitlements = try await interactor.purchaseProduct(productId: product.id)
                interactor.trackEvent(event: Event.purchaseSuccess(product: product))
                if entitlements.hasActiveEntitlement {
                    onDismiss()
                }

            } catch {
                showAlert = AnyAppAlertItem(error: error)
                interactor.trackEvent(event: Event.purchaseFail(error: error))
            }
        }
    }

    func onPurchaseStart(product: StoreKit.Product) {
        let product = AnyProduct(storeKitProduct: product)
        interactor.trackEvent(event: Event.purchaseStart(product: product))
    }

    func onPurchaseComplete(product: Product, result: Result<Product.PurchaseResult, any Error>, onDismiss: () -> Void) {
        let product = AnyProduct(storeKitProduct: product)
        switch result {
        case .success(let value):
            switch value {
            case .success:
                interactor.trackEvent(event: Event.purchaseSuccess(product: product))
                onDismiss()
            case .pending:
                interactor.trackEvent(event: Event.purchasePending(product: product))
            case .userCancelled:
                interactor.trackEvent(event: Event.purchaseUserCancelled(product: product))
            default:
                interactor.trackEvent(event: Event.purchaseUnknown(product: product))
            }
        case .failure(let error):
            interactor.trackEvent(event: Event.purchaseFail(error: error))
        }
    }
}

extension PaywallViewModel {
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
