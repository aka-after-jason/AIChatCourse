//
//  OnboardingCommunityViewModel.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/6/7.
//
import SwiftUI

@MainActor
@Observable
final class OnboardingCommunityPresenter {
    private let interactor: OnboardingCommunityInteractor
    private let router: OnboardingCommunityRouter
    init(interactor: OnboardingCommunityInteractor, router: OnboardingCommunityRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func onContinueButtonPressed() {
        router.showOnboardingColorView(delegate: OnboardingColorDelete())
    }
}
