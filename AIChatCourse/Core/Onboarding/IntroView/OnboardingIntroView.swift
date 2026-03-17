//
//  OnboardingIntroView.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/3/17.
//

import SwiftUI

struct OnboardingIntroView: View {
    var body: some View {
        VStack {
            Text(avatarsAndrealConversations())
                .frame(maxHeight: .infinity)

            NavigationLink {
                OnboardingColorView()
            } label: {
                Text("Continue")
                    .callToActionButton()
            }
        }
        .padding(24)
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

#Preview {
    NavigationStack {
        OnboardingIntroView()
    }
}
