//
//  ChatsViewModel.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/6/2.
//
import SwiftUI

@MainActor
protocol ChatsViewModelInteractor {
    var authUser: UserAuthInfoModel? { get }
    func trackEvent(event: LoggableEvent)
    func getCurrentUserId() throws -> String
    func getAllChats(userId: String) async throws -> [ChatModel]
    func getRecentAvatars() throws -> [AvatarModel]
    func getAvatar(id: String) async throws -> AvatarModel
    func getLastChatMessage(chatId: String) async throws -> ChatMessageModel?
}

extension CoreInteractor: ChatsViewModelInteractor {}

@MainActor
@Observable
final class ChatsViewModel {
    private let interactor: ChatsViewModelInteractor
    init(interactor: ChatsViewModelInteractor) {
        self.interactor = interactor
    }

    private(set) var chats: [ChatModel] = []
    private(set) var recentAvatars: [AvatarModel] = []
    var path: [NavigationPathOption] = []

    func loadChats() async {
        interactor.trackEvent(event: Event.loadChatsStart)
        do {
            let uid = try interactor.getCurrentUserId()
            chats = try await interactor.getAllChats(userId: uid)
                // .sorted(by: { $0.dateModified > $1.dateModified }) // 排序
                .sortedByKeyPath(keyPath: \.dateModified, ascending: false)
            interactor.trackEvent(event: Event.loadChatsSuccess(chatCount: chats.count))
        } catch {
            interactor.trackEvent(event: Event.loadChatsFail(error: error))
        }
    }

    func loadRecentAvatars() {
        interactor.trackEvent(event: Event.loadAvatarsStart)
        do {
            recentAvatars = try interactor.getRecentAvatars()
            interactor.trackEvent(event: Event.loadAvatarsSuccess(avatarCount: recentAvatars.count))
        } catch {
            interactor.trackEvent(event: Event.loadAvatarsFail(error: error))
        }
    }

    // MARK: ChatRowCellViewBuilder Logic

    var authUser: UserAuthInfoModel? {
        interactor.authUser
    }

    func getAvatar(id: String) async throws -> AvatarModel {
        try await interactor.getAvatar(id: id)
    }

    func getLastChatMessage(chatId: String) async throws -> ChatMessageModel? {
        try await interactor.getLastChatMessage(chatId: chatId)
    }

    // End ChatRowCellViewBuilder Logic

    func onChatPressed(chat: ChatModel) {
        path.append(.chatView(avatarId: chat.avatarId, chat: chat))
        interactor.trackEvent(event: Event.chatPressed(chat: chat))
    }

    func onAvatarPressed(avatar: AvatarModel) {
        path.append(.chatView(avatarId: avatar.avatarId, chat: nil))
        interactor.trackEvent(event: Event.avatarPressed(avatar: avatar))
    }
}

extension ChatsViewModel {
    enum Event: LoggableEvent {
        case loadAvatarsStart
        case loadAvatarsSuccess(avatarCount: Int)
        case loadAvatarsFail(error: Error)

        case loadChatsStart
        case loadChatsSuccess(chatCount: Int)
        case loadChatsFail(error: Error)

        case chatPressed(chat: ChatModel)
        case avatarPressed(avatar: AvatarModel)

        var eventName: String {
            switch self {
            case .loadAvatarsStart: return "ChatsView_LoadAvatar_Start"
            case .loadAvatarsSuccess: return "ChatsView_LoadAvatar_Success"
            case .loadAvatarsFail: return "ChatsView_LoadAvatar_Fail"
            case .loadChatsStart: return "ChatsView_LoadChats_Start"
            case .loadChatsSuccess: return "ChatsView_LoadChats_Success"
            case .loadChatsFail: return "ChatsView_LoadChats_Fail"
            case .chatPressed: return "ChatsView_Chat_Pressed"
            case .avatarPressed: return "ChatsView_Avatar_Pressed"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .loadAvatarsSuccess(avatarCount: let count):
                return ["avatars_count": count]
            case .loadChatsSuccess(chatCount: let count):
                return ["chats_count": count]
            case .loadAvatarsFail(error: let error), .loadChatsFail(error: let error):
                return error.eventParameters
            case .chatPressed(chat: let chat):
                return chat.eventParameters
            case .avatarPressed(avatar: let avatar):
                return avatar.eventParameters
            default:
                return nil
            }
        }

        var type: CustomLogType {
            switch self {
            case .loadAvatarsFail, .loadChatsFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
}
