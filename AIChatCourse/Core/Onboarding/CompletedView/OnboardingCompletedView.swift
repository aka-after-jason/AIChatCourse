//
//  OnboardingCompletedView.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/3/16.
//

import SwiftUI

struct OnboardingCompletedDelete {
    var selectedColor: Color = .orange // 保存 OnboardingColorView 中选择的颜色
}

struct OnboardingCompletedView: View {
    @State var presenter: OnboardingCompletedPresenter
    var delegate: OnboardingCompletedDelete = OnboardingCompletedDelete()
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Setup complete!")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundStyle(delegate.selectedColor)

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
    }

    private var ctaButton: some View {
        AsyncCallToActionButton(
            isLoading: presenter.isCompletingProfileSetup,
            title: "Finish",
            action: {
                presenter.onFinishButtonPressed(selectedColor: delegate.selectedColor)
            }
        )
    }
}

#Preview {
    let container = DevPreview.shared.container
    container.regiser(UserManager.self, manager: UserManager(services: MockUserServices()))
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    return RouterView { router in
        builder.onboardingCompletedView(router: router, delegate: OnboardingCompletedDelete(selectedColor: .mint))
        .previewEnvironment()
    }
}
