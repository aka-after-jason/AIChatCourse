//
//  WelcomeRouter.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/6/10.
//
import SwiftUI

@MainActor
protocol WelcomeRouter {
    func showOnboardingIntroView(delegate: OnboardingIntroDelete)
    func showCreateAccountView(delegate: CreateAccountDelegate, onDisappear: (() -> Void)?)
}
extension OnboardingRouter: WelcomeRouter {}
