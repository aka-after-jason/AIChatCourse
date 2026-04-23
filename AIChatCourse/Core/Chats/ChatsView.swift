//
//  ChatsView.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/3/16.
//

import SwiftUI

struct ChatsView: View {
    @State private var chats: [ChatModel] = ChatModel.mocks
    @State private var isnavigation: Bool = false
    var body: some View {
        NavigationStack {
            List(chats, id: \.self) { chat in
                ChatRowCellViewBuilder(
                    currentUserId: nil,
                    chat: chat,
                    getAvatar: {
                        try? await Task.sleep(for: .seconds(2))
                        return AvatarModel.mock
                    },
                    getLastChatMessage: {
                        try? await Task.sleep(for: .seconds(2))
                        return ChatMessageModel.mock
                    }
                )
                .anyButton(.highlight, action: {
                    isnavigation = true
                })
                .removeListRowFormatting()
            }
            .navigationTitle("Chats")
            .navigationDestination(isPresented: $isnavigation) {
                ChatView()
            }
        }
    }
}

#Preview {
    ChatsView()
}
