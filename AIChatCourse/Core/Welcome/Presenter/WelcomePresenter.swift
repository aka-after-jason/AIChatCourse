//
//  WelcomeViewModel.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/6/7.
//
import SwiftUI

@MainActor
@Observable
final class WelcomePresenter {
    private let interactor: WelcomeInteractor
    private let router: WelcomeRouter
    init(interactor: WelcomeInteractor, router: WelcomeRouter) {
        self.interactor = interactor
        self.router = router
    }

    private(set) var imageName: String = Constants.randomImageUrl
    
    func onGetStartedPressed() {
        router.showOnboardingIntroView(delegate: OnboardingIntroDelete())
    }

    func onSignInPressed() {
        interactor.trackEvent(event: Event.signInPressed)
        let delegate = CreateAccountDelegate(
            title: "Sign in",
            subtitle: "Connect to an existing account") { isNewUser in
                self.handleDidSignIn(isNewUser: isNewUser)
            }
        router.showCreateAccountView(delegate: delegate, onDisappear: nil)
    }

    private func handleDidSignIn(isNewUser: Bool) {
        interactor.trackEvent(event: Event.didSignIn(isNewUser: isNewUser))
        if isNewUser {
            // do nothing, user gose through onboading
        } else {
            // push into tabbar view
            interactor.updateAppState(showTabBarView: true)
        }
    }
}

extension WelcomePresenter {
    enum Event: LoggableEvent {
        case didSignIn(isNewUser: Bool)
        case signInPressed
        var eventName: String {
            switch self {
            case .didSignIn: return "WelcomeView_DidSignIn"
            case .signInPressed: return "WelcomeView_SignIn_Pressed"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .didSignIn(isNewUser: let isNewUser):
                return ["is_new_user": isNewUser]
            default:
                return nil
            }
        }

        var type: CustomLogType {
            switch self {
            default:
                return .analytic
            }
        }
    }
}
