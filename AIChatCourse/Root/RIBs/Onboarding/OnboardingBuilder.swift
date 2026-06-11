//
//  OnboardingBuilder.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/6/11.
//

import SwiftUI

@MainActor
struct OnboardingBuilder: Builder {
    let interactor: OnboardingInteractor

    func build() -> AnyView {
        welcomeView().any()
    }

    // MARK: WelcomeView

    func welcomeView() -> some View {
        RouterView { router in
            WelcomeView(
                viewModel: WelcomePresenter(interactor: interactor, router: OnboardingRouter(router: router, builder: self))
            )
        }
    }

    // MARK: Onboarding

    func onboardingIntroView(router: Router, delegate: OnboardingIntroDelete) -> some View {
        OnboardingIntroView(
            presenter: OnboardingIntroPresenter(
                interactor: interactor,
                router: OnboardingRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }

    func onboardingColorView(router: Router, delegate: OnboardingColorDelete) -> some View {
        OnboardingColorView(
            presenter: OnboardingColorPresenter(
                interactor: interactor,
                router: OnboardingRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }

    func onboardingCommunityView(router: Router, delegate: OnboardingCommunityDelete) -> some View {
        OnboardingCommunityView(
            presenter: OnboardingCommunityPresenter(
                interactor: interactor,
                router: OnboardingRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }

    func onboardingCompletedView(router: Router, delegate: OnboardingCompletedDelete) -> some View {
        OnboardingCompletedView(
            presenter: OnboardingCompletedPresenter(
                interactor: interactor,
                router: OnboardingRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }

    // MARK: CreateAccountView

    func createAccountView(router: Router, delegate: CreateAccountDelegate = CreateAccountDelegate()) -> some View {
        CreateAccountView(
            presenter: CreateAccountPresenter(
                interactor: interactor,
                router: OnboardingRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }

    func createAccountView(router: Router) -> some View {
        CreateAccountView(
            presenter: CreateAccountPresenter(
                interactor: interactor,
                router: OnboardingRouter(router: router, builder: self)
            )
        )
    }
}
