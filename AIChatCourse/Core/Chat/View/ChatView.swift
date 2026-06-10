//
//  ChatView.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/3/22.
//

import SwiftUI

struct ChatViewDelegate {
    var chat: ChatModel? // public, 让外面传进来
    var avatarId: String = AvatarModel.mock.avatarId // 外面传进来
}

struct ChatView: View {
    @State var presenter: ChatPresenter
    let delegate: ChatViewDelegate
    
    var body: some View {
        VStack {
            scrollviewSection
            textFieldSection
        }
        .navigationTitle(presenter.avatar?.name ?? "")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    presenter.onChatSettingsPressed()
                }, label: {
                    Image(systemName: "ellipsis")
                        .foregroundStyle(.accent)
                        .padding(8)
                })
            }
        }
        .appearAnalyticsViewModifier(name: "ChatView")
        .task {
            await presenter.loadAvatar(avatarId: delegate.avatarId)
        }
        .task {
            await presenter.loadChat(avatarId: delegate.avatarId)
            // 放在下面
            await presenter.listenForChatMessages()
        }
        .onFirstAppear {
            presenter.onViewFirstAppear(chat: delegate.chat)
        }
    }

    private var scrollviewSection: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                ForEach(presenter.chatMessages) { message in
                    // 45 分钟 才显示时间
                    if presenter.messageIsDelayed(message: message) {
                        timestampView(date: message.dateCreatedCalculated)
                    }
                    let isCurrentUser = presenter.messageIsCurrentUser(message: message) // currentUser?.userId
                    ChatBubbleViewBuilder(
                        message: message,
                        isCurrentUser: isCurrentUser,
                        currentUserProfileColor: presenter.currentUser?.profileColorCalculated ?? .accent,
                        imageName: presenter.avatar?.profileImageName,
                        onImagePressed: presenter.onAvatarImagePressed
                    )
                    .onAppear(perform: {
                        presenter.onMessageDidAppear(message: message)
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
        .scrollPosition(id: $presenter.scrollPosition, anchor: .center)
        // .default 动画 搭配scrollview 绝配
        .animation(.default, value: presenter.chatMessages.count)
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
        TextField("Say something...", text: $presenter.textfieldText)
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
                        presenter.onSendMessagePressed()
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

#Preview("Working chat - Not Premium") {
    let container = DevPreview.shared.container
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    return RouterView { router in
        builder.chatView(router: router)
            .previewEnvironment()
    }
}

#Preview("Working chat - Premium") {
    let container = DevPreview.shared.container
    container.regiser(PurchaseManager.self, manager: PurchaseManager(service: MockPurchaseService(activeEntitlements: [.mock])))
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = ChatViewDelegate()
    return RouterView { router in
        builder.chatView(router: router, delegate: delegate)
            .previewEnvironment()
    }
}
