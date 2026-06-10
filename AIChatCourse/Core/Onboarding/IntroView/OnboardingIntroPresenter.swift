//
//  OnboardingIntroViewModel.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/6/7.
//
import SwiftUI

@MainActor
@Observable
final class OnboardingIntroPresenter {
    private let interactor: OnboardingIntroInteractor
    private let router: OnboardingIntroRouter
    init(interactor: OnboardingIntroInteractor, router: OnboardingIntroRouter) {
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
