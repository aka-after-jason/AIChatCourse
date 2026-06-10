//
//  ChatViewModel.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/6/6.
//
import SwiftUI

@MainActor
@Observable
final class ChatPresenter {
    private let interactor: ChatInteractor
    private let router: ChatRouter
    init(interactor: ChatInteractor, router: ChatRouter) {
        self.interactor = interactor
        self.router = router
    }

    private(set) var chatMessages: [ChatMessageModel] = []
    private(set) var avatar: AvatarModel? // = .mock
    private(set) var currentUser: UserModel?
    private(set) var chat: ChatModel?

    var scrollPosition: String?
    var textfieldText: String = ""

    var entitlements: [PurchasedEntitlement] {
        interactor.entitlements
    }

    func messageIsCurrentUser(message: ChatMessageModel) -> Bool {
        message.authorId == interactor.authUser?.uid
    }

    func onViewFirstAppear(chat: ChatModel?) {
        currentUser = interactor.currentUser
        self.chat = chat
    }

    func getChatId() throws -> String {
        guard let chat else {
            throw CustomError.errorMessage(message: "No chat")
        }
        return chat.id
    }

    func listenForChatMessages() async {
        interactor.trackEvent(event: Event.loadMessagesStart)
        do {
            let chatId = try getChatId()
            for try await value in interactor.streamChatMessages(chatId: chatId) {
                chatMessages = value.sorted(by: { $0.dateCreatedCalculated < $1.dateCreatedCalculated })
                // 更新 scrollPosition
                scrollPosition = chatMessages.last?.id
            }
        } catch {
            interactor.trackEvent(event: Event.loadMessagesFail(error: error))
        }
    }

    func loadChat(avatarId: String) async {
        interactor.trackEvent(event: Event.loadChatStart)
        do {
            let uid = try interactor.getCurrentUserId()
            chat = try await interactor.getChat(userId: uid, avatarId: avatarId)
            interactor.trackEvent(event: Event.loadChatSuccess(chat: chat))
        } catch {
            interactor.trackEvent(event: Event.loadChatFail(error: error))
        }
    }

    func loadAvatar(avatarId: String) async {
        interactor.trackEvent(event: Event.loadAvatarStart)
        do {
            let avatar = try await interactor.getAvatar(id: avatarId)
            // 添加到 SwiftData
            self.avatar = avatar
            try? await interactor.addRecentAvatar(avatar: avatar)
            interactor.trackEvent(event: Event.loadAvatarSuccess(avatar: avatar))
        } catch {
            interactor.trackEvent(event: Event.loadAvatarFail(error: error))
        }
    }

    func onMessageDidAppear(message: ChatMessageModel) {
        Task {
            do {
                let uid = try interactor.getCurrentUserId()
                let chatId = try getChatId()
                guard !message.hasBeenSeenBy(userId: uid) else { return }
                try await interactor.markChatMessageAsSeen(chatId: chatId, messageId: message.id, userId: uid)
            } catch {
                interactor.trackEvent(event: Event.messageSeenFail(error: error))
            }
        }
    }

    /// 大于 45 分钟 返回true
    func messageIsDelayed(message: ChatMessageModel) -> Bool {
        let currentMessageDate = message.dateCreatedCalculated
        guard let index = chatMessages.firstIndex(where: { $0.id == message.id }), chatMessages.indices.contains(index - 1) else {
            return false
        }
        let previousMessageDate = chatMessages[index - 1].dateCreatedCalculated
        let timeDiff = currentMessageDate.timeIntervalSince(previousMessageDate)
        // threshold = 60 seconds * 45 minutes
        let threshold: TimeInterval = 60 * 45
        return timeDiff > threshold
    }

