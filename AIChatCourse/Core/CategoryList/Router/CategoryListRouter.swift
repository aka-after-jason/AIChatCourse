//
//  CategoryListRouter.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/6/10.
//
import SwiftUI

@MainActor
protocol CategoryListRouter {
    func showAlert(error: Error)
    func showChatView(delegate: ChatViewDelegate)
}
extension CoreRouter: CategoryListRouter {}
