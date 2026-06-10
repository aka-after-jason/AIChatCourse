//
//  SettingsRouter.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/6/10.
//
import SwiftUI

@MainActor
protocol SettingsRouter {
    func showAlert(error: Error)
    func showAlert(type: CustomRouting.AlertType, title: String, subtitle: String?, buttons: (() -> AnyView)?)
    func dismissScreen()
    func showCreateAccountView(delegate: CreateAccountDelegate, onDisappear: (() -> Void)?)
    func showRatingsModal(onEnjoyAppYesPressed: @escaping () -> Void, onEnjoyAppNoPressed: @escaping () -> Void)
    func dismissModal()
}
extension CoreRouter: SettingsRouter {}