    func onSendMessagePressed() {
        let content = textfieldText
        interactor.trackEvent(event: Event.sendMessageStart(chat: chat, avatar: avatar))
        Task {
            do {
                // show paywall if needed
                // User is NOT premium
                // Chat has >= 3 messages
                let isPremium = interactor.entitlements.hasActiveEntitlement
                if !isPremium && chatMessages.count >= 3 {
                    router.showPaywallView()
                    return
                }

                // get userId
                let uid = try interactor.getCurrentUserId()

                // validate textField text
                try TextValidationHelper.checkIfTextIsValid(text: content)

                // if chat is nil, then create a new chat
                if chat == nil {
                    chat = try await createNewChat(uid: uid, avatarId: avatar?.avatarId ?? "")
                }

                // If there is no chat, throw error (should never happen)
                guard let chat else {
                    throw CustomError.errorMessage(message: "No chat")
                }

                // Create user chat
                let newChatMessage = AIChatModel(role: .user, message: content)
                let newUserMessage = ChatMessageModel.newUserMessage(chatId: chat.id, userId: uid, message: newChatMessage)

                // Upload user chat to the firestore
                try await interactor.addChatMessage(chatId: chat.id, message: newUserMessage)

                interactor.trackEvent(event: Event.sendMessageSent(chat: chat, avatar: avatar, message: newUserMessage))

                // Clear the textField & scroll to the bottom
                textfieldText = ""

                // Generate AI Response
                var aiChats = chatMessages.compactMap { $0.content }
                if let avatarDescription = avatar?.characterDescription {
                    // "A cat that is smiling in the park."
                    let systemMessage = AIChatModel(
                        role: .system,
                        message: "You are a \(avatarDescription) with the intelligence of an AI. We are having a VERY casual conversation. You are my friend."
                    )
                    aiChats.insert(systemMessage, at: 0)
                }
                let aiResponse = try await interactor.generateText(chats: aiChats)

                // Create AI Chat
                let newAIMessage = ChatMessageModel.newAIMessage(chatId: chat.id, userId: avatar?.avatarId ?? "", message: aiResponse)

                interactor.trackEvent(event: Event.sendMessageResponse(chat: chat, avatar: avatar, message: newAIMessage))

                // Upload AI chat to the firestore
                try await interactor.addChatMessage(chatId: chat.id, message: newAIMessage)

                interactor.trackEvent(event: Event.sendMessageResponseSent(chat: chat, avatar: avatar, message: newAIMessage))
            } catch {
                interactor.trackEvent(event: Event.sendMessageFail(error: error))
                router.showAlert(error: error)
            }
        }
    }

    func createNewChat(uid: String, avatarId: String) async throws -> ChatModel {
        interactor.trackEvent(event: Event.createChatStart)
        let newChat = ChatModel.newChat(userId: uid, avatarId: avatarId)
        try await interactor.createNewChat(chat: newChat)

        // defer: 在 createNewChat 函数结束调用
        defer {
            Task {
                await listenForChatMessages()
            }
        }

        return newChat
    }

    func onChatSettingsPressed() {
        interactor.trackEvent(event: Event.chatSettingsPressed)
        router.showAlert(
            type: .confirmationDialog,
            title: "",
            subtitle: "What would you like to do?",
            buttons: {
            AnyView(
                Group {
                    Button("Report User / Chat", role: .destructive, action: {
                        self.onReportChatPressed()
                    })
                    Button("Delete Chat", role: .destructive) {
                        self.onDeleteChatPressed()
                    }
                }
            )
        })
    }

    func onReportChatPressed() {
        interactor.trackEvent(event: Event.reportChatStart)
        Task {
            do {
                let chatId = try getChatId()
                let uid = try interactor.getCurrentUserId()
                try await interactor.reportChat(chatId: chatId, userId: uid)
                interactor.trackEvent(event: Event.reportChatSuccess)
                router.showAlert(
                    title: "👮🏻 Reported 👮🏻",
                    subtitle: "We will review the chat shortly. You may leave the chat at any time. Thanks for bringing this to our attention!"
                )
            } catch {
                interactor.trackEvent(event: Event.reportChatFail(error: error))
                router.showAlert(
                    title: "Something went wrong",
                    subtitle: "Please check your internet connection and try again."
                )
            }
        }
    }

    func onDeleteChatPressed() {
        interactor.trackEvent(event: Event.deleteChatStart)
        Task {
            do {
                let chatId = try getChatId()
                try await interactor.deleteChat(chatId: chatId)
                router.dismissScreen()
                interactor.trackEvent(event: Event.deleteChatSuccess)
            } catch {
                interactor.trackEvent(event: Event.deleteChatFail(error: error))
                router.showAlert(
                    title: "Something went wrong",
                    subtitle: "Please check your internet connection and try again."
                )
            }
        }
    }

    func onAvatarImagePressed() {
        interactor.trackEvent(event: Event.avatarImagePressed(avatar: avatar))
        if let avatar = avatar {
            router.showProfileModal(avatar: avatar, onXmarkPressed: {
                self.router.dismissModal()
            })
        }
    }
}

extension ChatPresenter {
    enum Event: LoggableEvent {
        case loadAvatarStart
        case loadAvatarSuccess(avatar: AvatarModel)
        case loadAvatarFail(error: Error)

