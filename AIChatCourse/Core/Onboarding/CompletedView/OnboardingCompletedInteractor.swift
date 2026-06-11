//
//  OnboardingCompletedInteractor.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/6/10.
//
import SwiftUI

@MainActor
protocol OnboardingCompletedInteractor {
    func trackEvent(event: LoggableEvent)
    func markOnboardingCompleteForCurrentUser(profileColorHex: String) async throws
    func updateAppState(showTabBarView: Bool)
}
extension OnboardingInteractor: OnboardingCompletedInteractor {}
