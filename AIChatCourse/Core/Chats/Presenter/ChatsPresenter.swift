//
//  ChatsViewModel.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/6/2.
//
import SwiftUI

@MainActor
@Observable
final class ChatsPresenter {
    private let interactor: ChatsInteractor
    private let router: ChatsRouter
    init(interactor: ChatsInteractor, router: ChatsRouter) {
        self.interactor = interactor
        self.router = router
    }

    private(set) var chats: [ChatModel] = []
    private(set) var recentAvatars: [AvatarModel] = []

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

    func onChatPressed(chat: ChatModel) {
        interactor.trackEvent(event: Event.chatPressed(chat: chat))
        let delegate = ChatViewDelegate(chat: chat, avatarId: chat.avatarId)
        router.showChatView(delegate: delegate)
    }

    func onAvatarPressed(avatar: AvatarModel) {
        interactor.trackEvent(event: Event.avatarPressed(avatar: avatar))
        let delegate = ChatViewDelegate(chat: nil, avatarId: avatar.avatarId)
        router.showChatView(delegate: delegate)
    }
}

extension ChatsPresenter {
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
