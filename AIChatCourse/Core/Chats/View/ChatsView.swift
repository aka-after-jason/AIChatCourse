//
//  ChatsView.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/3/16.
//

import SwiftUI

struct ChatsView: View {
    @Environment(CoreBuilder.self) private var builder
    @State var viewModel: ChatsViewModel
    var body: some View {
        NavigationStack(path: $viewModel.path) {
            List {
                if !viewModel.recentAvatars.isEmpty {
                    recentsSection
                }
                chatsSection
            }
            .navigationTitle("Chats")
            .appearAnalyticsViewModifier(name: "ChatsView")
            .customNavDestiForTabbarModule(path: $viewModel.path)
            .task {
                await viewModel.loadChats()
            }
            .onAppear {
                viewModel.loadRecentAvatars()
            }
        }
    }
}

// MARK: 抽取属性

extension ChatsView {
    private var chatsSection: some View {
        Section {
            if viewModel.chats.isEmpty {
                ContentUnavailableView("Empty Chats", systemImage: "text.bubble", description: Text("Your chats will appear here!"))
                    .foregroundStyle(.secondary)
                    .padding(40)
                    .removeListRowFormatting()
            } else {
                ForEach(viewModel.chats) { chat in
                    // ChatRowCellViewBuilder 用了自己的 viewmodel
                    builder.chatRowCellViewBuilder(delegate: ChatRowCellViewDelegate(chat: chat))
                        .anyButton(.highlight, action: {
                            viewModel.onChatPressed(chat: chat)
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
                    ForEach(viewModel.recentAvatars, id: \.self) { avatar in
                        if let imageName = avatar.profileImageName {
                            RecentAvatarView(
                                imageName: imageName,
                                title: avatar.name ?? ""
                            )
                            .anyButton {
                                viewModel.onAvatarPressed(avatar: avatar)
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

#Preview {
    let builder = CoreBuilder(interactor: CoreInteractor(container: DevPreview.shared.container))
    return builder.chatsView()
        .previewEnvironment()
}
