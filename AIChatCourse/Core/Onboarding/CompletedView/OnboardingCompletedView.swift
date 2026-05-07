//
//  OnboardingCompletedView.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/3/16.
//

import SwiftUI

struct OnboardingCompletedView: View {
    @Environment(AppState.self) private var appState
    @Environment(UserManager.self) private var userManager
    @Environment(LogManager.self) private var logManager
    var selectedColor: Color = .orange // 保存 OnboardingColorView 中选择的颜色
    @State private var isCompletingProfileSetup: Bool = false
    @State private var showAlert: AnyAppAlertItem?
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Setup complete!")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundStyle(selectedColor)

            Text("We've set up your profile and you're ready to start chatting.")
                .font(.title)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
        }
        .frame(maxHeight: .infinity)
        .safeAreaInset(edge: .bottom, content: {
            ctaButton
        })
        .toolbar(.hidden, for: .navigationBar)
        .padding(24)
        .appearAnalyticsViewModifier(name: "OnboardingCompletedView")
        .showCustomAlert(alertItem: $showAlert)
    }

    private var ctaButton: some View {
        AsyncCallToActionButton(
            isLoading: isCompletingProfileSetup,
            title: "Finish",
            action: onFinishButtonPressed
        )
    }

    func onFinishButtonPressed() {
        // other logic to complete onboarding
        isCompletingProfileSetup = true
        logManager.trackEvent(event: Event.finishStart)
        Task {
            do {
                let hex = selectedColor.asHex()
                try await userManager.markOnboardingCompleteForCurrentUser(profileColorHex: hex)
                logManager.trackEvent(event: Event.finishSuccess(hex: hex))
                // dismiss screen
                isCompletingProfileSetup = false
                appState.updateViewState(showTabBarView: true)
            } catch {
                showAlert = AnyAppAlertItem(error: error)
                logManager.trackEvent(event: Event.finishFail(error: error))
            }
        }
    }
}

extension OnboardingCompletedView {
    
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

#Preview {
    OnboardingCompletedView(selectedColor: .mint)
        .environment(UserManager(services: MockUserServices()))
        .environment(AppState())
}
