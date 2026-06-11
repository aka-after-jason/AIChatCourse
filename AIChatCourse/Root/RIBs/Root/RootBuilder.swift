//
//  RootBuilder.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/6/11.
//
import SwiftUI

@MainActor
struct RootBuilder: Builder {
    let interactor: RootInteractor
    let loggedInRIB: Builder
    
    func build() -> AnyView {
        appView().any()
    }
    
    func appView() -> some View {
        AppView(
            viewModel: AppViewModel(interactor: interactor),
            tabbarView: {
                loggedInRIB.build()
            },
            onboardingView: {
                Text("onboardingView")
            }
        )
    }
}

