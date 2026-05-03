//
//  ChatModel.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/3/21.
//

import Foundation

struct ChatModel: Identifiable, Hashable, Codable {
    let id: String
    let userId: String
    let avatarId: String
    let dateCreated: Date
    let dateModified: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case userId = "user_id"
        case avatarId = "avatar_id"
        case dateCreated = "date_created"
        case dateModified = "date_modified"
    }
    
    static func newChat(userId: String, avatarId: String) -> Self {
        ChatModel(
            id: "\(userId)_\(avatarId)",
            userId: userId,
            avatarId: avatarId,
            dateCreated: .now,
            dateModified: .now
        )
    }

    /// mock data
    static var mock: ChatModel {
        mocks[0]
    }

    static var mocks: [ChatModel] {
        let now = Date()
        return [
            ChatModel(
                id: "mock_chat_1",
                userId: "user1",
                avatarId: "avatar1",
                dateCreated: now,
                dateModified: now
            ),
            ChatModel(
                id: "mock_chat_2",
                userId: "user2",
                avatarId: "avatar2",
                dateCreated: now.addingTimeInterval(hours: -1),
                dateModified: now.addingTimeInterval(minutes: -30)
            ),
            ChatModel(
                id: "mock_chat_3",
                userId: "user3",
                avatarId: "avatar3",
                dateCreated: now.addingTimeInterval(hours: -2),
                dateModified: now.addingTimeInterval(hours: -1)
            ),
            ChatModel(
                id: "mock_chat_4",
                userId: "user4",
                avatarId: "avatar4",
                dateCreated: now.addingTimeInterval(days: -1),
                dateModified: now.addingTimeInterval(hours: -10)
            )
        ]
    }
}
