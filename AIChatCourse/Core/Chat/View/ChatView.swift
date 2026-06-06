//
//  ChatView.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/3/22.
//

import SwiftUI

struct ChatView: View {
    @State var viewModel: ChatViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(DependencyContainer.self) private var container
    var chat: ChatModel? // public, 让外面传进来
    var avatarId: String = AvatarModel.mock.avatarId // 外面传进来
    var body: some View {
        VStack {
            scrollviewSection
            textFieldSection
        }
        .navigationTitle(viewModel.avatar?.name ?? "")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    viewModel.onChatSettingsPressed(onDismiss: {
                        dismiss()
                    })
                }, label: {
                    Image(systemName: "ellipsis")
                        .foregroundStyle(.accent)
                        .padding(8)
                })
            }
        }
        .appearAnalyticsViewModifier(name: "ChatView")
        .showCustomAlert(type: .confirmationDialog, alertItem: $viewModel.dialogItem)
        .showCustomAlert(type: .alert, alertItem: $viewModel.alertItem)
        .showModal(showModal: $viewModel.showProfileModalView) {
            if let avatar = viewModel.avatar {
                profileModal(avatar: avatar)
            }
        }
        .sheet(isPresented: $viewModel.showPaywallViwe, content: {
            PaywallView(viewModel: PaywallViewModel(interactor: CoreInteractor(container: container)))
        })
        .task {
            await viewModel.loadAvatar(avatarId: avatarId)
        }
        .task {
            await viewModel.loadChat(avatarId: avatarId)
            // 放在下面
            await viewModel.listenForChatMessages()
        }
        .onFirstAppear {
            viewModel.onViewFirstAppear(chat: chat)
        }
    }

    private func profileModal(avatar: AvatarModel) -> some View {
        ProfileModalView(
            imageName: avatar.profileImageName,
            title: avatar.name,
            subtitle: avatar.characterOption?.rawValue.capitalized,
            headline: avatar.characterDescription
        ) {
            viewModel.showProfileModalView = false
        }
        .padding(40)
        .transition(.slide)
    }

    private var scrollviewSection: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                ForEach(viewModel.chatMessages) { message in
                    // 45 分钟 才显示时间
                    if viewModel.messageIsDelayed(message: message) {
                        timestampView(date: message.dateCreatedCalculated)
                    }
                    let isCurrentUser = viewModel.messageIsCurrentUser(message: message) // currentUser?.userId
                    ChatBubbleViewBuilder(
                        message: message,
                        isCurrentUser: isCurrentUser,
                        currentUserProfileColor: viewModel.currentUser?.profileColorCalculated ?? .accent,
                        imageName: viewModel.avatar?.profileImageName,
                        onImagePressed: viewModel.onAvatarImagePressed
                    )
                    .onAppear(perform: {
                        viewModel.onMessageDidAppear(message: message)
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
        .scrollPosition(id: $viewModel.scrollPosition, anchor: .center)
        // .default 动画 搭配scrollview 绝配
        .animation(.default, value: viewModel.chatMessages.count)
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
        TextField("Say something...", text: $viewModel.textfieldText)
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
                        viewModel.onSendMessagePressed()
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
        ChatView(viewModel: ChatViewModel(interactor: CoreInteractor(container: DevPreview.shared.container)))
            .previewEnvironment()
    }
}
