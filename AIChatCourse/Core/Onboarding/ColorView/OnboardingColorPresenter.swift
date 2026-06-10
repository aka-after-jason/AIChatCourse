//
//  OnboardingColorViewModel.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/6/7.
//
import SwiftUI

@MainActor
@Observable
final class OnboardingColorPresenter {
    private let interactor: OnboardingColorInteractor
    private let router: OnboardingColorRouter
    init(interactor: OnboardingColorInteractor, router: OnboardingColorRouter) {
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
