//
//  CreateAccountRouter.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/6/10.
//
import SwiftUI

@MainActor
protocol CreateAccountRouter {
    func dismissScreen()
}
extension CoreRouter: CreateAccountRouter {}
