//
//  ChatView.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/3/22.
//

import SwiftUI

struct ChatView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(UserManager.self) private var userManager
    @Environment(AuthManager.self) private var authManager
    @Environment(AvatarManager.self) private var avatarManager
    @Environment(AIManager.self) private var aiManager
    @Environment(ChatManager.self) private var chatManager
    @Environment(LogManager.self) private var logManager
    @Environment(PurchaseManager.self) private var purchaseManager
    @State private var chatMessages: [ChatMessageModel] = []
    @State var chat: ChatModel? // public, 让外面传进来
    @State private var avatar: AvatarModel? // = .mock
    @State private var currentUser: UserModel?
    @State private var textfieldText: String = ""
    @State private var scrollPosition: String?

    @State private var alertItem: AnyAppAlertItem?
    @State private var dialogItem: AnyAppAlertItem?

    @State private var showProfileModalView: Bool = false
    @State private var showPaywallViwe: Bool = false

    var avatarId: String = AvatarModel.mock.avatarId

    var body: some View {
        VStack {
            scrollviewSection
            textFieldSection
        }
        .navigationTitle(avatar?.name ?? "")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    onChatSettingsPressed()
                }, label: {
                    Image(systemName: "ellipsis")
                        .foregroundStyle(.accent)
                        .padding(8)
                })
            }
        }
        .appearAnalyticsViewModifier(name: "ChatView")
        .showCustomAlert(type: .confirmationDialog, alertItem: $dialogItem)
        .showCustomAlert(type: .alert, alertItem: $alertItem)
        .showModal(showModal: $showProfileModalView) {
            if let avatar {
                profileModal(avatar: avatar)
            }
        }
        .sheet(isPresented: $showPaywallViwe, content: {
            PaywallView()
        })
        .task {
            await loadAvatar()
        }
        .task {
            await loadChat()
            // 放在下面
            await listenForChatMessages()
        }
        .onAppear {
            loadCurrentUser()
        }
    }

    private func getChatId() throws -> String {
        guard let chat else {
            throw CustomError.errorMessage(message: "No chat")
        }
        return chat.id
    }

    private func listenForChatMessages() async {
        logManager.trackEvent(event: Event.loadMessagesStart)
        do {
            let chatId = try getChatId()
            for try await value in chatManager.streamChatMessages(chatId: chatId) {
                chatMessages = value.sorted(by: { $0.dateCreatedCalculated < $1.dateCreatedCalculated })
                // 更新 scrollPosition
                scrollPosition = chatMessages.last?.id
            }
        } catch {
            logManager.trackEvent(event: Event.loadMessagesFail(error: error))
        }
    }

    private func loadChat() async {
        logManager.trackEvent(event: Event.loadChatStart)
        do {
            let uid = try authManager.getCurrentUserId()
            chat = try await chatManager.getChat(userId: uid, avatarId: avatarId)
            logManager.trackEvent(event: Event.loadChatSuccess(chat: chat))
        } catch {
            logManager.trackEvent(event: Event.loadChatFail(error: error))
        }
    }

    private func loadCurrentUser() {
        currentUser = userManager.currentUser
    }

    private func loadAvatar() async {
        logManager.trackEvent(event: Event.loadAvatarStart)
        do {
            let avatar = try await avatarManager.getAvatar(id: avatarId)
            // 添加到 SwiftData
            self.avatar = avatar
            try? await avatarManager.addRecentAvatar(avatar: avatar)
            logManager.trackEvent(event: Event.loadAvatarSuccess(avatar: avatar))
        } catch {
            logManager.trackEvent(event: Event.loadAvatarFail(error: error))
        }
    }

    private func profileModal(avatar: AvatarModel) -> some View {
        ProfileModalView(
            imageName: avatar.profileImageName,
            title: avatar.name,
            subtitle: avatar.characterOption?.rawValue.capitalized,
            headline: avatar.characterDescription
        ) {
            showProfileModalView = false
        }
        .padding(40)
        .transition(.slide)
    }

    private var scrollviewSection: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                ForEach(chatMessages) { message in
                    // 45 分钟 才显示时间
                    if messageIsDelayed(message: message) {
                        timestampView(date: message.dateCreatedCalculated)
                    }
                    let isCurrentUser = message.authorId == authManager.authUser?.uid // currentUser?.userId
                    ChatBubbleViewBuilder(
                        message: message,
                        isCurrentUser: isCurrentUser,
                        currentUserProfileColor: currentUser?.profileColorCalculated ?? .accent,
                        imageName: avatar?.profileImageName,
                        onImagePressed: onAvatarImagePressed
                    )
                    .onAppear(perform: {
                        onMessageDidAppear(message: message)
                    })
                    .id(message.id)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(8)
            .rotationEffect(.degrees(180)) // 将内容反转, 目的是让内容贴近输入框
        }
        // 将 scrollview 反转,目的是让内容贴近输入框
        .rotationEffect(.degrees(180))
        .scrollPosition(id: $scrollPosition, anchor: .center)
        // .default 动画 搭配scrollview 绝配
        .animation(.default, value: chatMessages.count)
    }

    private func onMessageDidAppear(message: ChatMessageModel) {
        Task {
            do {
                let uid = try authManager.getCurrentUserId()
                let chatId = try getChatId()
                guard !message.hasBeenSeenBy(userId: uid) else { return }
                try await chatManager.markChatMessageAsSeen(chatId: chatId, messageId: message.id, userId: uid)
            } catch {
                logManager.trackEvent(event: Event.messageSeenFail(error: error))
            }
        }
    }

    /// 大于 45 分钟 返回true
    private func messageIsDelayed(message: ChatMessageModel) -> Bool {
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

    private func timestampView(date: Date) -> some View {
        Group {
            Text(date.formatted(date: .abbreviated, time: .omitted))
                +
                Text(" • ")
                +
                Text(date.formatted(date: .omitted, time: .shortened))
        }
        .foregroundStyle(.secondary)
        .font(.callout)
    }

    private var textFieldSection: some View {
        TextField("Say something...", text: $textfieldText)
            .keyboardType(.alphabet)
            .autocorrectionDisabled()
            .padding(12)
            .padding(.trailing, 60) // textfield 在发送按钮的左边
            .overlay(alignment: .trailing, content: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .padding(.trailing, 4)
                    .foregroundStyle(.accent)
                    .anyButton {
                        onSendMessagePressed()
                    }
            })
            .background(
                ZStack {
                    // 背景
                    RoundedRectangle(cornerRadius: 100)
                        .fill(Color(uiColor: .systemBackground))
                    // 描边
                    RoundedRectangle(cornerRadius: 100)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                }
            )
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color(uiColor: .secondarySystemBackground))
    }
}

