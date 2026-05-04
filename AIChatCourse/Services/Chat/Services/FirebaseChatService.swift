//
//  FirebaseChatService.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/5/4.
//

import FirebaseFirestore
import SwiftfulFirestore

struct FirebaseChatService: ChatService {
    private var chatCollection: CollectionReference {
        Firestore.firestore().collection(Constants.chatCollectionName)
    }

    private func messageCollection(chatId: String) -> CollectionReference {
        chatCollection.document(chatId).collection(Constants.messageCollectionName)
    }
    
    private var chatReportsCollection: CollectionReference {
        Firestore.firestore().collection(Constants.chatReportsCollectionName)
    }
    
    func createNewChat(chat: ChatModel) async throws {
        // 将 chat.id 作为 document id
        try chatCollection.document(chat.id).setData(from: chat, merge: true)
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
        try await chatCollection.getDocument(id: ChatModel.chatId(userId: userId, avatarId: avatarId))
    }
    
    func getAllChats(userId: String) async throws -> [ChatModel] {
        try await chatCollection
            .whereField(ChatModel.CodingKeys.userId.rawValue, isEqualTo: userId)
            // 这里不在 server 上排序
            .getAllDocuments()
    }
    
    func addChatMessage(chatId: String, message: ChatMessageModel) async throws {
        // add the message to chat sub-collection
        try messageCollection(chatId: chatId).document(message.id).setData(from: message, merge: true)
        
        // update chat dateModified
        try await chatCollection.document(chatId).updateData([
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
    
    func deleteChat(chatId: String) async throws {
        /*
         // 删除 chatCollection
         try await chatCollection.deleteDocument(id: chatId)
         // 删除 messageCollection
         try await messageCollection(chatId: chatId).deleteAllDocuments()
          */
        
        // 两者同时进行, 这里使用 async let
        async let deleteChat: () = chatCollection.deleteDocument(id: chatId)
        async let deleteMessages: () = messageCollection(chatId: chatId).deleteAllDocuments()
        _ = try await (deleteChat, deleteMessages)
    }
    
    func deleteAllChatsForUser(userId: String) async throws {
        let chats = try await getAllChats(userId: userId)
        // 使用 TaskGroup
        try await withThrowingTaskGroup { group in
            for chat in chats {
                group.addTask {
                    try await deleteChat(chatId: chat.id)
                }
            }
            try await group.waitForAll()
        }
    }
    
    func reportChat(report: ChatReportModel) async throws {
        try await chatReportsCollection.setDocument(document: report)
    }
}
