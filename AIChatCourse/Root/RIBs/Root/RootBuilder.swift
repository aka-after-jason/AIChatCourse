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
    
    // 这里定义成 closure, 可以达到懒加载的目的, 需要用到才会执行
    // 如果定义成实例, 例如 let loggedInRIB: Builder, 则达不到
    let loggedInRIB: () -> Builder
    let loggedOutRIB: () -> Builder

    func build() -> AnyView {
        appView().any()
    }

    func appView() -> some View {
        AppView(
            viewModel: AppViewModel(interactor: interactor),
            tabbarView: {
                loggedInRIB().build()
            },
            onboardingView: {
                loggedOutRIB().build()
            }
        )
    }
}
