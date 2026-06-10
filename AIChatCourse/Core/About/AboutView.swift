//
//  AboutView.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/6/10.
//

import SwiftUI

@MainActor
protocol AboutInteractor {}
extension CoreInteractor: AboutInteractor {}

@MainActor
protocol AboutRouter {
    func dismissScreen()
    func showRandomView(delegate: RandomDelegate)
}
extension CoreRouter: AboutRouter {}

@MainActor
@Observable
final class AboutPresenter {
    private let interactor: AboutInteractor
    private let router: AboutRouter
    init(interactor: AboutInteractor, router: AboutRouter) {
        self.interactor = interactor
        self.router = router
    }

    func onDismissPressed() {
        router.dismissScreen()
    }
    
    func onRandomPressed() {
        router.showRandomView(delegate: RandomDelegate())
    }
}

struct AboutDelegate {}

struct AboutView: View {
    @State var presenter: AboutPresenter
    let delegate: AboutDelegate

    var body: some View {
        List {
            Text("Made by SwiftfulThinking!")
            Button(action: {
                presenter.onDismissPressed()
            }, label: {
                Text("Dismiss")
            })
            
            Button(action: {
                presenter.onRandomPressed()
            }, label: {
                Text("RandomView")
            })
        }
        .navigationTitle("About Us")
        .appearAnalyticsViewModifier(name: "AboutView")
    }
}

#Preview {
    let container = DevPreview.shared.container
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = AboutDelegate()
    return RouterView { router in
        builder.aboutView(router: router, delegate: delegate)
    }
    .previewEnvironment()
}
