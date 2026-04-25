//
//  OnboardingCompletedView.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/3/16.
//

import SwiftUI

struct OnboardingCompletedView: View {
    @Environment(AppState.self) private var appState
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
            try await Task.sleep(for: .seconds(1))
            isCompletingProfileSetup = false
            appState.updateViewState(showTabBarView: true)
        }
    }
}

#Preview {
    NavigationStack {
        OnboardingCompletedView(selectedColor: .mint)
    }
    .environment(AppState())
}
