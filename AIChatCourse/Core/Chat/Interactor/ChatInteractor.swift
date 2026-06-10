//
//  ChatInteractor.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/6/10.
//
import SwiftUI

@MainActor
protocol ChatInteractor {
    var currentUser: UserModel? { get }
    var authUser: UserAuthInfoModel? { get }
    var entitlements: [PurchasedEntitlement] { get }
    func trackEvent(event: LoggableEvent)
    func streamChatMessages(chatId: String) -> AsyncThrowingStream<[ChatMessageModel], Error>
    func getCurrentUserId() throws -> String
    func getChat(userId: String, avatarId: String) async throws -> ChatModel?
    func getAvatar(id: String) async throws -> AvatarModel
    func addRecentAvatar(avatar: AvatarModel) async throws
    func markChatMessageAsSeen(chatId: String, messageId: String, userId: String) async throws
    func addChatMessage(chatId: String, message: ChatMessageModel) async throws
    func generateText(chats: [AIChatModel]) async throws -> AIChatModel
    func createNewChat(chat: ChatModel) async throws
    func reportChat(chatId: String, userId: String) async throws
    func deleteChat(chatId: String) async throws
}
extension CoreInteractor: ChatInteractor {}
