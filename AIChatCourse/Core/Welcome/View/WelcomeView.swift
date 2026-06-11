//
//  WelcomeView.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/3/16.
//

import SwiftUI

struct WelcomeView: View {
    @State var viewModel: WelcomePresenter
    var body: some View {
        VStack(spacing: 8) {
            ImageLoaderView(urlString: viewModel.imageName)
                .ignoresSafeArea()

            titleSection
                .padding(.top, 24)

            ctaButtons
                .padding(16)

            policyLinks
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
            Text("Get Started")
                .callToActionButton()
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .anyButton(.press, action: {
                    viewModel.onGetStartedPressed()
                })
                .accessibilityIdentifier("StartButton")
                .frame(maxWidth: 500)

            Text("Already have an account? Sign in!")
                .underline()
                .font(.body)
                .padding(10)
                .tappableBackground()
                .onTapGesture {
                    viewModel.onSignInPressed()
                }
        }
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

#Preview {
    let container = DevPreview.shared.container
    let builder = OnboardingBuilder(interactor: OnboardingInteractor(container: container))
    
    return builder.welcomeView()
        .previewEnvironment()
}
