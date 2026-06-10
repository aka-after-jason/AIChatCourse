//
//  ChatRouter.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/6/10.
//
import SwiftUI

@MainActor
protocol ChatRouter {
    func showPaywallView()
    func showAlert(error: Error)
    func showAlert(type: CustomRouting.AlertType, title: String, subtitle: String?, buttons: (() -> AnyView)?)
    func showAlert(title: String, subtitle: String?)
    func showProfileModal(avatar: AvatarModel, onXmarkPressed: @escaping () -> Void)
    func dismissModal()
    func dismissAlert()
    func dismissScreen()
}
extension CoreRouter: ChatRouter {}
