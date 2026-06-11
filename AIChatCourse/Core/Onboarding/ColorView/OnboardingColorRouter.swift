//
//  OnboardingColorRouter.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/6/10.
//
import SwiftUI

@MainActor
protocol OnboardingColorRouter {
    func showOnboardingCompletedView(delegate: OnboardingCompletedDelete)
}
extension OnboardingRouter: OnboardingColorRouter {}
