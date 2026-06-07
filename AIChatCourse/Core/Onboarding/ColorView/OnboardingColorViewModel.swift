//
//  OnboardingColorViewModel.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/6/7.
//
import SwiftUI

protocol OnboardingColorViewModelInteractor {}

extension CoreInteractor: OnboardingColorViewModelInteractor {}

@MainActor
@Observable
final class OnboardingColorViewModel {
    private let interactor: OnboardingColorViewModelInteractor
    init(interactor: OnboardingColorViewModelInteractor) {
        self.interactor = interactor
    }

    let colors: [Color] = [.red, .green, .orange, .blue, .mint, .purple, .cyan, .teal, .indigo]
    private(set) var selectedColor: Color?

    func onColorPressed(color: Color) {
        selectedColor = color
    }

    func onContinueButtonPressed(path: Binding<[NavOnboardingPathOption]>) {
        guard let selectedColor else { return }
        path.wrappedValue.append(.completedView(selectedColor: selectedColor))
    }
}
