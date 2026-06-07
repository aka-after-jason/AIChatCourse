//
//  OnboardingCompletedView.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/3/16.
//

import SwiftUI

struct OnboardingCompletedView: View {
    @State var viewModel: OnboardingCompletedViewModel
    @Environment(AppState.self) private var appState
    var selectedColor: Color = .orange // 保存 OnboardingColorView 中选择的颜色

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
        .appearAnalyticsViewModifier(name: "OnboardingCompletedView")
        .showCustomAlert(alertItem: $viewModel.showAlert)
    }

    private var ctaButton: some View {
        AsyncCallToActionButton(
            isLoading: viewModel.isCompletingProfileSetup,
            title: "Finish",
            action: {
                viewModel.onFinishButtonPressed(selectedColor: selectedColor, onUpdateViewState: {
                    appState.updateViewState(showTabBarView: true)
                })
            }
        )
    }
}

#Preview {
    let container = DevPreview.shared.container
    container.regiser(UserManager.self, manager: UserManager(services: MockUserServices()))
    return OnboardingCompletedView(
        viewModel: OnboardingCompletedViewModel(interactor: CoreInteractor(container: container)),
        selectedColor: .mint
    )
    .previewEnvironment()
}
