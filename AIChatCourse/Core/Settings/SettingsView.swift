//
//  SettingsView.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/3/16.
//

import SwiftfulUtilities
import SwiftUI

struct SettingsView: View {
    @Environment(DependencyContainer.self) private var container
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    @Environment(AvatarManager.self) private var avatarManager
    @Environment(ChatManager.self) private var chatManager
    @Environment(LogManager.self) private var logManager
    @Environment(PurchaseManager.self) private var purchaseManager
    @State private var isPremium: Bool = false
    @State private var isAnonymousUser: Bool = false
    @State private var showCreateAccountView: Bool = false
    @State private var showAlert: AnyAppAlertItem?
    @State private var showRatingsModal: Bool = false
    var body: some View {
        NavigationStack {
            List {
                accountSection
                purchaseSection
                applicationSection
            }
            .navigationTitle("Settings")
            .appearAnalyticsViewModifier(name: "SettingsView")
            .showModal(showModal: $showRatingsModal, content: {
                ratingsModal
            })
            .sheet(isPresented: $showCreateAccountView, onDismiss: {
                setAnonymousAccountStatus()
            }, content: {
                CreateAccountView(viewModel: CreateAccountViewModel(interactor: CoreInteractor(container: container)))
                    .presentationDetents([.medium])
            })
            .showCustomAlert(alertItem: $showAlert)
            .onAppear {
                setAnonymousAccountStatus()
            }
        }
    }
}

// MARK: 抽取属性

extension SettingsView {
    private var accountSection: some View {
        Section(content: {
            if isAnonymousUser {
                Text("Save & back-up account")
                    .rowFormatting()
                    .anyButton(.highlight, action: {
                        onCreateAccountPressed()
                    })
                    .removeListRowFormatting()
            } else {
                Text("Sign out")
                    .rowFormatting()
                    .anyButton(.highlight, action: {
                        onSignOutButtonPressed()
                    })
                    .removeListRowFormatting()
            }

            Text("Delete Account")
                .foregroundStyle(.red)
                .rowFormatting()
                .anyButton(.highlight, action: {
                    onDeleteAccountPressed()
                })
                .removeListRowFormatting()
        }, header: {
            Text("Account")
        })
    }

    private var purchaseSection: some View {
        Section(content: {
            HStack(spacing: 8) {
                Text("Account status: \(isPremium ? "PREMIUM" : "FREE")")
                Spacer()
                if isPremium {
                    Text("MANAGE")
                        .badgeButton()
                }
            }
            .rowFormatting()
            .anyButton(.highlight, action: {})
            .removeListRowFormatting()
            .disabled(!isPremium)
        }, header: {
            Text("Purchases")
        })
    }

    private var applicationSection: some View {
        Section(content: {
            Text("Rete us on the AppStore!")
                .foregroundStyle(.blue)
                .rowFormatting()
                .anyButton(.highlight, action: { onRatingsButtonPressed() })
                .removeListRowFormatting()

            HStack(spacing: 8) {
                Text("Version")
                Spacer()
                Text(Utilities.appVersion ?? "")
                    .foregroundStyle(.secondary)
            }
            .rowFormatting()
            .removeListRowFormatting()

            HStack(spacing: 8) {
                Text("Build Number")
                Spacer()
                Text(Utilities.buildNumber ?? "")
                    .foregroundStyle(.secondary)
            }
            .rowFormatting()
            .removeListRowFormatting()

            Text("Contact us")
                .foregroundStyle(.blue)
                .rowFormatting()
                .anyButton(.highlight) { onContactUsPressed() }
                .removeListRowFormatting()

        }, header: {
            Text("Application")
        }, footer: {
            Text("Created by Swiftful Thinking.\nLearn more at www.swiftful-thinking.com.")
                .baselineOffset(6)
        })
    }

    private var ratingsModal: some View {
        CustomModalView(
            title: "Are you enjoying AIChat?",
            subtitle: "We'd love to hear your feedback!",
            primaryButtonTitle: "Yes",
            primaryButtonAction: { onEnjoyAppYesPressed() },
            secondaryButtonTitle: "No",
            secondaryButtonAction: { onEnjoyAppNoPressed() }
        )
    }
}

private extension View {
    func rowFormatting() -> some View {
        padding(.vertical, 12)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(uiColor: .systemBackground))
    }
}

// MARK: 事件

