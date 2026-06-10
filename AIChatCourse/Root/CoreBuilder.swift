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

    func createAccountView(router: Router, delegate: CreateAccountDelegate = CreateAccountDelegate()) -> AnyView {
        CreateAccountView(
            presenter: CreateAccountPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
        .any()
    }

    func createAccountView(router: Router) -> AnyView {
        CreateAccountView(
            presenter: CreateAccountPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            )
        )
        .any()
    }

    // MARK: DevSettingsView

    func devSettingsView(router: Router) -> AnyView {
        DevSettingsView(
            presenter: DevSettingsPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            )
        )
        .any()
    }

    // MARK: ExploreView

    func exploreView(router: Router) -> AnyView {
        ExploreView(
            presenter: ExplorePresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            )
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
                    RouterView { router in
                        exploreView(router: router)
                    }
                    .any()
                }),
                TabBarScreen(title: "Chats", systemImage: "bubble.left.and.bubble.right", screen: {
                    RouterView { router in
                        chatsView(router: router)
                    }
                    .any()
                }),
                TabBarScreen(title: "Profile", systemImage: "person.fill", screen: {
                    RouterView { router in
                        profileView(router: router)
                    }
                    .any()
                })
            ]
        )
        .any()
    }

    func welcomeView() -> AnyView {
        RouterView { router in
            WelcomeView(
                viewModel: WelcomeViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self))
            )
            .any()
        }
        .any()
    }

    // MARK: CategoryListView

    func categoryListView(router: Router, delegate: CategoryListDelegate) -> AnyView {
        CategoryListView(
            presenter: CategoryListPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
        .any()
    }

    // MARK: PaywallView

    func paywallView(router: Router) -> AnyView {
        PaywallView(
            viewModel: PaywallViewModel(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            )
        )
        .any()
    }

    // MARK: ChatView

    func chatView(router: Router, delegate: ChatViewDelegate = ChatViewDelegate()) -> AnyView {
        ChatView(
            presenter: ChatPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
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

    func chatsView(router: Router) -> AnyView {
        ChatsView(
            presenter: ChatsPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            chatRowCellViewBuilder: { delegate in
                chatRowCellViewBuilder(delegate: delegate)
            }
        )
        .any()
    }

    // MARK: CreateAvatarView

    func createAvatarView(router: Router) -> AnyView {
        CreateAvatarView(
            presenter: CreateAvatarPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            )
        )
        .any()
    }

    // MARK: OnboardingColorView

    func onboardingColorView(router: Router, delegate: OnboardingColorDelete) -> AnyView {
        OnboardingColorView(
            viewModel: OnboardingColorViewModel(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
        .any()
    }

    // MARK: OnboardingCommunityView

    func onboardingCommunityView(router: Router, delegate: OnboardingCommunityDelete) -> AnyView {
        OnboardingCommunityView(
            viewModel: OnboardingCommunityViewModel(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
        .any()
    }

    // MARK: OnboardingCompletedView

    func onboardingCompletedView(router: Router, delegate: OnboardingCompletedDelete) -> AnyView {
        OnboardingCompletedView(
            viewModel: OnboardingCompletedViewModel(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
        .any()
    }

    // MARK: OnboardingIntroView

    func onboardingIntroView(router: Router, delegate: OnboardingIntroDelete) -> AnyView {
        OnboardingIntroView(
            viewModel: OnboardingIntroViewModel(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
        .any()
    }

    // MARK: SettingsView

    func settingsView(router: Router) -> AnyView {
        SettingsView(
            viewModel: SettingsViewModel(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            )
        )
        .any()
    }

    // MARK: ProfileView

    func profileView(router: Router) -> AnyView {
        ProfileView(
            viewModel: ProfileViewModel(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            )
        )
        .any()
    }
}
