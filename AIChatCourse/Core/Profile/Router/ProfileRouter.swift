//
//  ProfileRouter.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/6/10.
//
import SwiftUI

@MainActor
protocol ProfileRouter {
    func showSettingsView()
    func showCreateAvatarView(onDisappear: @escaping () -> Void)
    func showAlert(title: String, subtitle: String?)
    func showChatView(delegate: ChatViewDelegate)
}
extension CoreRouter: ProfileRouter {}
