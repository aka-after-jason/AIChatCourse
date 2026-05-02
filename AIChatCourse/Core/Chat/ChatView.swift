//
//  ChatView.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/3/22.
//

import SwiftUI

struct ChatView: View {
    @Environment(AvatarManager.self) private var avatarManager
    @State private var chatMessages: [ChatMessageModel] = ChatMessageModel.mocks
    @State private var avatar: AvatarModel? // = .mock
    @State private var currentUser: UserModel? = .mock
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
        .navigationTitle(avatar?.name ?? "Chat")
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
            headline: avatar.characterDescription) {
                showProfileModalView = false
            }
            .padding(40)
            .transition(.slide)
    }

    private var scrollviewSection: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                ForEach(chatMessages) { message in
                    let isCurrentUser = message.authorId == currentUser?.userId
                    ChatBubbleViewBuilder(
                        message: message,
                        isCurrentUser: isCurrentUser,
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
    }
}

// MARK: 事件

extension ChatView {
    private func onSendMessagePressed() {
        guard let currentUser else { return }
        let content = textfieldText
        do {
            try TextValidationHelper.checkIfTextIsValid(text: content)
            let message = ChatMessageModel(
                id: UUID().uuidString,
                chatId: UUID().uuidString,
                authorId: currentUser.userId,
                content: content,
                seenByIds: nil,
                dateCreated: .now
            )
            chatMessages.append(message)
            scrollPosition = message.id
            textfieldText = ""
        } catch {
            alertItem = AnyAppAlertItem(error: error)
        }
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
