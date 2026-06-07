//
//  WelcomeViewModel.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/6/7.
//
import SwiftUI

protocol WelcomeViewModelInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: WelcomeViewModelInteractor {}

@MainActor
@Observable
final class WelcomeViewModel {
    private let interactor: WelcomeViewModelInteractor
    init(interactor: WelcomeViewModelInteractor) {
        self.interactor = interactor
    }

    var path: [NavOnboardingPathOption] = []
    var showSignIn: Bool = false
    private(set) var imageName: String = Constants.randomImageUrl
    
    func onGetStartedPressed() {
        path.append(.introView)
    }

    func onSignInPressed() {
        interactor.trackEvent(event: Event.signInPressed)
        showSignIn = true
    }

    func handleDidSignIn(isNewUser: Bool, onShowTabBarView: () -> Void) {
        interactor.trackEvent(event: Event.didSignIn(isNewUser: isNewUser))
        if isNewUser {
            // do nothing, user gose through onboading
        } else {
            // push into tabbar view
            onShowTabBarView()
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
