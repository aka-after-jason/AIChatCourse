//
//  OnboardingCompletedView.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/3/16.
//

import SwiftUI

struct OnboardingCompletedView: View {
    @Environment(AppState.self) private var appState
    @Environment(UserManager.self) private var userManager
    var selectedColor: Color = .orange // 保存 OnboardingColorView 中选择的颜色
    @State private var isCompletingProfileSetup: Bool = false
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Setup complete!")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundStyle(selectedColor)

            Text("We've set up your profile and you're ready to start chatting.")
                .font(.title)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
        }
        .frame(maxHeight: .infinity)
        .safeAreaInset(edge: .bottom, content: {
            ctaButton
        })
        .toolbar(.hidden, for: .navigationBar)
        .padding(24)
    }

    private var ctaButton: some View {
        AsyncCallToActionButton(
            isLoading: isCompletingProfileSetup,
            title: "Finish",
            action: onFinishButtonPressed
        )
    }

    func onFinishButtonPressed() {
        // other logic to complete onboarding
        isCompletingProfileSetup = true
        Task {
            let hex = selectedColor.asHex()
            try await userManager.markOnboardingCompleteForCurrentUser(profileColorHex: hex)

            // dismiss screen
            isCompletingProfileSetup = false
            appState.updateViewState(showTabBarView: true)
        }
    }
}

#Preview {
    OnboardingCompletedView(selectedColor: .mint)
        .environment(UserManager(service: MockUserService()))
        .environment(AppState())
}
