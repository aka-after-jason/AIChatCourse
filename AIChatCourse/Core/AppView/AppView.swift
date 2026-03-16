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
    @AppStorage("showTabbarView") var showTabBar: Bool = false
    var body: some View {
        AppViewBuilder(
            showTabBar: showTabBar,
            tabbarView: {
                TabBarView()
            },
            onboardingView: {
                WelcomeView()
            }
        )
        .onTapGesture {
            showTabBar.toggle()
        }
    }
}

#Preview("AppView Tabbar") {
    AppView(showTabBar: true)
}

#Preview("AppView Onboarding") {
    AppView(showTabBar: false)
}