extension SettingsView {
    private func setAnonymousAccountStatus() {
        isAnonymousUser = authManager.authUser?.isAnonymous == true
    }

    private func onSignOutButtonPressed() {
        // do some logic to sign out of app!
        logManager.trackEvent(event: Event.signOutStart)
        Task {
            do {
                try authManager.signOut()
                try await purchaseManager.logOut()
                userManager.signOut()
                await dismissScreen()
                logManager.trackEvent(event: Event.signOutSuccess)
            } catch {
                showAlert = AnyAppAlertItem(error: error)
                logManager.trackEvent(event: Event.signOutFail(error: error))
            }
        }
    }

    private func onDeleteAccountPressed() {
        logManager.trackEvent(event: Event.deleteAccountStart)
        showAlert = AnyAppAlertItem(
            title: "Delete Account?",
            subtitle: "This action is permanent and cannot be undone. Your data will be deleted from our server forever.",
            buttons: {
                AnyView(
                    Group {
                        Button("Delete", role: .destructive, action: {
                            onDeleteAccountConfirmed()
                        })
                    }
                )
            }
        )
    }

    private func onDeleteAccountConfirmed() {
        logManager.trackEvent(event: Event.deleteAccountStartConfirm)
        Task {
            do {
                let uid = try authManager.getCurrentUserId()

                try await authManager.deleteAccount()
                try await userManager.deleteUser()
                try await avatarManager.removeAuthorIdFromAllUserAvatars(userId: uid)
                try await chatManager.deleteAllChatsForUser(userId: uid)
                try await purchaseManager.logOut()

                // 使用 async let
//                async let deleteAuth: () = authManager.deleteAccount()
//                async let deleteUser: () = userManager.deleteUser()
//                async let deleteAvatar: () = avatarManager.removeAuthorIdFromAllUserAvatars(userId: uid)
//                async let deleteChats: () = chatManager.deleteAllChatsForUser(userId: uid)
//                let (_, _, _, _) = try await (deleteAuth, deleteUser, deleteAvatar, deleteChats)
                logManager.deleteUserProfile()
                logManager.trackEvent(event: Event.deleteAccountSuccess)
                await dismissScreen()
            } catch {
                showAlert = AnyAppAlertItem(error: error)
                logManager.trackEvent(event: Event.deleteAccountFail(error: error))
            }
        }
    }

    private func dismissScreen() async {
        dismiss()
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        appState.updateViewState(showTabBarView: false)
    }

    private func onCreateAccountPressed() {
        logManager.trackEvent(event: Event.createAccountPressed)
        showCreateAccountView.toggle()
    }

    private func onContactUsPressed() {
        logManager.trackEvent(event: Event.contactUsPressed)
        let email = "15021453094@163.com"
        let emailString = "mailto:\(email)"
        guard let url = URL(string: emailString), UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url)
    }

    private func onRatingsButtonPressed() {
        logManager.trackEvent(event: Event.ratingPressed)
        showRatingsModal = true
    }

    private func onEnjoyAppYesPressed() {
        logManager.trackEvent(event: Event.ratingYesPressed)
        showRatingsModal = false
        AppStoreRatingsHelper.requestRatingsReview()
    }

    private func onEnjoyAppNoPressed() {
        logManager.trackEvent(event: Event.ratingNoPressed)
        showRatingsModal = false
    }
}

extension SettingsView {
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

// MARK: Previews

#Preview("No auth") {
    SettingsView()
        .environment(AvatarManager(service: MockAvatarService()))
        .environment(AuthManager(service: MockAuthService(user: nil)))
        .environment(UserManager(services: MockUserServices(user: nil)))
        .previewEnvironment()
}

#Preview("Anonymous") {
    SettingsView()
        .environment(AvatarManager(service: MockAvatarService()))
        .environment(AuthManager(service: MockAuthService(user: UserAuthInfoModel.mock(isAnonymous: true))))
        .environment(UserManager(services: MockUserServices(user: .mock)))
        .previewEnvironment()
}

#Preview("Not anonymous") {
    SettingsView()
        .environment(AvatarManager(service: MockAvatarService()))
        .environment(AuthManager(service: MockAuthService(user: UserAuthInfoModel.mock(isAnonymous: false))))
        .environment(UserManager(services: MockUserServices(user: .mock)))
        .previewEnvironment()
}
