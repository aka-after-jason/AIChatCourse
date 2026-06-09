//
//  SettingsViewModel.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/6/7.
//
import SwiftUI

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
@Observable
final class SettingsViewModel {
    private let interactor: SettingsViewModelInteractor
    init(interactor: SettingsViewModelInteractor) {
        self.interactor = interactor
    }

    private(set) var isPremium: Bool = false
    private(set) var isAnonymousUser: Bool = false
    var showCreateAccountView: Bool = false
    var showAlert: AnyAppAlertItem?
    var showRatingsModal: Bool = false

    var authUser: UserAuthInfoModel? {
        interactor.authUser
    }

    func setAnonymousAccountStatus() {
        isAnonymousUser = interactor.authUser?.isAnonymous == true
    }

    func onSignOutButtonPressed(onDismiss: @escaping () async -> Void) {
        // do some logic to sign out of app!
        interactor.trackEvent(event: Event.signOutStart)
        Task {
            do {
                try await interactor.signOut()
                await onDismiss()
                interactor.updateAppState(showTabBarView: false)
                interactor.trackEvent(event: Event.signOutSuccess)
            } catch {
                showAlert = AnyAppAlertItem(error: error)
                interactor.trackEvent(event: Event.signOutFail(error: error))
            }
        }
    }

    func onDeleteAccountPressed(onDismiss: @escaping () async -> Void) {
        interactor.trackEvent(event: Event.deleteAccountStart)
        showAlert = AnyAppAlertItem(
            title: "Delete Account?",
            subtitle: "This action is permanent and cannot be undone. Your data will be deleted from our server forever.",
            buttons: {
                AnyView(
                    Group {
                        Button("Delete", role: .destructive, action: {
                            self.onDeleteAccountConfirmed(onDismiss: onDismiss)
                        })
                    }
                )
            }
        )
    }

    func onDeleteAccountConfirmed(onDismiss: @escaping () async -> Void) {
        interactor.trackEvent(event: Event.deleteAccountStartConfirm)
        Task {
            do {
                let uid = try interactor.getCurrentUserId()

                try await interactor.deleteAccount()
                try await interactor.deleteUser()
                try await interactor.removeAuthorIdFromAllUserAvatars(userId: uid)
                try await interactor.deleteAllChatsForUser(userId: uid)
                try await interactor.signOut()

                // 使用 async let
//                async let deleteAuth: () = authManager.deleteAccount()
//                async let deleteUser: () = userManager.deleteUser()
//                async let deleteAvatar: () = avatarManager.removeAuthorIdFromAllUserAvatars(userId: uid)
//                async let deleteChats: () = chatManager.deleteAllChatsForUser(userId: uid)
//                let (_, _, _, _) = try await (deleteAuth, deleteUser, deleteAvatar, deleteChats)
                interactor.deleteUserProfile()
                interactor.trackEvent(event: Event.deleteAccountSuccess)
                await onDismiss()
                interactor.updateAppState(showTabBarView: false)
            } catch {
                showAlert = AnyAppAlertItem(error: error)
                interactor.trackEvent(event: Event.deleteAccountFail(error: error))
            }
        }
    }

    func onCreateAccountPressed() {
        interactor.trackEvent(event: Event.createAccountPressed)
        showCreateAccountView.toggle()
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
        showRatingsModal = true
    }

    func onEnjoyAppYesPressed() {
        interactor.trackEvent(event: Event.ratingYesPressed)
        showRatingsModal = false
        AppStoreRatingsHelper.requestRatingsReview()
    }

    func onEnjoyAppNoPressed() {
        interactor.trackEvent(event: Event.ratingNoPressed)
        showRatingsModal = false
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
