//
//  OnboardingIntroInteractor.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/6/10.
//
import SwiftUI

@MainActor
protocol OnboardingIntroInteractor {
    var activeABTestModel: ActiveABTestModel { get }
}
extension CoreInteractor: OnboardingIntroInteractor {}