// MARK: 事件

extension ChatView {
    private func onSendMessagePressed() {
        let content = textfieldText
        logManager.trackEvent(event: Event.sendMessageStart(chat: chat, avatar: avatar))
        Task {
            do {
                
                // show paywall if needed
                // User is NOT premium
                // Chat has >= 3 messages
                let isPremium = purchaseManager.entitlements.hasActiveEntitlement
                if !isPremium && chatMessages.count >= 3 {
                    showPaywallViwe = true
                    return
                }
                
                // get userId
                let uid = try authManager.getCurrentUserId()

                // validate textField text
                try TextValidationHelper.checkIfTextIsValid(text: content)

                // if chat is nil, then create a new chat
                if chat == nil {
                    chat = try await createNewChat(uid: uid)
                }

                // If there is no chat, throw error (should never happen)
                guard let chat else {
                    throw CustomError.errorMessage(message: "No chat")
                }

                // Create user chat
                let newChatMessage = AIChatModel(role: .user, message: content)
                let newUserMessage = ChatMessageModel.newUserMessage(chatId: chat.id, userId: uid, message: newChatMessage)

                // Upload user chat to the firestore
                try await chatManager.addChatMessage(chatId: chat.id, message: newUserMessage)

                logManager.trackEvent(event: Event.sendMessageSent(chat: chat, avatar: avatar, message: newUserMessage))

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
                let aiResponse = try await aiManager.generateText(chats: aiChats)

                // Create AI Chat
                let newAIMessage = ChatMessageModel.newAIMessage(chatId: chat.id, userId: avatarId, message: aiResponse)

                logManager.trackEvent(event: Event.sendMessageResponse(chat: chat, avatar: avatar, message: newAIMessage))

                // Upload AI chat to the firestore
                try await chatManager.addChatMessage(chatId: chat.id, message: newAIMessage)

                logManager.trackEvent(event: Event.sendMessageResponseSent(chat: chat, avatar: avatar, message: newAIMessage))
            } catch {
                alertItem = AnyAppAlertItem(error: error)
                logManager.trackEvent(event: Event.sendMessageFail(error: error))
            }
        }
    }

    private func createNewChat(uid: String) async throws -> ChatModel {
        logManager.trackEvent(event: Event.createChatStart)
        let newChat = ChatModel.newChat(userId: uid, avatarId: avatarId)
        try await chatManager.createNewChat(chat: newChat)

        // defer: 在 createNewChat 函数结束调用
        defer {
            Task {
                await listenForChatMessages()
            }
        }

        return newChat
    }

    private func onChatSettingsPressed() {
        logManager.trackEvent(event: Event.chatSettingsPressed)
        dialogItem = AnyAppAlertItem(
            title: "",
            subtitle: "What would you like to do?",
            buttons: {
                AnyView(
                    Group {
                        Button("Report User / Chat", role: .destructive) {
                            onReportChatPressed()
                        }
                        Button("Delete Chat", role: .destructive) {
                            onDeleteChatPressed()
                        }
                    }
                )
            }
        )
    }

    private func onReportChatPressed() {
        logManager.trackEvent(event: Event.reportChatStart)
        Task {
            do {
                let chatId = try getChatId()
                let uid = try authManager.getCurrentUserId()
                try await chatManager.reportChat(chatId: chatId, userId: uid)
                alertItem = AnyAppAlertItem(
                    title: "👮🏻 Reported 👮🏻",
                    subtitle: "We will review the chat shortly. You may leave the chat at any time. Thanks for bringing this to our attention!"
                )
                logManager.trackEvent(event: Event.reportChatSuccess)
            } catch {
                alertItem = AnyAppAlertItem(
                    title: "Something went wrong",
                    subtitle: "Please check your internet connection and try again."
                )
                logManager.trackEvent(event: Event.reportChatFail(error: error))
            }
        }
    }

    private func onDeleteChatPressed() {
        logManager.trackEvent(event: Event.deleteChatStart)
        Task {
            do {
                let chatId = try getChatId()
                try await chatManager.deleteChat(chatId: chatId)
                dismiss()
                logManager.trackEvent(event: Event.deleteChatSuccess)
            } catch {
                print("Failed to delete chat: \(error)")
                alertItem = AnyAppAlertItem(
                    title: "Something went wrong",
                    subtitle: "Please check your internet connection and try again."
                )
                logManager.trackEvent(event: Event.deleteChatFail(error: error))
            }
        }
    }

    private func onAvatarImagePressed() {
        showProfileModalView = true
        logManager.trackEvent(event: Event.avatarImagePressed(avatar: avatar))
    }
}

extension ChatView {
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

#Preview {
    NavigationStack {
        ChatView()
            .previewEnvironment()
    }
}
