//
//  OnboardingColorViewModel.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/6/7.
//
import SwiftUI

@MainActor
protocol OnboardingColorViewModelInteractor {}
extension CoreInteractor: OnboardingColorViewModelInteractor {}

@MainActor
protocol OnboardingColorViewModelRouter {
    func showOnboardingCompletedView(delegate: OnboardingCompletedDelete)
}

extension CoreRouter: OnboardingColorViewModelRouter {}

@MainActor
@Observable
final class OnboardingColorViewModel {
    private let interactor: OnboardingColorViewModelInteractor
    private let router: OnboardingColorViewModelRouter
    init(interactor: OnboardingColorViewModelInteractor, router: OnboardingColorViewModelRouter) {
        self.interactor = interactor
        self.router = router
    }

    let colors: [Color] = [.red, .green, .orange, .blue, .mint, .purple, .cyan, .teal, .indigo]
    private(set) var selectedColor: Color?

    func onColorPressed(color: Color) {
        selectedColor = color
    }

    func onContinueButtonPressed() {
        guard let selectedColor else { return }
        let delegate = OnboardingCompletedDelete(selectedColor: selectedColor)
        router.showOnboardingCompletedView(delegate: delegate)
    }
}
