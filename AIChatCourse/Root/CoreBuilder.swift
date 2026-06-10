//
//  CoreBuilder.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/6/8.
//
import SwiftUI

// @_exported this explicitly tells Xcode to export this imported module to the rest of the target.
@_exported import CustomRouting // 不加 @_exported, 在使用 typealias 的时候没有用

typealias RouterView = CustomRouting.RouterView

@MainActor
struct CoreRouter {
    let router: Router
    let builder: CoreBuilder

    // MARK: segues

    func showCategoryListView(delegate: CategoryListDelegate) {
        router.showScreen(.push) { router in
            builder.categoryListView(router: router, delegate: delegate)
        }
    }

    func showChatView(delegate: ChatViewDelegate) {
        router.showScreen(.push) { router in
            builder.chatView(router: router, delegate: delegate)
        }
    }

    func showOnboardingIntroView(delegate: OnboardingIntroDelete) {
        router.showScreen(.push) { router in
            builder.onboardingIntroView(router: router, delegate: delegate)
        }
    }

    func showOnboardingCommunityView(delegate: OnboardingCommunityDelete) {
        router.showScreen(.push) { router in
            builder.onboardingCommunityView(router: router, delegate: delegate)
        }
    }

    func showOnboardingColorView(delegate: OnboardingColorDelete) {
        router.showScreen(.push) { router in
            builder.onboardingColorView(router: router, delegate: delegate)
        }
    }

    func showOnboardingCompletedView(delegate: OnboardingCompletedDelete) {
        router.showScreen(.push) { router in
            builder.onboardingCompletedView(router: router, delegate: delegate)
        }
    }

    func showCreateAvatarView(onDisappear: @escaping () -> Void) {
        router.showScreen(.fullScreenCover) { _ in
            builder.createAvatarView()
                .onDisappear {
                    onDisappear()
                }
        }
    }

    func dismissScreen() {
        router.dismissScreen()
    }

    // MARK: sheets

    func showPaywallView() {
        router.showScreen(.sheet) { _ in
            builder.paywallView()
        }
    }

    func showSettingsView() {
        router.showScreen(.sheet) { _ in
            builder.settingsView()
        }
    }

    func showDevSettingsView() {
        router.showScreen(.sheet) { _ in
            builder.devSettingsView()
        }
    }

    func showCreateAccountView(delegate: CreateAccountDelegate) {
        router.showScreen(.sheet) { _ in
            builder.createAccountView(delegate: delegate)
                .presentationDetents([.medium])
        }
    }

    // MARK: modals

    func showPushNotificationModal(onEnablePressed: @escaping () -> Void, onCancelPressed: @escaping () -> Void) {
        router.showModal(
            backgroundColor: Color.black.opacity(0.6),
            transition: .move(edge: .bottom),
            destination: {
                CustomModalView(
                    title: "Enable push notifications?",
                    subtitle: "We'll send you reminders and updates!",
                    primaryButtonTitle: "Enable",
                    primaryButtonAction: {
                        onEnablePressed()
                    },
                    secondaryButtonTitle: "Cancel",
                    secondaryButtonAction: {
                        onCancelPressed()
                    }
                )
            }
        )
    }

    func showProfileModal(avatar: AvatarModel, onXmarkPressed: @escaping () -> Void) {
        router.showModal(
            backgroundColor: Color.black.opacity(0.6),
            transition: .slide,
            destination: {
                ProfileModalView(
                    imageName: avatar.profileImageName,
                    title: avatar.name,
                    subtitle: avatar.characterOption?.rawValue.capitalized,
                    headline: avatar.characterDescription,
                    onXmarkPressed: {
                        onXmarkPressed()
                    }
                )
                .padding(40)
            }
        )
    }

    func dismissModal() {
        router.dismissModal()
    }

    // MARK: alerts

    func showAlert(type: CustomRouting.AlertType, title: String, subtitle: String?, buttons: (() -> AnyView)?) {
        router.showAlert(type: type, title: title, subtitle: subtitle, buttons: buttons)
    }

    func showAlert(title: String, subtitle: String?) {
        router.showAlert(type: .alert, title: title, subtitle: subtitle, buttons: nil)
    }

    func showAlert(error: Error) {
        router.showAlert(type: .alert, title: "Error", subtitle: error.localizedDescription, buttons: nil)
    }

    func dismissAlert() {
        router.dismissAlert()
    }
}

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

    func exploreView(router: Router) -> AnyView {
        ExploreView(
            viewModel: ExploreViewModel(
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
            viewModel: CategoryListViewModel(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
        .any()
    }

    // MARK: PaywallView

    func paywallView() -> AnyView {
        PaywallView(viewModel: PaywallViewModel(interactor: interactor))
            .any()
    }

    // MARK: ChatView

    func chatView(router: Router, delegate: ChatViewDelegate = ChatViewDelegate()) -> AnyView {
        ChatView(
            viewModel: ChatViewModel(
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
            viewModel: ChatsViewModel(
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

    func createAvatarView() -> AnyView {
        CreateAvatarView(viewModel: CreateAvatarViewModel(interactor: interactor))
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
