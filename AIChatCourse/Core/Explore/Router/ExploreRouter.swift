//
//  ExploreRouter.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/6/10.
//
import SwiftUI

@MainActor
protocol ExploreRouter {
    func showCategoryListView(delegate: CategoryListDelegate)
    func showChatView(delegate: ChatViewDelegate)
    func showCreateAccountView(delegate: CreateAccountDelegate, onDisappear: (() -> Void)?)
    func showPushNotificationModal(onEnablePressed: @escaping () -> Void, onCancelPressed: @escaping () -> Void)
    func showDevSettingsView()
    func dismissModal()
}
extension CoreRouter: ExploreRouter {}
