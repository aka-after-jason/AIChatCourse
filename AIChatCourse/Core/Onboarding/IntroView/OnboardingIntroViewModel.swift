//
//  OnboardingIntroViewModel.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/6/7.
//
import SwiftUI

protocol OnboardingIntroViewModelInteractor {
    var activeABTestModel: ActiveABTestModel { get }
}

extension CoreInteractor: OnboardingIntroViewModelInteractor {}

@MainActor
@Observable
final class OnboardingIntroViewModel {
    private let interactor: OnboardingIntroViewModelInteractor
    init(interactor: OnboardingIntroViewModelInteractor) {
        self.interactor = interactor
    }

    var activeABTestModel: ActiveABTestModel {
        interactor.activeABTestModel
    }
}
