//
//  SettingsView.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/3/16.
//

import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) var appState
    var body: some View {
        NavigationStack {
            List {
                Button {
                    onSignOutButtonPressed()
                } label: {
                    Text("Sign out")
                }
            }
            .navigationTitle("Settings")
        }
    }
    
    private func onSignOutButtonPressed() {
        // do some logic to sign out of app!
        appState.updateViewState(showTabBarView: false)
    }
}

#Preview {
    SettingsView()
        .environment(AppState())
}
