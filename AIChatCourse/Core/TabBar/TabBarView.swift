//
//  TabBarView.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/3/16.
//

import SwiftUI

struct TabBarView: View {
    
    @Environment(DependencyContainer.self) private var container
    
    var body: some View {
        TabView {
            ExploreView(viewModel: ExploreViewModel(interactor: CoreInteractor(container: container)))
                .tabItem {
                    Label("Explore", systemImage: "eyes")
                }

            ChatsView()
                .tabItem {
                    Label("Chats", systemImage: "bubble.left.and.bubble.right")
                }

            ProfileView(viewModel: ProfileViewModel(interactor: CoreInteractor(container: container)))
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
    }
}

#Preview {
    TabBarView()
}
