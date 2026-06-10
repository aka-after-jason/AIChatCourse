//
//  PaywallRouter.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/6/10.
//
import SwiftUI

@MainActor
protocol PaywallRouter {
    func dismissScreen()
    func showAlert(error: Error)
}
extension CoreRouter: PaywallRouter {}
