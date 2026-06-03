//
//  NavigationPathOption.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/4/24.
//

import Foundation
import SwiftUI

enum NavigationPathOption: Hashable {
    case chatView(avatarId: String, chat: ChatModel?)
    case categoryListView(category: CharacterOption, imageName: String)
}

struct NavigationDestinationViewModifier: ViewModifier {
    @Environment(DependencyContainer.self) private var container
    let path: Binding<[NavigationPathOption]>
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: NavigationPathOption.self) { newValue in
                switch newValue {
                case .chatView(avatarId: let avatarId, chat: let chat):
                    ChatView(chat: chat, avatarId: avatarId)
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
    func customNavigationDestinationForCoreModule(path: Binding<[NavigationPathOption]>) -> some View {
        modifier(NavigationDestinationViewModifier(path: path))
    }
}
