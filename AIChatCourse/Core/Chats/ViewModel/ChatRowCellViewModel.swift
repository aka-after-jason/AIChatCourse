//
//  ChatRowCellViewModel.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/6/3.
//
import SwiftUI

protocol ChatRowCellViewModelInteractor {
    var authUser: UserAuthInfoModel? { get }
    func trackEvent(event: LoggableEvent)
    func getAvatar(id: String) async throws -> AvatarModel
    func getLastChatMessage(chatId: String) async throws -> ChatMessageModel?
}

extension CoreInteractor: ChatRowCellViewModelInteractor {}

@MainActor
@Observable
final class ChatRowCellViewModel {
    private let interactor: ChatRowCellViewModelInteractor
    init(interactor: ChatRowCellViewModelInteractor) {
        self.interactor = interactor
    }
    
    var currentUserId: String? {
        interactor.authUser?.uid
    }
    
    private(set) var avatar: AvatarModel?
    private(set) var lastChatMessage: ChatMessageModel?
    private(set) var didLoadAvatar: Bool = false
    private(set) var didLoadChatMessage: Bool = false
    
    var subheadline: String? {
        if isLoading {
            return "xxxx xxxx xxxx"
        }
        if avatar == nil, lastChatMessage == nil {
            return "Error loading..."
        }
        return lastChatMessage?.content?.message
    }
    
    var isLoading: Bool {
        if didLoadAvatar && didLoadChatMessage {
            return false
        }
        return true
    }
    
    var hasNewChat: Bool {
        guard let lastChatMessage, let currentUserId else { return false }
        return !lastChatMessage.hasBeenSeenBy(userId: currentUserId)
    }
    
    func loadAvatar(chat: ChatModel) async {
        avatar = try? await interactor.getAvatar(id: chat.avatarId)
        didLoadAvatar = true
    }
    
    func loadLastChatMessage(chat: ChatModel) async {
        lastChatMessage = try? await interactor.getLastChatMessage(chatId: chat.id)
        didLoadChatMessage = true
    }
}

/// 提供类型擦除的方式 for preview
@MainActor
struct AnyChatRowCellViewModelInteractor: ChatRowCellViewModelInteractor {
    let anyAuthUser: UserAuthInfoModel?
    let anyTrackEvent: ((LoggableEvent) -> Void)?
    let anyGetAvatar: (String) async throws -> AvatarModel
    let anyGetLastChatMessage: (String) async throws -> ChatMessageModel?
    
    init(anyAuthUser: UserAuthInfoModel? = nil, anyTrackEvent: ((LoggableEvent) -> Void)? = nil, anyGetAvatar: @escaping (String) async throws -> AvatarModel, anyGetLastChatMessage: @escaping (String) async throws -> ChatMessageModel?) {
        self.anyAuthUser = anyAuthUser
        self.anyTrackEvent = anyTrackEvent
        self.anyGetAvatar = anyGetAvatar
        self.anyGetLastChatMessage = anyGetLastChatMessage
    }
    
    init(interactor: ChatRowCellViewModelInteractor) {
        self.anyAuthUser = interactor.authUser
        self.anyTrackEvent = interactor.trackEvent
        self.anyGetAvatar = interactor.getAvatar
        self.anyGetLastChatMessage = interactor.getLastChatMessage
    }
    
    var authUser: UserAuthInfoModel? {
        anyAuthUser
    }
    
    func trackEvent(event: LoggableEvent) {
        anyTrackEvent?(event)
    }
    
    func getAvatar(id: String) async throws -> AvatarModel {
        try await anyGetAvatar(id)
    }

    func getLastChatMessage(chatId: String) async throws -> ChatMessageModel? {
        try await anyGetLastChatMessage(chatId)
    }
}
