//
//  ChatBubbleViewBuilder.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/3/22.
//

import SwiftUI

struct ChatBubbleViewBuilder: View {
    var message: ChatMessageModel = .mock
    var isCurrentUser: Bool = false
    var imageName: String?
    var onImagePressed: (() -> Void)?
    var body: some View {
        ZStack {
            ChatBubbleView(
                text: message.content ?? "",
                textColor: isCurrentUser ? .white : .primary,
                backgroundColor: isCurrentUser ? .accent : Color(uiColor: .systemGray6),
                imageName: imageName,
                showImage: !isCurrentUser,
                onImagePressed: onImagePressed
            )
            .frame(maxWidth: .infinity, alignment: isCurrentUser ? .trailing : .leading)
        }
        .padding(.leading, isCurrentUser ? 75 : 0)
        .padding(.trailing, isCurrentUser ? 0 : 75)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 24) {
            ChatBubbleViewBuilder()
            ChatBubbleViewBuilder(isCurrentUser: true)
            ChatBubbleViewBuilder(
                message: ChatMessageModel(
                    id: UUID().uuidString,
                    chatId: UUID().uuidString,
                    authorId: UUID().uuidString,
                    content: "ChatBubbleViewBuilder()ChatBubbleViewBuilder()ChatBubbleViewBuilder()ChatBubbleViewBuilder()ChatBubbleViewBuilder()ChatBubbleViewBuilder()ChatBubbleViewBuilder()ChatBubbleViewBuilder()",
                    seenByIds: nil,
                    dateCreated: .now
                ),
                isCurrentUser: true
            )
            ChatBubbleViewBuilder(
                message: ChatMessageModel(
                    id: UUID().uuidString,
                    chatId: UUID().uuidString,
                    authorId: UUID().uuidString,
                    content: "ChatBubbleViewBuilder()ChatBubbleViewBuilder()ChatBubbleViewBuilder()ChatBubbleViewBuilder()ChatBubbleViewBuilder()ChatBubbleViewBuilder()ChatBubbleViewBuilder()ChatBubbleViewBuilder()",
                    seenByIds: nil,
                    dateCreated: .now
                ),
                isCurrentUser: false
            )
        }
        .padding(12)
    }
}
