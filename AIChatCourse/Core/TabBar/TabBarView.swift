//
//  TabBarView.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/3/16.
//

import SwiftUI

struct TabBarView: View {
    
    @Environment(UserManager.self) private var userManager
    @Environment(AvatarManager.self) private var avatarManager
    @Environment(AuthManager.self) private var authManager
    @Environment(LogManager.self) private var logManager
    
    var body: some View {
        TabView {
            ExploreView()
                .tabItem {
                    Label("Explore", systemImage: "eyes")
                }

            ChatsView()
                .tabItem {
                    Label("Chats", systemImage: "bubble.left.and.bubble.right")
                }

            ProfileView(
                viewModel: ProfileViewModel(
                    userManager: userManager,
                    avatarManager: avatarManager,
                    authManager: authManager,
                    logManager: logManager
                )
            )
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
    }
}

#Preview {
    TabBarView()
}
