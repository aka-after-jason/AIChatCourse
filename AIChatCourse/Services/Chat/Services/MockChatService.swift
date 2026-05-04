//
//  MockChatService.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/5/4.
//

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

    func deleteChat(chatId: String) async throws {}

    func deleteAllChatsForUser(userId: String) async throws {}

    func reportChat(report: ChatReportModel) async throws {}
}
