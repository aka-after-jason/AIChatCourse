//
//  OnboardingIntroViewModel.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/6/7.
//
import SwiftUI

@MainActor
protocol OnboardingIntroViewModelInteractor {
    var activeABTestModel: ActiveABTestModel { get }
}
extension CoreInteractor: OnboardingIntroViewModelInteractor {}

@MainActor
protocol OnboardingIntroViewModelRouter {
    func showOnboardingCommunityView(delegate: OnboardingCommunityDelete)
    func showOnboardingColorView(delegate: OnboardingColorDelete)
}
extension CoreRouter: OnboardingIntroViewModelRouter {}

@MainActor
@Observable
final class OnboardingIntroViewModel {
    private let interactor: OnboardingIntroViewModelInteractor
    private let router: OnboardingIntroViewModelRouter
    init(interactor: OnboardingIntroViewModelInteractor, router: OnboardingIntroViewModelRouter) {
        self.interactor = interactor
        self.router = router
    }

    var activeABTestModel: ActiveABTestModel {
        interactor.activeABTestModel
    }
    
    func onContinueButtonPressed() {
        if activeABTestModel.onboardingCommunityTest {
            router.showOnboardingCommunityView(delegate: OnboardingCommunityDelete())
        } else {
            router.showOnboardingColorView(delegate: OnboardingColorDelete())
        }
    }
}
