//
//  SettingsView.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/3/16.
//

import SwiftUI
import SwiftfulUtilities

struct SettingsView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var isPremium: Bool = false
    @State private var isAnonymousUser: Bool = false
    @State private var showCreateAccountView: Bool = false
    var body: some View {
        NavigationStack {
            List {
                accountSection
                purchaseSection
                applicationSection
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showCreateAccountView) {
                CreateAccountView()
                    .presentationDetents([.medium])
            }
        }
    }

    private func onSignOutButtonPressed() {
        // do some logic to sign out of app!
        dismiss()
        Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            appState.updateViewState(showTabBarView: false)
        }
    }
    
    private func onCreateAccountPressed() {
        showCreateAccountView.toggle()
    }

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
                .anyButton(.highlight, action: {})
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

#Preview {
    SettingsView()
        .environment(AppState())
}

private extension View {
    func rowFormatting() -> some View {
        padding(.vertical, 12)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(uiColor: .systemBackground))
    }
}
