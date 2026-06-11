//
//  OnboardingCommunityRouter.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/6/10.
//
import SwiftUI

@MainActor
protocol OnboardingCommunityRouter {
    func showOnboardingColorView(delegate: OnboardingColorDelete)
}
extension OnboardingRouter: OnboardingCommunityRouter {}
