//
//  ChatsView.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/3/16.
//

import SwiftUI

struct ChatsView: View {
    @State var presenter: ChatsPresenter
    @ViewBuilder var chatRowCellViewBuilder: (ChatRowCellViewDelegate) -> AnyView
    var body: some View {
        List {
            if !presenter.recentAvatars.isEmpty {
                recentsSection
            }
            chatsSection
        }
        .navigationTitle("Chats")
        .appearAnalyticsViewModifier(name: "ChatsView")
        .task {
            await presenter.loadChats()
        }
        .onAppear {
            presenter.loadRecentAvatars()
        }
    }
}

// MARK: 抽取属性

extension ChatsView {
    private var chatsSection: some View {
        Section {
            if presenter.chats.isEmpty {
                ContentUnavailableView("Empty Chats", systemImage: "text.bubble", description: Text("Your chats will appear here!"))
                    .foregroundStyle(.secondary)
                    .padding(40)
                    .removeListRowFormatting()
            } else {
                ForEach(presenter.chats) { chat in
                    // ChatRowCellViewBuilder 用了自己的 viewmodel
                    chatRowCellViewBuilder(ChatRowCellViewDelegate(chat: chat))
                        .anyButton(.highlight, action: {
                            presenter.onChatPressed(chat: chat)
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
                    ForEach(presenter.recentAvatars, id: \.self) { avatar in
                        if let imageName = avatar.profileImageName {
                            RecentAvatarView(
                                imageName: imageName,
                                title: avatar.name ?? ""
                            )
                            .anyButton {
                                presenter.onAvatarPressed(avatar: avatar)
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
    return RouterView { router in
        builder.chatsView(router: router)
            .previewEnvironment()
    }
}
