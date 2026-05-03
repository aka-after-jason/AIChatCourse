//
//  ChatsView.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/3/16.
//

import SwiftUI

struct ChatsView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(ChatManager.self) private var chatManager
    @Environment(AvatarManager.self) private var avatarManager
    @State private var chats: [ChatModel] = []
    @State private var recentAvatars: [AvatarModel] = []
    @State private var path: [NavigationPathOption] = []
    var body: some View {
        NavigationStack(path: $path) {
            List {
                if !recentAvatars.isEmpty {
                    recentsSection
                }
                chatsSection
            }
            .navigationTitle("Chats")
            .customNavigationDestinationForCoreModule(path: $path)
            .task {
                await loadChats()
            }
            .onAppear {
                loadRecentAvatars()
            }
        }
    }

    private func loadChats() async {
        do {
            let uid = try authManager.getCurrentUserId()
            chats = try await chatManager.getAllChats(userId: uid)
                // .sorted(by: { $0.dateModified > $1.dateModified }) // 排序
                .sortedByKeyPath(keyPath: \.dateModified, ascending: false)
        } catch {
            print("Failed to load chats: \(error)")
        }
    }

    private func loadRecentAvatars() {
        do {
            recentAvatars = try avatarManager.getRecentAvatars()
        } catch {
            print("Failed to load recent avatars: \(error)")
        }
    }
}

#Preview {
    ChatsView()
        .previewEnvironment()
}

// MARK: 抽取属性

extension ChatsView {
    private var chatsSection: some View {
        Section {
            if chats.isEmpty {
                ContentUnavailableView("Empty Chats", systemImage: "text.bubble", description: Text("Your chats will appear here!"))
                    .foregroundStyle(.secondary)
                    .padding(40)
                    .removeListRowFormatting()
            } else {
                ForEach(chats) { chat in
                    ChatRowCellViewBuilder(
                        currentUserId: authManager.authUser?.uid,
                        chat: chat,
                        getAvatar: {
                            try? await avatarManager.getAvatar(id: chat.avatarId)
                        },
                        getLastChatMessage: {
                            try? await chatManager.getLastChatMessage(chatId: chat.id)
                        }
                    )
                    .anyButton(.highlight, action: {
                        onChatPressed(chat: chat)
                    })
                    .removeListRowFormatting()
                }
            }
        } header: {
            Text("Chats")
        }
    }

    private var recentsSection: some View {
        Section {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 8) {
                    ForEach(recentAvatars, id: \.self) { avatar in
                        if let imageName = avatar.profileImageName {
                            RecentAvatarView(imageName: imageName, title: avatar.name ?? "")
                                .anyButton {
                                    onAvatarPressed(avatar: avatar)
                                }
                        }
                    }
                }
                .padding(.top, 12)
            }
            .frame(height: 120) // 给一个固定的高度
            .removeListRowFormatting()
        } header: {
            Text("Recents")
        }
    }
}

struct RecentAvatarView: View {
    var imageName: String
    var title: String
    var body: some View {
        VStack {
            ImageLoaderView(urlString: imageName)
                .aspectRatio(1, contentMode: .fit)
                .clipShape(Circle())
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: 事件

extension ChatsView {
    private func onChatPressed(chat: ChatModel) {
        path.append(.chatView(avatarId: chat.avatarId, chat: chat))
    }

    private func onAvatarPressed(avatar: AvatarModel) {
        path.append(.chatView(avatarId: avatar.avatarId, chat: nil))
    }
}
