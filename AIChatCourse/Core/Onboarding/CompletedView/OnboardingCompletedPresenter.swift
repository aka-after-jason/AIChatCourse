//
//  OnboardingCompletedViewModel.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/6/7.
//
import SwiftUI

@MainActor
@Observable
final class OnboardingCompletedPresenter {
    private let interactor: OnboardingCompletedInteractor
    private let router: OnboardingCompletedRouter
    init(interactor: OnboardingCompletedInteractor, router: OnboardingCompletedRouter) {
        self.interactor = interactor
        self.router = router
    }

    private(set) var isCompletingProfileSetup: Bool = false

    func onFinishButtonPressed(selectedColor: Color) {
        // other logic to complete onboarding
        isCompletingProfileSetup = true
        interactor.trackEvent(event: Event.finishStart)
        Task {
            do {
                let hex = selectedColor.asHex()
                try await interactor.markOnboardingCompleteForCurrentUser(profileColorHex: hex)
                interactor.trackEvent(event: Event.finishSuccess(hex: hex))
                // dismiss screen
                isCompletingProfileSetup = false
                // show tabbar view
                interactor.updateAppState(showTabBarView: true)
            } catch {
                router.showAlert(error: error)
                interactor.trackEvent(event: Event.finishFail(error: error))
            }
        }
    }
}

extension OnboardingCompletedPresenter {
    enum Event: LoggableEvent {
        case finishStart
        case finishSuccess(hex: String)
        case finishFail(error: Error)
        var eventName: String {
            switch self {
            case .finishStart: return "OnboardingCompletedView_Finish_Start"
            case .finishSuccess: return "OnboardingCompletedView_Finish_Success"
            case .finishFail: return "OnboardingCompletedView_Finish_Fail"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .finishFail(error: let error):
                return error.eventParameters
            case .finishSuccess(hex: let hex):
                return ["profile_color_hex": hex]
            default:
                return nil
            }
        }

        var type: CustomLogType {
            switch self {
            case .finishFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
}
