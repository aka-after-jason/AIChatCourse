//
//  CoreBuilder.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/6/8.
//
import SwiftUI

@MainActor
struct CoreBuilder {
    let interactor: CoreInteractor

    // MARK: CreateAccountView

    func createAccountView(delegate: CreateAccountDelegate = CreateAccountDelegate()) -> AnyView {
        CreateAccountView(
            viewModel: CreateAccountViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }
    
    func createAccountView() -> AnyView {
        CreateAccountView(viewModel: CreateAccountViewModel(interactor: interactor))
            .any()
    }
    
    // MARK: DevSettingsView

    func devSettingsView() -> AnyView {
        DevSettingsView(
            viewModel: DevSettingsViewModel(interactor: interactor)
        )
        .any()
    }
    
    // MARK: ExploreView

    func exploreView() -> AnyView {
        ExploreView(
            viewModel: ExploreViewModel(interactor: interactor),
            devSettingsView: {
                devSettingsView()
            },
            createAccountView: {
                createAccountView()
            },
            chatView: { delegate in
                chatView(delegate: delegate)
            },
            categoryListView: { delegate in
                categoryListView(delegate: delegate)
            }
        )
        .any()
    }
    
    // MARK: AppView

    func appView() -> AnyView {
        AppView(
            viewModel: AppViewModel(interactor: interactor),
            tabbarView: {
                tabbarView()
            },
            onboardingView: {
                welcomeView()
            }
        )
        .any()
    }
    
    func tabbarView() -> AnyView {
        TabBarView(
            tabs: [
                TabBarScreen(title: "Explore", systemImage: "eyes", screen: {
                    exploreView()
                }),
                TabBarScreen(title: "Chats", systemImage: "bubble.left.and.bubble.right", screen: {
                    chatsView()
                }),
                TabBarScreen(title: "Profile", systemImage: "person.fill", screen: {
                    profileView()
                })
            ]
        )
        .any()
    }
    
    func welcomeView() -> AnyView {
        WelcomeView(
            viewModel: WelcomeViewModel(interactor: interactor),
            createAccountView: { delegate in
                createAccountView(delegate: delegate)
            },
            onboardingColorView: { delegate in
                onboardingColorView(delegate: delegate)
            },
            onboardingCommunityView: { delegate in
                onboardingCommunityView(delegate: delegate)
            },
            onboardingIntroView: { delegate in
                onboardingIntroView(delegate: delegate)
            },
            onboardingCompletedView: { delegate in
                onboardingCompletedView(delegate: delegate)
            }
        )
        .any()
    }
    
    // MARK: CategoryListView

    func categoryListView(delegate: CategoryListDelegate) -> AnyView {
        CategoryListView(
            viewModel: CategoryListViewModel(interactor: interactor),
            delegate: delegate,
            chatView: { delegate in
                chatView(delegate: delegate)
            },
            categoryListView: { delegate in
                categoryListView(delegate: delegate)
            }
        )
        .any()
    }
    
    // MARK: PaywallView

    func paywallView() -> AnyView {
        PaywallView(viewModel: PaywallViewModel(interactor: interactor))
            .any()
    }
    
    // MARK: ChatView

    func chatView(delegate: ChatViewDelegate = ChatViewDelegate()) -> AnyView {
        ChatView(
            viewModel: ChatViewModel(interactor: interactor),
            delegate: delegate,
            paywallView: {
                paywallView()
            }
        )
        .any()
    }
    
    // MARK: ChatsView

    func chatRowCellViewBuilder(delegate: ChatRowCellViewDelegate = ChatRowCellViewDelegate()) -> AnyView {
        ChatRowCellViewBuilder(
            viewModel: ChatRowCellViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }
    
    func chatsView() -> AnyView {
        ChatsView(
            viewModel: ChatsViewModel(interactor: interactor),
            chatRowCellViewBuilder: { delegate in
                chatRowCellViewBuilder(delegate: delegate)
            },
            chatView: { delegate in
                chatView(delegate: delegate)
            },
            categoryListView: { delegate in
                categoryListView(delegate: delegate)
            }
        )
        .any()
    }
    
    // MARK: CreateAvatarView

    func createAvatarView() -> AnyView {
        CreateAvatarView(viewModel: CreateAvatarViewModel(interactor: interactor))
            .any()
    }
    
    // MARK: OnboardingColorView

    func onboardingColorView(delegate: OnboardingColorDelete) -> AnyView {
        OnboardingColorView(
            viewModel: OnboardingColorViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }
    
    // MARK: OnboardingCommunityView

    func onboardingCommunityView(delegate: OnboardingCommunityDelete) -> AnyView {
        OnboardingCommunityView(
            viewModel: OnboardingCommunityViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }
    
    // MARK: OnboardingCompletedView

    func onboardingCompletedView(delegate: OnboardingCompletedDelete) -> AnyView {
        OnboardingCompletedView(viewModel: OnboardingCompletedViewModel(interactor: interactor), delegate: delegate)
            .any()
    }
    
    // MARK: OnboardingIntroView

    func onboardingIntroView(delegate: OnboardingIntroDelete) -> AnyView {
        OnboardingIntroView(viewModel: OnboardingIntroViewModel(interactor: interactor), delegate: delegate)
            .any()
    }
    
    // MARK: SettingsView

    func settingsView() -> AnyView {
        SettingsView(
            viewModel: SettingsViewModel(interactor: interactor),
            createAccountView: {
                createAvatarView()
            }
        )
        .any()
    }
    
    // MARK: ProfileView

    func profileView() -> AnyView {
        ProfileView(
            viewModel: ProfileViewModel(interactor: interactor),
            settingsView: {
                settingsView()
            },
            createAvatarView: {
                createAvatarView()
            },
            chatView: { delegate in
                chatView(delegate: delegate)
            },
            categoryListView: { delegate in
                categoryListView(delegate: delegate)
            }
        )
        .any()
    }
}
