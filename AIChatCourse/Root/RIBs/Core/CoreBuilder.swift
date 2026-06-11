//
//  CoreBuilder.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/6/8.
//
import SwiftUI

@MainActor
struct CoreBuilder: Builder {
    let interactor: CoreInteractor
    
    func build() -> AnyView {
        tabbarView().any()
    }
    
    func tabbarView() -> some View {
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
    }

    // MARK: DevSettingsView

    func devSettingsView(router: Router) -> some View {
        DevSettingsView(
            presenter: DevSettingsPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            )
        )
    }
    
    // MARK: CreateAccountView

    func createAccountView(router: Router, delegate: CreateAccountDelegate = CreateAccountDelegate()) -> some View {
        CreateAccountView(
            presenter: CreateAccountPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }

    func createAccountView(router: Router) -> some View {
        CreateAccountView(
            presenter: CreateAccountPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            )
        )
    }

    // MARK: ExploreView

    func exploreView(router: Router) -> some View {
        ExploreView(
            presenter: ExplorePresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            )
        )
    }

    // MARK: CategoryListView

    func categoryListView(router: Router, delegate: CategoryListDelegate) -> some View {
        CategoryListView(
            presenter: CategoryListPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }

    // MARK: PaywallView

    func paywallView(router: Router) -> some View {
        PaywallView(
            presenter: PaywallPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            )
        )
    }

    // MARK: ChatView

    func chatView(router: Router, delegate: ChatViewDelegate = ChatViewDelegate()) -> some View {
        ChatView(
            presenter: ChatPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }

    // MARK: ChatsView

    func chatRowCellViewBuilder(delegate: ChatRowCellViewDelegate = ChatRowCellViewDelegate()) -> some View {
        ChatRowCellViewBuilder(
            viewModel: ChatRowCellViewModel(interactor: interactor),
            delegate: delegate
        )
    }

    func chatsView(router: Router) -> some View {
        ChatsView(
            presenter: ChatsPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            chatRowCellViewBuilder: { delegate in
                chatRowCellViewBuilder(delegate: delegate)
            }
        )
    }

    // MARK: CreateAvatarView

    func createAvatarView(router: Router) -> some View {
        CreateAvatarView(
            presenter: CreateAvatarPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            )
        )
    }

    // MARK: SettingsView

    func settingsView(router: Router) -> some View {
        SettingsView(
            presenter: SettingsPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            )
        )
    }

    // MARK: ProfileView

    func profileView(router: Router) -> some View {
        ProfileView(
            presenter: ProfilePresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            )
        )
    }
    
    // MARK: AboutView
    func aboutView(router: Router, delegate: AboutDelegate) -> some View {
        AboutView(
            presenter: AboutPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
}
