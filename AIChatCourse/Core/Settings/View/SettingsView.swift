//
//  SettingsView.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/3/16.
//
import SwiftUI

struct SettingsView: View {
    @State var presenter: SettingsPresenter

    var body: some View {
        List {
            accountSection
            purchaseSection
            applicationSection
        }
        .navigationTitle("Settings")
        .appearAnalyticsViewModifier(name: "SettingsView")
        .onAppear {
            presenter.setAnonymousAccountStatus()
        }
    }
}

// MARK: 抽取属性

extension SettingsView {
    private var accountSection: some View {
        Section(content: {
            if presenter.isAnonymousUser {
                Text("Save & back-up account")
                    .rowFormatting()
                    .anyButton(.highlight, action: {
                        presenter.onCreateAccountPressed()
                    })
                    .removeListRowFormatting()
            } else {
                Text("Sign out")
                    .rowFormatting()
                    .anyButton(.highlight, action: {
                        presenter.onSignOutButtonPressed()
                    })
                    .removeListRowFormatting()
            }

            Text("Delete Account")
                .foregroundStyle(.red)
                .rowFormatting()
                .anyButton(.highlight, action: {
                    presenter.onDeleteAccountPressed()
                })
                .removeListRowFormatting()
        }, header: {
            Text("Account")
        })
    }

    private var purchaseSection: some View {
        Section(content: {
            HStack(spacing: 8) {
                Text("Account status: \(presenter.isPremium ? "PREMIUM" : "FREE")")
                Spacer()
                if presenter.isPremium {
                    Text("MANAGE")
                        .badgeButton()
                }
            }
            .rowFormatting()
            .anyButton(.highlight, action: {})
            .removeListRowFormatting()
            .disabled(!presenter.isPremium)
        }, header: {
            Text("Purchases")
        })
    }

    private var applicationSection: some View {
        Section(content: {
            Text("Rete us on the AppStore!")
                .foregroundStyle(.blue)
                .rowFormatting()
                .anyButton(.highlight, action: { presenter.onRatingsButtonPressed() })
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
                .anyButton(.highlight) { presenter.onContactUsPressed() }
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
            primaryButtonAction: { presenter.onEnjoyAppYesPressed() },
            secondaryButtonTitle: "No",
            secondaryButtonAction: { presenter.onEnjoyAppNoPressed() }
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
    return RouterView { router in
        builder.settingsView(router: router)
            .previewEnvironment()
    }
}

#Preview("Anonymous") {
    let container = DevPreview.shared.container
    container.regiser(AvatarManager.self, manager: AvatarManager(service: MockAvatarService()))
    container.regiser(AuthManager.self, manager: AuthManager(service: MockAuthService(user: UserAuthInfoModel.mock(isAnonymous: true))))
    container.regiser(UserManager.self, manager: UserManager(services: MockUserServices(user: .mock)))
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    return RouterView { router in
        builder.settingsView(router: router)
            .previewEnvironment()
    }
}

#Preview("Not anonymous") {
    let container = DevPreview.shared.container
    container.regiser(AvatarManager.self, manager: AvatarManager(service: MockAvatarService()))
    container.regiser(AuthManager.self, manager: AuthManager(service: MockAuthService(user: UserAuthInfoModel.mock(isAnonymous: false))))
    container.regiser(UserManager.self, manager: UserManager(services: MockUserServices(user: .mock)))
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    return RouterView { router in
        builder.settingsView(router: router)
            .previewEnvironment()
    }
}
