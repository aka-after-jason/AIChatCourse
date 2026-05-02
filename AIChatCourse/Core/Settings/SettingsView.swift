//
//  SettingsView.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/3/16.
//

import SwiftfulUtilities
import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    @Environment(AvatarManager.self) private var avatarManager
    @State private var isPremium: Bool = false
    @State private var isAnonymousUser: Bool = false
    @State private var showCreateAccountView: Bool = false
    @State private var showAlert: AnyAppAlertItem?
    var body: some View {
        NavigationStack {
            List {
                accountSection
                purchaseSection
                applicationSection
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showCreateAccountView, onDismiss: {
                setAnonymousAccountStatus()
            }, content: {
                CreateAccountView()
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
                .anyButton(.highlight) {}
                .removeListRowFormatting()

        }, header: {
            Text("Application")
        }, footer: {
            Text("Created by Swiftful Thinking.\nLearn more at www.swiftful-thinking.com.")
                .baselineOffset(6)
        })
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
        Task {
            do {
                try authManager.signOut()
                userManager.signOut()
                await dismissScreen()
            } catch {
                showAlert = AnyAppAlertItem(error: error)
            }
        }
    }
    
    private func onDeleteAccountPressed() {
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
        Task {
            do {
                let uid = try authManager.getCurrentUserId()
                /*
                try await authManager.deleteAccount()
                try await userManager.deleteUser()
                try await avatarManager.removeAuthorIdFromAllUserAvatars(userId: uid)
                 */
                
                // 使用 async let
                async let deleteAuth: () = authManager.deleteAccount()
                async let deleteUser: () = userManager.deleteUser()
                async let deleteAvatar: () = avatarManager.removeAuthorIdFromAllUserAvatars(userId: uid)
                let (_, _, _) = await (try deleteAuth, try deleteUser, try deleteAvatar)
                
                await dismissScreen()
            } catch {
                showAlert = AnyAppAlertItem(error: error)
            }
        }
    }
    
    private func dismissScreen() async {
        dismiss()
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        appState.updateViewState(showTabBarView: false)
    }

    private func onCreateAccountPressed() {
        showCreateAccountView.toggle()
    }
    
}

// MARK: Previews
#Preview("No auth") {
    SettingsView()
        .environment(AvatarManager(service: MockAvatarService()))
        .environment(AuthManager(service: MockAuthService(user: nil)))
        .environment(UserManager(services: MockUserServices(user: nil)))
        .environment(AppState())
}

#Preview("Anonymous") {
    SettingsView()
        .environment(AvatarManager(service: MockAvatarService()))
        .environment(AuthManager(service: MockAuthService(user: UserAuthInfoModel.mock(isAnonymous: true))))
        .environment(UserManager(services: MockUserServices(user: .mock)))
        .environment(AppState())
}

#Preview("Not anonymous") {
    SettingsView()
        .environment(AvatarManager(service: MockAvatarService()))
        .environment(AuthManager(service: MockAuthService(user: UserAuthInfoModel.mock(isAnonymous: false))))
        .environment(UserManager(services: MockUserServices(user: .mock)))
        .environment(AppState())
}
