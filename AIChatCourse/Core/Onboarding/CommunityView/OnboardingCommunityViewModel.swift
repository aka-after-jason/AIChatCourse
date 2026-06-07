//
//  OnboardingCommunityViewModel.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/6/7.
//
import SwiftUI

protocol OnboardingCommunityViewModelInteractor {}

extension CoreInteractor: OnboardingCommunityViewModelInteractor {}

@MainActor
@Observable
final class OnboardingCommunityViewModel {
    private let interactor: OnboardingCommunityViewModelInteractor
    init(interactor: OnboardingCommunityViewModelInteractor) {
        self.interactor = interactor
    }
    
    func onContinueButtonPressed(path: Binding<[NavOnboardingPathOption]>) {
        path.wrappedValue.append(.colorView)
    }
}
