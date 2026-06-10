//
//  SettingsViewModel.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/6/7.
//
import SwiftUI

@MainActor
protocol SettingsViewModelInteractor {
    var authUser: UserAuthInfoModel? { get }
    func trackEvent(event: LoggableEvent)
    func signOut() async throws
    func getCurrentUserId() throws -> String
    func deleteAccount() async throws
    func deleteUser() async throws
    func removeAuthorIdFromAllUserAvatars(userId: String) async throws
    func deleteAllChatsForUser(userId: String) async throws
    func deleteUserProfile()
    func updateAppState(showTabBarView: Bool)
}
extension CoreInteractor: SettingsViewModelInteractor {}

@MainActor
protocol SettingsViewModelRouter {
    func showAlert(error: Error)
    func showAlert(type: CustomRouting.AlertType, title: String, subtitle: String?, buttons: (() -> AnyView)?)
    func dismissScreen()
    func showCreateAccountView(delegate: CreateAccountDelegate, onDisappear: @escaping () -> Void)
    func showRatingsModal(onEnjoyAppYesPressed: @escaping () -> Void, onEnjoyAppNoPressed: @escaping () -> Void)
    func dismissModal()
}
extension CoreRouter: SettingsViewModelRouter {}

@MainActor
@Observable
final class SettingsViewModel {
    private let interactor: SettingsViewModelInteractor
    private let router: SettingsViewModelRouter
    init(interactor: SettingsViewModelInteractor, router: SettingsViewModelRouter) {
        self.interactor = interactor
        self.router = router
    }

    private(set) var isPremium: Bool = false
    private(set) var isAnonymousUser: Bool = false

    var authUser: UserAuthInfoModel? {
        interactor.authUser
    }

    func setAnonymousAccountStatus() {
        isAnonymousUser = interactor.authUser?.isAnonymous == true
    }

    func onSignOutButtonPressed() {
        // do some logic to sign out of app!
        interactor.trackEvent(event: Event.signOutStart)
        Task {
            do {
                try await interactor.signOut()
                
                await dismissScreen()
                
                interactor.updateAppState(showTabBarView: false)
                interactor.trackEvent(event: Event.signOutSuccess)
            } catch {
                interactor.trackEvent(event: Event.signOutFail(error: error))
                router.showAlert(error: error)
            }
        }
    }
    
    private func dismissScreen() async {
        router.dismissScreen()
        try? await Task.sleep(for: .seconds(1))
    }

    func onDeleteAccountPressed() {
        interactor.trackEvent(event: Event.deleteAccountStart)
        router.showAlert(
            type: .alert,
            title: "Delete Account?",
            subtitle: "This action is permanent and cannot be undone. Your data will be deleted from our server forever.",
            buttons: {
            AnyView(
                Group {
                    Button("Delete", role: .destructive, action: {
                        self.onDeleteAccountConfirmed()
                    })
                }
            )
        })
    }

    func onDeleteAccountConfirmed() {
        interactor.trackEvent(event: Event.deleteAccountStartConfirm)
        Task {
            do {
                let uid = try interactor.getCurrentUserId()

                try await interactor.deleteAccount()
                try await interactor.deleteUser()
                try await interactor.removeAuthorIdFromAllUserAvatars(userId: uid)
                try await interactor.deleteAllChatsForUser(userId: uid)
                try await interactor.signOut()
                
                interactor.deleteUserProfile()
                interactor.trackEvent(event: Event.deleteAccountSuccess)
                
                await dismissScreen()
                
                interactor.updateAppState(showTabBarView: false)
            } catch {
                interactor.trackEvent(event: Event.deleteAccountFail(error: error))
                router.showAlert(error: error)
            }
        }
    }

    func onCreateAccountPressed() {
        interactor.trackEvent(event: Event.createAccountPressed)
        router.showCreateAccountView(
            delegate: CreateAccountDelegate(),
            onDisappear: {
                self.setAnonymousAccountStatus()
            }
        )
    }

    func onContactUsPressed() {
        interactor.trackEvent(event: Event.contactUsPressed)
        let email = "15021453094@163.com"
        let emailString = "mailto:\(email)"
        guard let url = URL(string: emailString), UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url)
    }

    func onRatingsButtonPressed() {
        interactor.trackEvent(event: Event.ratingPressed)
        router.showRatingsModal(onEnjoyAppYesPressed: {
            self.onEnjoyAppYesPressed()
        }, onEnjoyAppNoPressed: {
            self.onEnjoyAppNoPressed()
        })
    }

    func onEnjoyAppYesPressed() {
        interactor.trackEvent(event: Event.ratingYesPressed)
        router.dismissModal()
        AppStoreRatingsHelper.requestRatingsReview()
    }

    func onEnjoyAppNoPressed() {
        interactor.trackEvent(event: Event.ratingNoPressed)
        router.dismissModal()
    }
}

extension SettingsViewModel {
    enum Event: LoggableEvent {
        case signOutStart
        case signOutSuccess
        case signOutFail(error: Error)
        case deleteAccountStart
        case deleteAccountStartConfirm
        case deleteAccountSuccess
        case deleteAccountFail(error: Error)
        case createAccountPressed
        case contactUsPressed
        case ratingPressed
        case ratingYesPressed
        case ratingNoPressed
        var eventName: String {
            switch self {
            case .signOutStart: return "SettingsView_SignOut_Start"
            case .signOutSuccess: return "SettingsView_SignOut_Success"
            case .signOutFail: return "SettingsView_SignOut_Fail"
            case .deleteAccountStart: return "SettingsView_DeleteAccount_Start"
            case .deleteAccountStartConfirm: return "SettingsView_DeleteAccount_Start_Confirm"
            case .deleteAccountSuccess: return "SettingsView_DeleteAccount_Success"
            case .deleteAccountFail: return "SettingsView_DeleteAccount_Fail"
            case .createAccountPressed: return "SettingsView_CreateAccount_Pressed"
            case .contactUsPressed: return "SettingsView_ContactUs_Pressed"
            case .ratingPressed: return "SettingsView_RatingAppStore_Pressed"
            case .ratingYesPressed: return "SettingsView_RatingYes_Pressed"
            case .ratingNoPressed: return "SettingsView_RatingNo_Pressed"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .signOutFail(error: let error), .deleteAccountFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }

        var type: CustomLogType {
            switch self {
            case .signOutFail, .deleteAccountFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
}
