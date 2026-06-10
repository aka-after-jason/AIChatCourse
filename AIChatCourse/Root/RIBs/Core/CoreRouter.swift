//
//  CoreRouter.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/6/10.
//
import SwiftUI
// @_exported this explicitly tells Xcode to export this imported module to the rest of the target.
@_exported import CustomRouting // 不加 @_exported, 在使用 typealias 的时候没有用

typealias RouterView = CustomRouting.RouterView

@MainActor
struct CoreRouter: GlobalRouter {
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
        router.showScreen(.fullScreenCover) { router in
            builder.createAvatarView(router: router)
                .onDisappear(perform: { onDisappear() })
        }
    }
    
    func showAboutView(delegate: AboutDelegate) {
        router.showScreen(.push) { router in
            builder.aboutView(router: router, delegate: delegate)
        }
    }

    // MARK: sheets

    func showPaywallView() {
        router.showScreen(.sheet) { router in
            builder.paywallView(router: router)
        }
    }

    func showSettingsView() {
        router.showScreen(.sheet) { router in
            builder.settingsView(router: router)
        }
    }

    func showDevSettingsView() {
        router.showScreen(.sheet) { router in
            builder.devSettingsView(router: router)
        }
    }

    func showCreateAccountView(delegate: CreateAccountDelegate, onDisappear: (() -> Void)? = nil) {
        router.showScreen(.sheet) { router in
            builder.createAccountView(router: router, delegate: delegate)
                .presentationDetents([.medium])
                .onDisappear(perform: { onDisappear?() })
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

    func showRatingsModal(onEnjoyAppYesPressed: @escaping () -> Void, onEnjoyAppNoPressed: @escaping () -> Void) {
        router.showModal(
            backgroundColor: Color.black.opacity(0.6),
            transition: .move(edge: .bottom),
            destination: {
                CustomModalView(
                    title: "Are you enjoying AIChat?",
                    subtitle: "We'd love to hear your feedback!",
                    primaryButtonTitle: "Yes",
                    primaryButtonAction: {
                        onEnjoyAppYesPressed()
                    },
                    secondaryButtonTitle: "No",
                    secondaryButtonAction: {
                        onEnjoyAppNoPressed()
                    }
                )
            }
        )
    }
}
