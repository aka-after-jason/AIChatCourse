//
//  NavOnboardingPathOption.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/6/7.
//
import SwiftUI
import Foundation

enum NavOnboardingPathOption: Hashable {
    case colorView
    case communityView
    case introView
    case completedView(selectedColor: Color)
}

struct NavDestiForOnboardingModuleViewModifier: ViewModifier {
    @Environment(DependencyContainer.self) private var container
    let path: Binding<[NavOnboardingPathOption]>
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: NavOnboardingPathOption.self) { newValue in
                switch newValue {
                case .colorView:
                    OnboardingColorView(
                        viewModel: OnboardingColorViewModel(interactor: CoreInteractor(container: container)),
                        path: path
                    )
                case .communityView:
                    OnboardingCommunityView(
                        viewModel: OnboardingCommunityViewModel(interactor: CoreInteractor(container: container)),
                        path: path
                    )
                case .introView:
                    OnboardingIntroView(
                        viewModel: OnboardingIntroViewModel(interactor: CoreInteractor(container: container)),
                        path: path
                    )
                case .completedView(selectedColor: let selectedColor):
                    OnboardingCompletedView(
                        viewModel: OnboardingCompletedViewModel(interactor: CoreInteractor(container: container)),
                        selectedColor: selectedColor
                    )
                }
            }
    }
}

extension View {
    func customNavDestiForOnboardingModule(path: Binding<[NavOnboardingPathOption]>) -> some View {
        modifier(NavDestiForOnboardingModuleViewModifier(path: path))
    }
}
