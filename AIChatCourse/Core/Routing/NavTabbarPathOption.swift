//
//  NavigationPathOption.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/4/24.
//

import Foundation
import SwiftUI

enum NavTabbarPathOption: Hashable {
    case chatView(avatarId: String, chat: ChatModel?)
    case categoryListView(category: CharacterOption, imageName: String)
}

struct NavDestiForTabbarModuleViewModifier: ViewModifier {
    let path: Binding<[NavTabbarPathOption]>
    @ViewBuilder var chatView: (ChatViewDelegate) -> AnyView
    @ViewBuilder var categoryListView: (CategoryListDelegate) -> AnyView
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: NavTabbarPathOption.self) { newValue in
                switch newValue {
                case .chatView(avatarId: let avatarId, chat: let chat):
                    chatView(ChatViewDelegate(chat: chat, avatarId: avatarId))
                case .categoryListView(category: let category, imageName: let imageName):
                    categoryListView(CategoryListDelegate(path: path, category: category, imageName: imageName))
                }
            }
    }
}

extension View {
    func customNavDestiForTabbarModule(
        path: Binding<[NavTabbarPathOption]>,
        @ViewBuilder chatView: @escaping (ChatViewDelegate) -> AnyView,
        @ViewBuilder categoryListView: @escaping (CategoryListDelegate) -> AnyView
    ) -> some View {
        modifier(
            NavDestiForTabbarModuleViewModifier(
                path: path,
                chatView: chatView,
                categoryListView: categoryListView
            )
        )
    }
}
