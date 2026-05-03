//
//  ChatMessageModel.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/3/21.
//

import Foundation

struct ChatMessageModel: Identifiable {
    let id: String
    let chatId: String
    let authorId: String?
    let content: AIChatModel?
    let seenByIds: [String]?
    let dateCreated: Date?

    init(
        id: String,
        chatId: String,
        authorId: String? = nil,
        content: AIChatModel? = nil,
        seenByIds: [String]? = nil,
        dateCreated: Date? = nil
    ) {
        self.id = id
        self.chatId = chatId
        self.authorId = authorId
        self.content = content
        self.seenByIds = seenByIds
        self.dateCreated = dateCreated
    }
    
    func hasBeenSeenBy(userId: String) -> Bool {
        guard let seenByIds else {return false}
        return seenByIds.contains(userId)
    }

    static var mock: ChatMessageModel {
        mocks[0]
    }

    static var mocks: [ChatMessageModel] {
        let now = Date()
        return [
            ChatMessageModel(
                id: "msg1",
                chatId: "1",
                authorId: "user1",
                content: AIChatModel(role: .user, message: "Hello, how are you?"),
                seenByIds: ["user1", "user2"],
                dateCreated: now
            ),
            ChatMessageModel(
                id: "msg2",
                chatId: "2",
                authorId: "user2",
                content: AIChatModel(role: .assistant, message: "Im doing well, thanks for asking!"),
                seenByIds: ["user1"],
                dateCreated: now.addingTimeInterval(minutes: -5)
            ),
            ChatMessageModel(
                id: "msg3",
                chatId: "3",
                authorId: "user3",
                content: AIChatModel(role: .user, message: "Anyone up for a game tonight?"),
                seenByIds: ["user1", "user2", "user4"],
                dateCreated: now.addingTimeInterval(hours: -1)
            ),
            ChatMessageModel(
                id: "msg4",
                chatId: "4",
                authorId: "user4",
                content: AIChatModel(role: .assistant, message: "Sure, count me in!"),
                seenByIds: ["user1", "user2"],
                dateCreated: now.addingTimeInterval(hours: -2, minutes: -15)
            )
        ]
    }
}
