//
//  ChatRowCellViewBuilder.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/3/21.
//

import SwiftUI

struct ChatRowCellViewBuilder: View {
    var currentUserId: String? = ""
    var chat: ChatModel = .mock
    @State private var avatar: AvatarModel?
    @State private var lastChatMessage: ChatMessageModel?
    var getAvatar: () async -> AvatarModel? // 定义一个异步函数 getAvatar() -> AvatarModel
    var getLastChatMessage: () async -> ChatMessageModel?
    
    @State private var didLoadAvatar: Bool = false
    @State private var didLoadChatMessage: Bool = false
    
    var body: some View {
        ChatRowCellView(
            imageName: avatar?.profileImageName,
            headline: isLoading ? "xxx xxx" : avatar?.name,
            subheadline: subheadline,
            hasNewChat: isLoading ? false : hasNewChat
        )
        .redacted(reason: isLoading ? .placeholder : [])
        .task {
            // get the avatar
            avatar = await getAvatar()
            didLoadAvatar = true
        }
        .task {
            // get last chat message
            lastChatMessage = await getLastChatMessage()
            didLoadChatMessage = true
        }
    }
    
    private var subheadline: String? {
        if isLoading {
            return "xxxx xxxx xxxx"
        }
        if avatar == nil && lastChatMessage == nil {
            return "Error loading..."
        }
        return lastChatMessage?.content?.message
    }
    
    private var isLoading: Bool {
        if didLoadAvatar && didLoadChatMessage {
            return false
        }
        return true
    }
    
    private var hasNewChat: Bool {
        guard let lastChatMessage, let currentUserId else { return false }
        return !lastChatMessage.hasBeenSeenBy(userId: currentUserId)
    }
}

#Preview {
    VStack {
        ChatRowCellViewBuilder(chat: ChatModel.mock, getAvatar: {
            try? await Task.sleep(for: .seconds(5))
            return AvatarModel.mock
        }, getLastChatMessage: {
            ChatMessageModel.mock
        })
        
        ChatRowCellViewBuilder(chat: ChatModel.mock, getAvatar: {
            AvatarModel.mock
        }, getLastChatMessage: {
            ChatMessageModel.mock
        })
        
        ChatRowCellViewBuilder(chat: ChatModel.mock, getAvatar: {
            nil
        }, getLastChatMessage: {
            nil
        })
    }
}
