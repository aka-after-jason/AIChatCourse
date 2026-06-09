//
//  OnboardingCommunityViewModel.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/6/7.
//
import SwiftUI

@MainActor
protocol OnboardingCommunityViewModelInteractor {}
extension CoreInteractor: OnboardingCommunityViewModelInteractor {}

@MainActor
protocol OnboardingCommunityViewModelRouter {
    func showOnboardingColorView(delegate: OnboardingColorDelete)
}
extension CoreRouter: OnboardingCommunityViewModelRouter {}

@MainActor
@Observable
final class OnboardingCommunityViewModel {
    private let interactor: OnboardingCommunityViewModelInteractor
    private let router: OnboardingCommunityViewModelRouter
    init(interactor: OnboardingCommunityViewModelInteractor, router: OnboardingCommunityViewModelRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func onContinueButtonPressed() {
        router.showOnboardingColorView(delegate: OnboardingColorDelete())
    }
}
