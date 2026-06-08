//
//  ChatRowCellViewBuilder.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/3/21.
//

import SwiftUI

struct ChatRowCellViewDelegate {
    var chat: ChatModel = .mock // view to view
}

struct ChatRowCellViewBuilder: View {
    @State var viewModel: ChatRowCellViewModel
    let delegate: ChatRowCellViewDelegate
    var body: some View {
        ChatRowCellView(
            imageName: viewModel.avatar?.profileImageName,
            headline: viewModel.isLoading ? "xxx xxx" : viewModel.avatar?.name,
            subheadline: viewModel.subheadline,
            hasNewChat: viewModel.isLoading ? false : viewModel.hasNewChat
        )
        .redacted(reason: viewModel.isLoading ? .placeholder : [])
        .task {
            // get the avatar
            await viewModel.loadAvatar(chat: delegate.chat)
        }
        .task {
            // get last chat message
            await viewModel.loadLastChatMessage(chat: delegate.chat)
        }
    }
}

#Preview {
    let builder = CoreBuilder(interactor: CoreInteractor(container: DevPreview.shared.container))
    return VStack {
        builder.chatRowCellViewBuilder()

        // 使用类型擦除的方式
        ChatRowCellViewBuilder(
            viewModel: ChatRowCellViewModel(interactor: AnyChatRowCellViewModelInteractor(
                anyGetAvatar: { _ in
                    try? await Task.sleep(for: .seconds(5))
                    return AvatarModel.mock
                },
                anyGetLastChatMessage: { _ in
                    try? await Task.sleep(for: .seconds(5))
                    return ChatMessageModel.mock
                }
            )),
            delegate: ChatRowCellViewDelegate()
        )

        // 使用类型擦除的方式
        ChatRowCellViewBuilder(
            viewModel: ChatRowCellViewModel(interactor: AnyChatRowCellViewModelInteractor(
                anyGetAvatar: { _ in
                    AvatarModel.mock
                },
                anyGetLastChatMessage: { _ in
                    ChatMessageModel.mock
                }
            )),
            delegate: ChatRowCellViewDelegate()
        )

        // 使用类型擦除的方式
        ChatRowCellViewBuilder(
            viewModel: ChatRowCellViewModel(interactor: AnyChatRowCellViewModelInteractor(
                anyGetAvatar: { _ in
                    throw URLError(.badURL)
                },
                anyGetLastChatMessage: { _ in
                    throw URLError(.badURL)
                }
            )),
            delegate: ChatRowCellViewDelegate()
        )
    }
}