        case loadChatStart
        case loadChatSuccess(chat: ChatModel?)
        case loadChatFail(error: Error)

        case loadMessagesStart
        case loadMessagesFail(error: Error)

        case messageSeenFail(error: Error)

        case sendMessageStart(chat: ChatModel?, avatar: AvatarModel?)
        case sendMessagePaywall(chat: ChatModel?, avatar: AvatarModel?)
        case sendMessageFail(error: Error)
        case sendMessageSent(chat: ChatModel?, avatar: AvatarModel?, message: ChatMessageModel)
        case sendMessageResponse(chat: ChatModel?, avatar: AvatarModel?, message: ChatMessageModel)
        case sendMessageResponseSent(chat: ChatModel?, avatar: AvatarModel?, message: ChatMessageModel)

        case createChatStart

        case chatSettingsPressed

        case reportChatStart
        case reportChatSuccess
        case reportChatFail(error: Error)

        case deleteChatStart
        case deleteChatSuccess
        case deleteChatFail(error: Error)

        case avatarImagePressed(avatar: AvatarModel?)

        var eventName: String {
            switch self {
            case .loadAvatarStart: return "ChatView_LoadAvatar_Start"
            case .loadAvatarSuccess: return "ChatView_LoadAvatar_Success"
            case .loadAvatarFail: return "ChatView_LoadAvatar_Fail"
            case .loadChatStart: return "ChatView_LoadChat_Start"
            case .loadChatSuccess: return "ChatView_LoadChat_Success"
            case .loadChatFail: return "ChatView_LoadChat_Fail"
            case .loadMessagesStart: return "ChatView_LoadMessages_Start"
            case .loadMessagesFail: return "ChatView_LoadMessages_Fail"
            case .messageSeenFail: return "ChatView_MessageSeen_Fail"
            case .sendMessageStart: return "ChatView_SendMessage_Start"
            case .sendMessagePaywall: return "ChatView_SendMessage_Paywall"
            case .sendMessageFail: return "ChatView_SendMessage_Fail"
            case .sendMessageSent: return "ChatView_SentMessage_Sent"
            case .sendMessageResponse: return "ChatView_SentMessage_Response"
            case .sendMessageResponseSent: return "ChatView_SentMessage_Response_Sent"
            case .createChatStart: return "ChatView_CreateChat_Start"
            case .chatSettingsPressed: return "ChatView_ChatSettings_Pressed"
            case .reportChatStart: return "ChatView_ReportChat_Start"
            case .reportChatSuccess: return "ChatView_ReportChat_Success"
            case .reportChatFail: return "ChatView_ReportChat_Fail"
            case .deleteChatStart: return "ChatView_DeleteChat_Start"
            case .deleteChatSuccess: return "ChatView_DeleteChat_Success"
            case .deleteChatFail: return "ChatView_DeleteChat_Fail"
            case .avatarImagePressed: return "ChatView_AvatarImage_Pressed"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .loadAvatarFail(error: let error),
                 .loadChatFail(error: let error),
                 .loadMessagesFail(error: let error),
                 .sendMessageFail(error: let error),
                 .reportChatFail(error: let error),
                 .deleteChatFail(error: let error):
                return error.eventParameters
            case .loadAvatarSuccess(avatar: let avatar):
                return avatar.eventParameters
            case .loadChatSuccess(chat: let chat):
                return chat?.eventParameters
            case .sendMessageStart(chat: let chat, avatar: let avatar), .sendMessagePaywall(chat: let chat, avatar: let avatar):
                var dict = chat?.eventParameters ?? [:]
                dict.merge(avatar?.eventParameters)
                return dict
            case .sendMessageSent(chat: let chat, avatar: let avatar, message: let message),
                 .sendMessageResponse(chat: let chat, avatar: let avatar, message: let message),
                 .sendMessageResponseSent(chat: let chat, avatar: let avatar, message: let message):
                var dict = chat?.eventParameters ?? [:]
                dict.merge(avatar?.eventParameters)
                dict.merge(message.eventParameters)
                return dict
            case .avatarImagePressed(avatar: let avatar):
                return avatar?.eventParameters
            default:
                return nil
            }
        }

        var type: CustomLogType {
            switch self {
            case .loadAvatarFail,
                 .messageSeenFail,
                 .reportChatFail,
                 .deleteChatFail:
                return .severe
            case .loadChatFail, .sendMessageFail, .loadMessagesFail:
                return .warning
            default:
                return .analytic
            }
        }
    }
}
