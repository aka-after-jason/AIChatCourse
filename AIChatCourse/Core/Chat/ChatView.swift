//
//  ChatView.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/3/22.
//

import SwiftUI

struct ChatView: View {
    @Environment(UserManager.self) private var userManager
    @Environment(AuthManager.self) private var authManager
    @Environment(AvatarManager.self) private var avatarManager
    @Environment(AIManager.self) private var aiManager
    @Environment(ChatManager.self) private var chatManager
    @State private var chatMessages: [ChatMessageModel] = ChatMessageModel.mocks
    @State private var chat: ChatModel?
    @State private var avatar: AvatarModel? // = .mock
    @State private var currentUser: UserModel?
    @State private var textfieldText: String = ""
    @State private var scrollPosition: String?

    @State private var alertItem: AnyAppAlertItem?
    @State private var dialogItem: AnyAppAlertItem?

    @State private var showProfileModalView: Bool = false

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
        .showCustomAlert(type: .confirmationDialog, alertItem: $dialogItem)
        .showCustomAlert(type: .alert, alertItem: $alertItem)
        .showModal(showModal: $showProfileModalView) {
            if let avatar {
                profileModal(avatar: avatar)
            }
        }
        .task {
            await loadAvatar()
        }
        .onAppear {
            loadCurrentUser()
        }
    }
    
    private func loadCurrentUser() {
        currentUser = userManager.currentUser
    }

    private func loadAvatar() async {
        do {
            let avatar = try await avatarManager.getAvatar(id: avatarId)
            // 添加到 SwiftData
            self.avatar = avatar
            try? await avatarManager.addRecentAvatar(avatar: avatar)
        } catch {
            print("Failed to load avatar: \(error)")
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
                    let isCurrentUser = message.authorId == authManager.authUser?.uid // currentUser?.userId
                    ChatBubbleViewBuilder(
                        message: message,
                        isCurrentUser: isCurrentUser,
                        currentUserProfileColor: currentUser?.profileColorCalculated ?? .accent,
                        imageName: avatar?.profileImageName,
                        onImagePressed: onAvatarImagePressed
                    )
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

#Preview {
    NavigationStack {
        ChatView()
            .environment(AvatarManager(service: MockAvatarService()))
            .previewEnvironment()
    }
}

// MARK: 事件

extension ChatView {
    private func onSendMessagePressed() {
        let content = textfieldText
        Task {
            do {
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
                
                chatMessages.append(newUserMessage) // 拼接到数组中
                
                // Clear the textField & scroll to the bottom
                scrollPosition = newUserMessage.id
                textfieldText = ""
                
                // Generate AI Response
                let aiChats = chatMessages.compactMap({ $0.content })
                let aiResponse = try await aiManager.generateText(chats: aiChats)
                
                // Create AI Chat
                let newAIMessage = ChatMessageModel.newAIMessage(chatId: chat.id, userId: avatarId, message: aiResponse)
                
                // Upload AI chat to the firestore
                try await chatManager.addChatMessage(chatId: chat.id, message: newAIMessage)
                
                chatMessages.append(newAIMessage) // 拼接到数组中
            } catch {
                alertItem = AnyAppAlertItem(error: error)
            }
        }
    }
    
    private func createNewChat(uid: String) async throws -> ChatModel {
        let newChat = ChatModel.newChat(userId: uid, avatarId: avatarId)
        try await chatManager.createNewChat(chat: newChat)
        return newChat
    }

    private func onChatSettingsPressed() {
        dialogItem = AnyAppAlertItem(
            title: "",
            subtitle: "What would you like to do?",
            buttons: {
                AnyView(
                    Group {
                        Button("Report User / Chat", role: .destructive) {}
                        Button("Delete Chat", role: .destructive) {}
                    }
                )
            }
        )
    }

    private func onAvatarImagePressed() {
        showProfileModalView = true
    }
}
