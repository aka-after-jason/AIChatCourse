//
//  PaywallView.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/5/26.
//

import StoreKit
import SwiftUI

struct PaywallView: View {
    @State var viewModel: PaywallViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            switch viewModel.activeABTestModel.paywallTest {
            case .custom:
                if viewModel.products.isEmpty {
                    ProgressView()
                } else {
                    CustomPaywallView(
                        onBackButtonPressed: {
                            viewModel.onBackButtonPressed(onDismiss: { dismiss() })
                        },
                        onRestorePurchasePressed: {
                            viewModel.onRestorePurchasePressed(onDismiss: { dismiss() })
                        },
                        onPurchaseProductPressed: { product in
                            viewModel.onPurchaseProductPressed(product: product, onDismiss: { dismiss() })
                        },
                        products: viewModel.products
                    )
                }
            case .revenueCat:
                RevenueCatPaywallView()
            case .storeKit:
                StoreKitPaywallView(
                    productIds: viewModel.productIds,
                    onInAppPurchaseStart: viewModel.onPurchaseStart,
                    onInAppPurchaseCompletion: { product, result in
                        viewModel.onPurchaseComplete(product: product, result: result, onDismiss: { dismiss() })
                    }
                )
            }
        }
        .appearAnalyticsViewModifier(name: "Paywall")
        .showCustomAlert(alertItem: $viewModel.showAlert)
        .task {
            await viewModel.onLoadProducts()
        }
    }
}

#Preview("Custom") {
    let container = DevPreview.shared.container
    container.regiser(ABTestManager.self, manager: ABTestManager(service: MockABTestService(paywallTest: .custom)))
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    return builder.paywallView()
        .previewEnvironment()
}

#Preview("StoreKit") {
    let container = DevPreview.shared.container
    container.regiser(ABTestManager.self, manager: ABTestManager(service: MockABTestService(paywallTest: .storeKit)))
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    return builder.paywallView()
        .previewEnvironment()
}

#Preview("RevenueCat") {
    let container = DevPreview.shared.container
    container.regiser(ABTestManager.self, manager: ABTestManager(service: MockABTestService(paywallTest: .revenueCat)))
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    return builder.paywallView()
        .previewEnvironment()
}
