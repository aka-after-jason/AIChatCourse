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
    
    // MARK: CreateAccountView
    func createAccountView(delegate: CreateAccountDelegate = CreateAccountDelegate()) -> some View {
        CreateAccountView(
            viewModel: CreateAccountViewModel(interactor: interactor),
            delegate: delegate
        )
    }
    
    func createAccountView() -> some View {
        CreateAccountView(viewModel: CreateAccountViewModel(interactor: interactor))
    }
    
    // MARK: DevSettingsView
    func devSettingsView() -> some View {
        DevSettingsView(
            viewModel: DevSettingsViewModel(interactor: interactor)
        )
    }
    
    // MARK: ExploreView
    func exploreView() -> some View {
        ExploreView(
            viewModel: ExploreViewModel(interactor: interactor)
        )
    }
    
    // MARK: AppView
    func appView() -> some View {
        AppView(viewModel: AppViewModel(interactor: interactor))
    }
    
    func tabbarView() -> some View {
        TabBarView()
    }
    
    func welcomeView() -> some View {
        WelcomeView(viewModel: WelcomeViewModel(interactor: interactor))
    }
    
    // MARK: CategoryListView
    func categoryListView(delegate: CategoryListDelegate) -> some View {
        CategoryListView(
            viewModel: CategoryListViewModel(interactor: interactor),
            delegate: delegate
        )
    }
    
    // MARK: PaywallView
    func paywallView() -> some View {
        PaywallView(viewModel: PaywallViewModel(interactor: interactor))
    }
    
    // MARK: ChatView
    func chatView(delegate: ChatViewDelegate = ChatViewDelegate()) -> some View {
        ChatView(viewModel: ChatViewModel(interactor: interactor), delegate: delegate)
    }
    
    // MARK: ChatsView
    func chatRowCellViewBuilder(delegate: ChatRowCellViewDelegate = ChatRowCellViewDelegate()) -> some View {
        ChatRowCellViewBuilder(
            viewModel: ChatRowCellViewModel(interactor: interactor),
            delegate: delegate
        )
    }
    
    func chatsView() -> some View {
        ChatsView(viewModel: ChatsViewModel(interactor: interactor))
    }
    
    // MARK: CreateAvatarView
    func createAvatarView() -> some View {
        CreateAvatarView(viewModel: CreateAvatarViewModel(interactor: interactor))
    }
    
    // MARK: OnboardingColorView
    func onboardingColorView(delegate: OnboardingColorDelete) -> some View {
        OnboardingColorView(
            viewModel: OnboardingColorViewModel(interactor: interactor),
            delegate: delegate
        )
    }
    
    // MARK: OnboardingCommunityView
    func onboardingCommunityView(delegate: OnboardingCommunityDelete) -> some View {
        OnboardingCommunityView(
            viewModel: OnboardingCommunityViewModel(interactor: interactor),
            delegate: delegate
        )
    }
    
    // MARK: OnboardingCompletedView
    func onboardingCompletedView(delegate: OnboardingCompletedDelete) -> some View {
        OnboardingCompletedView(viewModel: OnboardingCompletedViewModel(interactor: interactor), delegate: delegate)
    }
    
    // MARK: OnboardingIntroView
    func onboardingIntroView(delegate: OnboardingIntroDelete) -> some View {
        OnboardingIntroView(viewModel: OnboardingIntroViewModel(interactor: interactor), delegate: delegate)
    }
    
    // MARK: SettingsView
    func settingsView() -> some View {
        SettingsView(viewModel: SettingsViewModel(interactor: interactor))
    }
    
    // MARK: ProfileView
    func profileView() -> some View {
        ProfileView(viewModel: ProfileViewModel(interactor: interactor))
    }
}
