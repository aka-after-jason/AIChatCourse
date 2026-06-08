//
//  CoreBuilder.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/6/8.
//
import SwiftUI

@MainActor
@Observable
final class CoreBuilder {
    
    private let interactor: CoreInteractor
    init(interactor: CoreInteractor) {
        self.interactor = interactor
    }
    
    func createAccountView(delegate: CreateAccountDelegate = CreateAccountDelegate()) -> some View {
        CreateAccountView(
            viewModel: CreateAccountViewModel(interactor: interactor),
            delegate: delegate
        )
    }
    
    func createAccountView() -> some View {
        CreateAccountView(viewModel: CreateAccountViewModel(interactor: interactor))
    }
    
    func devSettingsView() -> some View {
        DevSettingsView(
            viewModel: DevSettingsViewModel(interactor: interactor)
        )
    }
    
    func exploreView() -> some View {
        ExploreView(
            viewModel: ExploreViewModel(interactor: interactor)
        )
    }
}
