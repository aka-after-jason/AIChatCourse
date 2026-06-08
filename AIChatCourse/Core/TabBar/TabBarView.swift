//
//  TabBarView.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/3/16.
//

import SwiftUI

struct TabBarScreen: Identifiable {
    var id: String {
        title
    }

    let title: String
    let systemImage: String
    @ViewBuilder var screen: () -> AnyView
}

struct TabBarView: View {
    var tabs: [TabBarScreen]

    var body: some View {
        TabView {
            ForEach(tabs) { tab in
                tab.screen()
                    .tabItem {
                        Label(tab.title, systemImage: tab.systemImage)
                    }
            }
        }
    }
}

#Preview("Real tabs") {
    let builder = CoreBuilder(interactor: CoreInteractor(container: DevPreview.shared.container))
    return builder.tabbarView()
        .previewEnvironment()
}

#Preview("Fake tabs") {
    TabBarView(tabs: [
        TabBarScreen(title: "Explore", systemImage: "eyes", screen: {
            Color.red.any()
        }),
        TabBarScreen(title: "Chats", systemImage: "bubble.left.and.bubble.right", screen: {
            Color.green.any()
        }),
        TabBarScreen(title: "Profile", systemImage: "person.fill", screen: {
            Color.blue.any()
        })
    ])
    .previewEnvironment()
}
