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
    @Environment(DependencyContainer.self) private var container
    let path: Binding<[NavTabbarPathOption]>
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: NavTabbarPathOption.self) { newValue in
                switch newValue {
                case .chatView(avatarId: let avatarId, chat: let chat):
                    ChatView(
                        viewModel: ChatViewModel(interactor: CoreInteractor(container: container)),
                        chat: chat,
                        avatarId: avatarId
                    )
                case .categoryListView(category: let category, imageName: let imageName):
                    CategoryListView(
                        viewModel: CategoryListViewModel(interactor: CoreInteractor(container: container)),
                        path: path,
                        category: category,
                        imageName: imageName
                    )
                }
            }
    }
}

extension View {
    func customNavDestiForTabbarModule(path: Binding<[NavTabbarPathOption]>) -> some View {
        modifier(NavDestiForTabbarModuleViewModifier(path: path))
    }
}
