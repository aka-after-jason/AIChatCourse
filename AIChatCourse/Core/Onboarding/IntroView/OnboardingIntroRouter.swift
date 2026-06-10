//
//  OnboardingIntroRouter.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/6/10.
//
import SwiftUI

@MainActor
protocol OnboardingIntroRouter {
    func showOnboardingCommunityView(delegate: OnboardingCommunityDelete)
    func showOnboardingColorView(delegate: OnboardingColorDelete)
}
extension CoreRouter: OnboardingIntroRouter {}
