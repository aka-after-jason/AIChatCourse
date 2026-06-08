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
    @Environment(CoreBuilder.self) private var builder
    let path: Binding<[NavOnboardingPathOption]>
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: NavOnboardingPathOption.self) { newValue in
                switch newValue {
                case .colorView:
                    builder.onboardingColorView(delegate: OnboardingColorDelete(path: path))
                case .communityView:
                    builder.onboardingCommunityView(delegate: OnboardingCommunityDelete(path: path))
                case .introView:
                    builder.onboardingIntroView(delegate: OnboardingIntroDelete(path: path))
                case .completedView(selectedColor: let selectedColor):
                    builder.onboardingCompletedView(delegate: OnboardingCompletedDelete(selectedColor: selectedColor))
                }
            }
    }
}

extension View {
    func customNavDestiForOnboardingModule(path: Binding<[NavOnboardingPathOption]>) -> some View {
        modifier(NavDestiForOnboardingModuleViewModifier(path: path))
    }
}
