//
//  WelcomeView.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/3/16.
//

import SwiftUI

struct WelcomeView: View {
    @State var imageName: String = Constants.randomImageUrl
    @State private var showSignIn: Bool = false
    @Environment(AppState.self) private var appState
    @Environment(LogManager.self) private var logManager
    var body: some View {
        NavigationStack {
            VStack(spacing: 8) {
                ImageLoaderView(urlString: imageName)
                    .ignoresSafeArea()

                titleSection
                    .padding(.top, 24)

                ctaButtons
                    .padding(16)

                policyLinks
            }
        }
        .sheet(isPresented: $showSignIn) {
            CreateAccountView(
                title: "Sign in",
                subtitle: "Connect to an existing account.",
                onDidSignIn: { isNewUser in
                    handleDidSignIn(isNewUser: isNewUser)
                }
            )
            .presentationDetents([.medium])
        }
        .appearAnalyticsViewModifier(name: "WelcomeView")
    }
}

extension WelcomeView {
    private var titleSection: some View {
        VStack(spacing: 10) {
            Text("AI Chat 🤗")
                .font(.largeTitle)
                .fontWeight(.semibold)
            Text("YouTube @ SwiftfulThinking")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var ctaButtons: some View {
        VStack(spacing: 8) {
            NavigationLink {
                OnboardingIntroView()
            } label: {
                Text("Get Started")
                    .callToActionButton()
            }

            Text("Already have an account? Sign in!")
                .underline()
                .font(.body)
                .padding(10)
                .tappableBackground()
                .onTapGesture {
                    onSignInPressed()
                }
        }
    }

    private func onSignInPressed() {
        logManager.trackEvent(event: Event.signInPressed)
        showSignIn = true
    }

    private var policyLinks: some View {
        HStack {
            Link(destination: URL(string: Constants.termsOfServiceUrl)!) {
                Text("Terms of Service")
            }
            Circle()
                .fill(.accent)
                .frame(width: 4, height: 4)
            Link(destination: URL(string: Constants.privacyPolicyUrl)!) {
                Text("Privacy Policy")
            }
        }
    }
}

// MARK: 事件

extension WelcomeView {
    private func handleDidSignIn(isNewUser: Bool) {
        logManager.trackEvent(event: Event.didSignIn(isNewUser: isNewUser))
        if isNewUser {
            // do nothing, user gose through onboading
        } else {
            // push into tabbar view
            appState.updateViewState(showTabBarView: true)
        }
    }
}

extension WelcomeView {
    
    enum Event: LoggableEvent {
        case didSignIn(isNewUser: Bool)
        case signInPressed
        var eventName: String {
            switch self {
            case .didSignIn: return "WelcomeView_DidSignIn"
            case .signInPressed: return "WelcomeView_SignIn_Pressed"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .didSignIn(isNewUser: let isNewUser):
                return ["is_new_user": isNewUser]
            default:
                return nil
            }
        }
        
        var type: CustomLogType {
            switch self {
            default:
                return .analytic
            }
        }
    }
}


#Preview {
    WelcomeView()
}
