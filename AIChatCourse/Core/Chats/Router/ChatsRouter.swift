//
//  ChatsRouter.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/6/10.
//
import SwiftUI

@MainActor
protocol ChatsRouter {
    func showChatView(delegate: ChatViewDelegate)
}
extension CoreRouter: ChatsRouter {}
