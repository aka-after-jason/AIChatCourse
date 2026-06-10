//
//  DevSettingsRouter.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/6/10.
//
import SwiftUI

@MainActor
protocol DevSettingsRouter {
    func dismissScreen()
}
extension CoreRouter: DevSettingsRouter {}
