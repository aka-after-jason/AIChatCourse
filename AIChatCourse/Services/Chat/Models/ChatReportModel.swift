//
//  ChatReportModel.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/5/4.
//

import SwiftUI
import IdentifiableByString

struct ChatReportModel: Codable, StringIdentifiable {
    let id: String
    let chatId: String
    let userId: String // reporting user
    let isActive: Bool
    let dateCreated: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case chatId = "chat_id"
        case userId = "user_id"
        case isActive = "is_active"
        case dateCreated = "date_created"
    }
    
    static func new(chatId: String, userId: String) -> Self {
        ChatReportModel(
            id: UUID().uuidString,
            chatId: chatId,
            userId: userId,
            isActive: true, // 创建的时候默认为true
            dateCreated: .now
        )
    }
}
