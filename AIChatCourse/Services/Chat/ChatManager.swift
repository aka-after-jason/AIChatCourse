//
//  ChatManager.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/5/3.
//
import SwiftUI
import Combine

protocol ChatService {
    func createNewChat(chat: ChatModel) async throws
}

struct MockChatService: ChatService {
    func createNewChat(chat: ChatModel) async throws {
        
    }
}

import FirebaseFirestore
struct FirebaseChatService: ChatService {
    var collection: CollectionReference {
        Firestore.firestore().collection(Constants.chatCollectionName)
    }
    func createNewChat(chat: ChatModel) async throws {
        // 将 chat.id 作为 document id
        try collection.document(chat.id).setData(from: chat, merge: true)
    }
}

// create manager
// 2 services
// add the functions
@MainActor
@Observable
final class ChatManager {
    private let service: ChatService
    init(service: ChatService) {
        self.service = service
    }
    
    func createNewChat(chat: ChatModel) async throws {
        try await service.createNewChat(chat: chat)
    }
}
