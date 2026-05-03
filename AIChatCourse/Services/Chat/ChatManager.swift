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
    func addChatMessage(chatId: String, message: ChatMessageModel) async throws
}

struct MockChatService: ChatService {
    func createNewChat(chat: ChatModel) async throws {
        
    }
    
    func addChatMessage(chatId: String, message: ChatMessageModel) async throws {
        
    }
}

import FirebaseFirestore
struct FirebaseChatService: ChatService {
    private var collection: CollectionReference {
        Firestore.firestore().collection(Constants.chatCollectionName)
    }
    private func messageCollection(chatId: String) -> CollectionReference {
        collection.document(chatId).collection(Constants.messageCollectionName)
    }
    
    func createNewChat(chat: ChatModel) async throws {
        // 将 chat.id 作为 document id
        try collection.document(chat.id).setData(from: chat, merge: true)
    }
    
    func addChatMessage(chatId: String, message: ChatMessageModel) async throws {
        // add the message to chat sub-collection
        try messageCollection(chatId: chatId).document(message.id).setData(from: message, merge: true)
        
        // update chat dateModified
        try await collection.document(chatId).updateData([
            ChatModel.CodingKeys.dateModified.rawValue: Date.now
        ])
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
    
    func addChatMessage(chatId: String, message: ChatMessageModel) async throws {
        try await service.addChatMessage(chatId: chatId, message: message)
    }
}
