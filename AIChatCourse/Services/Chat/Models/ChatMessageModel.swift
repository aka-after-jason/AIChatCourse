//
//  ChatMessageModel.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/3/21.
//

import Foundation

struct ChatMessageModel: Identifiable, Codable {
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
    
    var dateCreatedCalculated: Date {
        dateCreated ?? .distantPast
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case chatId = "chat_id"
        case authorId = "author_id"
        case content = "content"
        case seenByIds = "seen_by_ids"
        case dateCreated = "date_created"
    }
    
    func hasBeenSeenBy(userId: String) -> Bool {
        guard let seenByIds else {return false}
        return seenByIds.contains(userId)
    }
    
    /// 用户发送的消息封装到这里
    static func newUserMessage(chatId: String, userId: String, message: AIChatModel) -> ChatMessageModel {
        ChatMessageModel(
            id: UUID().uuidString,
            chatId: chatId,
            authorId: userId,
            content: message,
            seenByIds: [userId],
            dateCreated: .now
        )
    }
    
    /// AI发送的消息封装到这里
    static func newAIMessage(chatId: String, userId: String, message: AIChatModel) -> ChatMessageModel {
        ChatMessageModel(
            id: UUID().uuidString,
            chatId: chatId,
            authorId: userId,
            content: message,
            seenByIds: [],
            dateCreated: .now
        )
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
