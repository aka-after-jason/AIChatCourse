//
//  OnboardingCommunityView.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/5/20.
//

import SwiftUI

struct OnboardingCommunityDelete {
    var path: Binding<[NavOnboardingPathOption]>
}

struct OnboardingCommunityView: View {
    @State var viewModel: OnboardingCommunityViewModel
    let delegate: OnboardingCommunityDelete
    var body: some View {
        VStack {
            VStack(spacing: 30) {
                ImageLoaderView()
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())

                Text(avatarsAndrealConversations())
            }
            .frame(maxHeight: .infinity)

            Text("Continue")
                .callToActionButton()
                .anyButton(.press, action: {
                    viewModel.onContinueButtonPressed(path: delegate.path)
                })
        }
        .toolbar(.hidden, for: .navigationBar)
        .padding(24)
        .appearAnalyticsViewModifier(name: "OnboardingIntroView")
    }

    /// 使用富文本的方式
    func avatarsAndrealConversations() -> AttributedString {
        var text = AttributedString("Join our community with over 1000+ custom avatars.\n\nHave real conversations with AI generated responses.")
        if let range1 = text.range(of: "1000+") {
            text[range1].foregroundColor = .accent
            text[range1].font = .boldSystemFont(ofSize: 18)
        }
        return text
    }
}

#Preview {
    let builder = CoreBuilder(interactor: CoreInteractor(container: DevPreview.shared.container))
    return NavigationStack {
        builder.onboardingCommunityView(delegate: OnboardingCommunityDelete(path: .constant([])))
    }
    .previewEnvironment()
}
