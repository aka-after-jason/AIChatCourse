//
//  ChatsView.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/3/16.
//

import SwiftUI

struct ChatsView: View {
    @State private var chats: [ChatModel] = ChatModel.mocks
    var body: some View {
        NavigationStack {
            List(chats, id: \.self) { chat in
                Text(chat.id)
            }
            .navigationTitle("Chats")
        }
    }
}

#Preview {
    ChatsView()
}
