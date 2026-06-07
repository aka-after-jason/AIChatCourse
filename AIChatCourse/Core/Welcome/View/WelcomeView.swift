//
//  WelcomeView.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/3/16.
//

import SwiftUI

struct WelcomeView: View {
    @State var viewModel: WelcomeViewModel
    @Environment(DependencyContainer.self) private var container
    @Environment(AppState.self) private var appState
    var body: some View {
        NavigationStack(path: $viewModel.path) {
            VStack(spacing: 8) {
                ImageLoaderView(urlString: viewModel.imageName)
                    .ignoresSafeArea()

                titleSection
                    .padding(.top, 24)

                ctaButtons
                    .padding(16)

                policyLinks
            }
            .customNavDestiForOnboardingModule(path: $viewModel.path)
        }
        .sheet(isPresented: $viewModel.showSignIn) {
            CreateAccountView(
                viewModel: CreateAccountViewModel(interactor: CoreInteractor(container: container)),
                title: "Sign in",
                subtitle: "Connect to an existing account.",
                onDidSignIn: { isNewUser in
                    viewModel.handleDidSignIn(
                        isNewUser: isNewUser,
                        onShowTabBarView: {
                            appState.updateViewState(showTabBarView: true)
                        }
                    )
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
    WelcomeView(viewModel: WelcomeViewModel(interactor: CoreInteractor(container: DevPreview.shared.container)))
        .previewEnvironment()
}
