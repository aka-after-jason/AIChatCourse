//
//  AppView.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/3/16.
//

import SwiftUI

// tabbar - signed in
// onboarding - signed out

struct AppView: View {
    // 由于使用了 @Observable, 这里需要使用 @State
    @State var appState: AppState = .init()
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    var body: some View {
        AppViewBuilder(
            showTabBar: appState.showTabBar,
            tabbarView: {
                TabBarView()
            },
            onboardingView: {
                WelcomeView()
            }
        )
        // 由于使用了 @Observable, 这里需要使用 environment,不是 environmentObject
        .environment(appState) // TabBarView 和 WelcomeView 都能访问
        // .environment(<#T##object: (Observable & AnyObject)?##(Observable & AnyObject)?#>) // 用于class, 且遵循了 @Observable
        // .environment(<#T##keyPath: WritableKeyPath<EnvironmentValues, V>##WritableKeyPath<EnvironmentValues, V>#>, <#T##value: V##V#>) // 用于struct
        .task {
            await checkUserStatus()
        }
        // 监听 appState 中的 showTabBar
        .onChange(of: appState.showTabBar) { _, showTabBar in
            if !showTabBar {
                Task { await checkUserStatus() }
            }
        }
    }
}

#Preview("AppView Tabbar") {
    AppView(appState: AppState(showTabBar: true))
}

#Preview("AppView Onboarding") {
    AppView(appState: AppState(showTabBar: false))
}

extension AppView {
    private func checkUserStatus() async {
        if let user = authManager.authUser {
            // user is authenticated
            print("User already authenticated: \(user.uid)")
            do {
                try await userManager.login(auth: user, isNewUser: false)
            } catch let error {
                print("Failed to log into auth for existing user: \(error)")
                try? await Task.sleep(for: .seconds(3))
                await checkUserStatus()
            }
        } else {
            // user is not authenticated
            do {
                let (user, isNewUser) = try await authManager.signInAnonymously()
                try await userManager.login(auth: user, isNewUser: isNewUser)
                print("Sign in anonymous success: \(user.uid) -- isNewUser:\(isNewUser.description)")
            } catch {
                print("Failed to signInAnonymously: \(error.localizedDescription)")
                try? await Task.sleep(for: .seconds(3))
                await checkUserStatus()
            }
        }
    }
}
