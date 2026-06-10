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

    var body: some View {
        ZStack {
            switch viewModel.activeABTestModel.paywallTest {
            case .custom:
                if viewModel.products.isEmpty {
                    ProgressView()
                } else {
                    CustomPaywallView(
                        onBackButtonPressed: {
                            viewModel.onBackButtonPressed()
                        },
                        onRestorePurchasePressed: {
                            viewModel.onRestorePurchasePressed()
                        },
                        onPurchaseProductPressed: { product in
                            viewModel.onPurchaseProductPressed(product: product)
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
                        viewModel.onPurchaseComplete(product: product, result: result)
                    }
                )
            }
        }
        .appearAnalyticsViewModifier(name: "Paywall")
        .task {
            await viewModel.onLoadProducts()
        }
    }
}

#Preview("Custom") {
    let container = DevPreview.shared.container
    container.regiser(ABTestManager.self, manager: ABTestManager(service: MockABTestService(paywallTest: .custom)))
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    return RouterView { router in
        builder.paywallView(router: router)
    }
    .previewEnvironment()
}

#Preview("StoreKit") {
    let container = DevPreview.shared.container
    container.regiser(ABTestManager.self, manager: ABTestManager(service: MockABTestService(paywallTest: .storeKit)))
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    return RouterView { router in
        builder.paywallView(router: router)
    }
    .previewEnvironment()
}

#Preview("RevenueCat") {
    let container = DevPreview.shared.container
    container.regiser(ABTestManager.self, manager: ABTestManager(service: MockABTestService(paywallTest: .revenueCat)))
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    return RouterView { router in
        builder.paywallView(router: router)
    }
    .previewEnvironment()
}
