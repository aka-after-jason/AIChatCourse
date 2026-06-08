//
//  OnboardingIntroView.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/3/17.
//

import SwiftUI

struct OnboardingIntroDelete {
    var path: Binding<[NavOnboardingPathOption]>
}

struct OnboardingIntroView: View {
    @State var viewModel: OnboardingIntroViewModel
    let delegate: OnboardingIntroDelete
    var body: some View {
        VStack {
            Text(avatarsAndrealConversations())
                .frame(maxHeight: .infinity)

            Text("Continue")
                .callToActionButton()
                .anyButton(.press, action: {
                    viewModel.onContinueButtonPressed(path: delegate.path)
                })
                .accessibilityIdentifier("ContinueButton")
        }
        .toolbar(.hidden, for: .navigationBar)
        .padding(24)
        .appearAnalyticsViewModifier(name: "OnboardingIntroView")
    }

    /// 使用富文本的方式
    func avatarsAndrealConversations() -> AttributedString {
        var text = AttributedString("Make your own avatars and chat with them!\n\nHave real conversations with AI generated responses.")
        if let range1 = text.range(of: "avatars") {
            text[range1].foregroundColor = .accent
            text[range1].font = .boldSystemFont(ofSize: 16)
        }
        if let range2 = text.range(of: "real conversations") {
            text[range2].foregroundColor = .accent
            text[range2].font = .boldSystemFont(ofSize: 16)
        }
        return text
    }
}

#Preview("Original") {
    let builder = CoreBuilder(interactor: CoreInteractor(container: DevPreview.shared.container))
    let delegate = OnboardingIntroDelete(path: .constant([]))
    return NavigationStack {
        builder.onboardingIntroView(delegate: delegate)
    }
    .previewEnvironment()
}

#Preview("OnboardingCommunityTest") {
    let container = DevPreview.shared.container
    container.regiser(ABTestManager.self, manager: ABTestManager(service: MockABTestService(onboardingCommunityTest: true)))
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = OnboardingIntroDelete(path: .constant([]))
    return NavigationStack {
        builder.onboardingIntroView(delegate: delegate)
    }
    .previewEnvironment()
}
