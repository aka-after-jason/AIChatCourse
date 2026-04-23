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
    @State var appState: AppState = AppState()
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
    }
}

#Preview("AppView Tabbar") {
    AppView(appState: AppState(showTabBar: true))
}

#Preview("AppView Onboarding") {
    AppView(appState: AppState(showTabBar: false))
}
