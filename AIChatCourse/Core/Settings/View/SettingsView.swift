//
//  SettingsView.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/3/16.
//
import SwiftfulUtilities
import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State var viewModel: SettingsViewModel
    @ViewBuilder var createAccountView: () -> AnyView

    var body: some View {
        NavigationStack {
            List {
                accountSection
                purchaseSection
                applicationSection
            }
            .navigationTitle("Settings")
            .appearAnalyticsViewModifier(name: "SettingsView")
            .showModal(showModal: $viewModel.showRatingsModal, content: {
                ratingsModal
            })
            .sheet(isPresented: $viewModel.showCreateAccountView, onDismiss: {
                viewModel.setAnonymousAccountStatus()
            }, content: {
                createAccountView()
                    .presentationDetents([.medium])
            })
            .showCustomAlert(alertItem: $viewModel.showAlert)
            .onAppear {
                viewModel.setAnonymousAccountStatus()
            }
        }
    }

    func dismissScreen() async {
        dismiss()
        try? await Task.sleep(nanoseconds: 1_000_000_000)
    }
}

// MARK: 抽取属性

extension SettingsView {
    private var accountSection: some View {
        Section(content: {
            if viewModel.isAnonymousUser {
                Text("Save & back-up account")
                    .rowFormatting()
                    .anyButton(.highlight, action: {
                        viewModel.onCreateAccountPressed()
                    })
                    .removeListRowFormatting()
            } else {
                Text("Sign out")
                    .rowFormatting()
                    .anyButton(.highlight, action: {
                        viewModel.onSignOutButtonPressed(onDismiss: {
                            await dismissScreen()
                        })
                    })
                    .removeListRowFormatting()
            }

            Text("Delete Account")
                .foregroundStyle(.red)
                .rowFormatting()
                .anyButton(.highlight, action: {
                    viewModel.onDeleteAccountPressed(onDismiss: {
                        await dismissScreen()
                    })
                })
                .removeListRowFormatting()
        }, header: {
            Text("Account")
        })
    }

    private var purchaseSection: some View {
        Section(content: {
            HStack(spacing: 8) {
                Text("Account status: \(viewModel.isPremium ? "PREMIUM" : "FREE")")
                Spacer()
                if viewModel.isPremium {
                    Text("MANAGE")
                        .badgeButton()
                }
            }
            .rowFormatting()
            .anyButton(.highlight, action: {})
            .removeListRowFormatting()
            .disabled(!viewModel.isPremium)
        }, header: {
            Text("Purchases")
        })
    }

    private var applicationSection: some View {
        Section(content: {
            Text("Rete us on the AppStore!")
                .foregroundStyle(.blue)
                .rowFormatting()
                .anyButton(.highlight, action: { viewModel.onRatingsButtonPressed() })
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
                .anyButton(.highlight) { viewModel.onContactUsPressed() }
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
            primaryButtonAction: { viewModel.onEnjoyAppYesPressed() },
            secondaryButtonTitle: "No",
            secondaryButtonAction: { viewModel.onEnjoyAppNoPressed() }
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

// MARK: Previews

#Preview("No auth") {
    let container = DevPreview.shared.container
    container.regiser(AvatarManager.self, manager: AvatarManager(service: MockAvatarService()))
    container.regiser(AuthManager.self, manager: AuthManager(service: MockAuthService(user: nil)))
    container.regiser(UserManager.self, manager: UserManager(services: MockUserServices(user: nil)))
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    return builder.settingsView()
        .previewEnvironment()
}

#Preview("Anonymous") {
    let container = DevPreview.shared.container
    container.regiser(AvatarManager.self, manager: AvatarManager(service: MockAvatarService()))
    container.regiser(AuthManager.self, manager: AuthManager(service: MockAuthService(user: UserAuthInfoModel.mock(isAnonymous: true))))
    container.regiser(UserManager.self, manager: UserManager(services: MockUserServices(user: .mock)))
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    return builder.settingsView()
        .previewEnvironment()
}

#Preview("Not anonymous") {
    let container = DevPreview.shared.container
    container.regiser(AvatarManager.self, manager: AvatarManager(service: MockAvatarService()))
    container.regiser(AuthManager.self, manager: AuthManager(service: MockAuthService(user: UserAuthInfoModel.mock(isAnonymous: false))))
    container.regiser(UserManager.self, manager: UserManager(services: MockUserServices(user: .mock)))
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    return builder.settingsView()
        .previewEnvironment()
}
