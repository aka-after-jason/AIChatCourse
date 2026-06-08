//
//  NavOnboardingPathOption.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/6/7.
//
import Foundation
import SwiftUI

enum NavOnboardingPathOption: Hashable {
    case colorView
    case communityView
    case introView
    case completedView(selectedColor: Color)
}

struct NavDestiForOnboardingModuleViewModifier: ViewModifier {
    let path: Binding<[NavOnboardingPathOption]>
    @ViewBuilder var onboardingColorView: (OnboardingColorDelete) -> AnyView
    @ViewBuilder var onboardingCommunityView: (OnboardingCommunityDelete) -> AnyView
    @ViewBuilder var onboardingIntroView: (OnboardingIntroDelete) -> AnyView
    @ViewBuilder var onboardingCompletedView: (OnboardingCompletedDelete) -> AnyView
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: NavOnboardingPathOption.self) { newValue in
                switch newValue {
                case .colorView:
                    onboardingColorView(OnboardingColorDelete(path: path))
                case .communityView:
                    onboardingCommunityView(OnboardingCommunityDelete(path: path))
                case .introView:
                    onboardingIntroView(OnboardingIntroDelete(path: path))
                case .completedView(selectedColor: let selectedColor):
                    onboardingCompletedView(OnboardingCompletedDelete(selectedColor: selectedColor))
                }
            }
    }
}

extension View {
    func customNavDestiForOnboardingModule(
        path: Binding<[NavOnboardingPathOption]>,
        @ViewBuilder onboardingColorView: @escaping (OnboardingColorDelete) -> AnyView,
        @ViewBuilder onboardingCommunityView: @escaping (OnboardingCommunityDelete) -> AnyView,
        @ViewBuilder onboardingIntroView: @escaping (OnboardingIntroDelete) -> AnyView,
        @ViewBuilder onboardingCompletedView: @escaping (OnboardingCompletedDelete) -> AnyView
    ) -> some View {
        modifier(
            NavDestiForOnboardingModuleViewModifier(
                path: path,
                onboardingColorView: onboardingColorView,
                onboardingCommunityView: onboardingCommunityView,
                onboardingIntroView: onboardingIntroView,
                onboardingCompletedView: onboardingCompletedView
            )
        )
    }
}
