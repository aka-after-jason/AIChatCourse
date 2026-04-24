//
//  ChatsView.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/3/16.
//

import SwiftUI

struct ChatsView: View {
    @State private var chats: [ChatModel] = ChatModel.mocks
    @State private var path: [NavigationPathOption] = []
    var body: some View {
        NavigationStack(path: $path) {
            List(chats, id: \.self) { chat in
                ChatRowCellViewBuilder(
                    currentUserId: nil,
                    chat: chat,
                    getAvatar: {
                        try? await Task.sleep(for: .seconds(1))
                        return AvatarModel.mocks.randomElement()!
                    },
                    getLastChatMessage: {
                        try? await Task.sleep(for: .seconds(1))
                        return ChatMessageModel.mocks.randomElement()!
                    }
                )
                .anyButton(.highlight, action: {
                    onChatPressed(chat: chat)
                })
                .removeListRowFormatting()
            }
            .navigationTitle("Chats")
            .customNavigationDestinationForCoreModule(path: $path)
        }
    }
}

#Preview {
    ChatsView()
}

// MARK: 事件
extension ChatsView {
    private func onChatPressed(chat: ChatModel) {
        path.append(.chatView(avatarId: chat.avatarId))
    }
}
