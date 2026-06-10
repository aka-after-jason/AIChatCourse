//
//  CreateAccountViewModel.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/6/6.
//
import SwiftUI

@MainActor
protocol CreateAccountViewModelInteractor {
    func trackEvent(event: LoggableEvent)
    func signInApple() async throws -> (user: UserAuthInfoModel, isNewUser: Bool)
    func login(user: UserAuthInfoModel, isNewUser: Bool) async throws
}
extension CoreInteractor: CreateAccountViewModelInteractor {}

@MainActor
protocol CreateAccountViewModelRouter {
    func dismissScreen()
}
extension CoreRouter: CreateAccountViewModelRouter {}

@MainActor
@Observable
final class CreateAccountViewModel {
    private let interactor: CreateAccountViewModelInteractor
    private let router: CreateAccountViewModelRouter
    init(interactor: CreateAccountViewModelInteractor, router: CreateAccountViewModelRouter) {
        self.interactor = interactor
        self.router = router
    }

    func onSignInApplePressed(delegate: CreateAccountDelegate) {
        interactor.trackEvent(event: Event.appleAuthStart)
        Task {
            do {
                let (userAuthInfo, isNewUser) = try await interactor.signInApple()
                interactor.trackEvent(event: Event.appleAuthSuccess(user: userAuthInfo, isNewUser: isNewUser))
                try await interactor.login(user: userAuthInfo, isNewUser: isNewUser)
                interactor.trackEvent(event: Event.appleAuthLoginSuccess(user: userAuthInfo, isNewUser: isNewUser))
                delegate.onDidSignIn?(isNewUser)
                router.dismissScreen()
            } catch {
                interactor.trackEvent(event: Event.appleAuthFail(error: error))
            }
        }
    }
}

extension CreateAccountViewModel {
    enum Event: LoggableEvent {
        case appleAuthStart
        case appleAuthSuccess(user: UserAuthInfoModel, isNewUser: Bool)
        case appleAuthFail(error: Error)
        case appleAuthLoginSuccess(user: UserAuthInfoModel, isNewUser: Bool)

        var eventName: String {
            switch self {
            case .appleAuthStart: return "CreateAccountView_AppleAuth_Start"
            case .appleAuthSuccess: return "CreateAccountView_AppleAuth_Success"
            case .appleAuthFail: return "CreateAccountView_AppleAuth_Fail"
            case .appleAuthLoginSuccess: return "CreateAccountView_AppleAuth_LoginSuccess"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .appleAuthSuccess(user: let user, isNewUser: let isNewUser), .appleAuthLoginSuccess(user: let user, isNewUser: let isNewUser):
                var dict = user.eventParams
                dict["is_new_user"] = isNewUser
                return dict
            case .appleAuthFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }

        var type: CustomLogType {
            switch self {
            case .appleAuthFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
}
