//
//  ChatManager.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/5/3.
//
import Combine
import SwiftUI

protocol ChatService {
    func createNewChat(chat: ChatModel) async throws
    func getChat(userId: String, avatarId: String) async throws -> ChatModel?
    func getAllChats(userId: String) async throws -> [ChatModel]
    func addChatMessage(chatId: String, message: ChatMessageModel) async throws
    func getLastChatMessage(chatId: String) async throws -> ChatMessageModel?
    func streamChatMessages(chatId: String) -> AsyncThrowingStream<[ChatMessageModel], Error>
}

struct MockChatService: ChatService {
    func createNewChat(chat: ChatModel) async throws {}
    func getChat(userId: String, avatarId: String) async throws -> ChatModel? {
        ChatModel.mock
    }
    func addChatMessage(chatId: String, message: ChatMessageModel) async throws {}
    func streamChatMessages(chatId: String) -> AsyncThrowingStream<[ChatMessageModel], any Error> {
        AsyncThrowingStream { continuation in
            continuation.yield(ChatMessageModel.mocks)
        }
    }
    func getAllChats(userId: String) async throws -> [ChatModel] {
        ChatModel.mocks
    }
    func getLastChatMessage(chatId: String) async throws -> ChatMessageModel? {
        ChatMessageModel.mock
    }
}

import FirebaseFirestore
import SwiftfulFirestore

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
    
    func getChat(userId: String, avatarId: String) async throws -> ChatModel? {
        // 这里要用类型接收一下
        /*
        let result: [ChatModel] = try await collection
            .whereField(ChatModel.CodingKeys.userId.rawValue, isEqualTo: userId)
            .whereField(ChatModel.CodingKeys.avatarId.rawValue, isEqualTo: avatarId)
            .getAllDocuments()
        return result.first
         */
        
        // 另一种方式
        try await collection.getDocument(id: ChatModel.chatId(userId: userId, avatarId: avatarId))
    }
    
    func getAllChats(userId: String) async throws -> [ChatModel] {
        try await collection
            .whereField(ChatModel.CodingKeys.userId.rawValue, isEqualTo: userId)
            // 这里不在 server 上排序
            .getAllDocuments()
    }
    
    func addChatMessage(chatId: String, message: ChatMessageModel) async throws {
        // add the message to chat sub-collection
        try messageCollection(chatId: chatId).document(message.id).setData(from: message, merge: true)
        
        // update chat dateModified
        try await collection.document(chatId).updateData([
            ChatModel.CodingKeys.dateModified.rawValue: Date.now
        ])
    }
    
    func getLastChatMessage(chatId: String) async throws -> ChatMessageModel? {
        let messages: [ChatMessageModel] = try await messageCollection(chatId: chatId)
            .order(by: ChatMessageModel.CodingKeys.dateCreated.rawValue, descending: true)
            .limit(to: 1)
            .getAllDocuments()
        return messages.first
    }
    
    func streamChatMessages(chatId: String) -> AsyncThrowingStream<[ChatMessageModel], Error> {
        messageCollection(chatId: chatId).streamAllDocuments()
    }
    
}

/// create manager
/// 2 services
/// add the functions
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
    
    func getChat(userId: String, avatarId: String) async throws -> ChatModel? {
        try await service.getChat(userId: userId, avatarId: avatarId)
    }
    
    func getAllChats(userId: String) async throws -> [ChatModel] {
        try await service.getAllChats(userId: userId)
    }
    
    func getLastChatMessage(chatId: String) async throws -> ChatMessageModel? {
        try await service.getLastChatMessage(chatId: chatId)
    }
    
    func streamChatMessages(chatId: String) -> AsyncThrowingStream<[ChatMessageModel], Error> {
        service.streamChatMessages(chatId: chatId)
    }
}
