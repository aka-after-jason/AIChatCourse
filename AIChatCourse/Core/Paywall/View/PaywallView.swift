//
//  PaywallView.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/5/26.
//

import StoreKit
import SwiftUI

struct PaywallView: View {
    @State var presenter: PaywallPresenter

    var body: some View {
        ZStack {
            switch presenter.activeABTestModel.paywallTest {
            case .custom:
                if presenter.products.isEmpty {
                    ProgressView()
                } else {
                    CustomPaywallView(
                        onBackButtonPressed: {
                            presenter.onBackButtonPressed()
                        },
                        onRestorePurchasePressed: {
                            presenter.onRestorePurchasePressed()
                        },
                        onPurchaseProductPressed: { product in
                            presenter.onPurchaseProductPressed(product: product)
                        },
                        products: presenter.products
                    )
                }
            case .revenueCat:
                RevenueCatPaywallView()
            case .storeKit:
                StoreKitPaywallView(
                    productIds: presenter.productIds,
                    onInAppPurchaseStart: presenter.onPurchaseStart,
                    onInAppPurchaseCompletion: { product, result in
                        presenter.onPurchaseComplete(product: product, result: result)
                    }
                )
            }
        }
        .appearAnalyticsViewModifier(name: "Paywall")
        .task {
            await presenter.onLoadProducts()
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
