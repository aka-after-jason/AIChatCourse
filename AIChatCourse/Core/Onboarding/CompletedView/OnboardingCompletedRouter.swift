//
//  OnboardingCompletedRouter.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/6/10.
//
import SwiftUI

@MainActor
protocol OnboardingCompletedRouter {
    func showAlert(error: Error)
}
extension CoreRouter: OnboardingCompletedRouter {}
