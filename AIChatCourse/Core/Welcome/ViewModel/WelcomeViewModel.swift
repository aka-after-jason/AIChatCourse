//
//  WelcomeViewModel.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/6/7.
//
import SwiftUI

@MainActor
protocol WelcomeViewModelInteractor {
    func trackEvent(event: LoggableEvent)
    func updateAppState(showTabBarView: Bool)
}
extension CoreInteractor: WelcomeViewModelInteractor {}

@MainActor
protocol WelcomeViewModelRoutre {
    func showOnboardingIntroView(delegate: OnboardingIntroDelete)
    func showCreateAccountView(delegate: CreateAccountDelegate, onDisappear: (() -> Void)?)
}
extension CoreRouter: WelcomeViewModelRoutre {}

@MainActor
@Observable
final class WelcomeViewModel {
    private let interactor: WelcomeViewModelInteractor
    private let router: WelcomeViewModelRoutre
    init(interactor: WelcomeViewModelInteractor, router: WelcomeViewModelRoutre) {
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

extension WelcomeViewModel {
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
