//
//  NavigationPathOption.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/4/24.
//

import SwiftUI
import Foundation

enum NavigationPathOption: Hashable {
    case chatView(avatarId: String)
    case categoryListView(category: CharacterOption, imageName: String)
}

extension View {
    func customNavigationDestinationForCoreModule(path: Binding<[NavigationPathOption]>) -> some View {
        self
            .navigationDestination(for: NavigationPathOption.self) { type in
                switch type {
                case .chatView(avatarId: let avatarId):
                    ChatView(avatarId: avatarId)
                case .categoryListView(category: let category, imageName: let imageName):
                    CategoryListView(category: category, imageName: imageName, path: path)
                }
            }
    }
}
