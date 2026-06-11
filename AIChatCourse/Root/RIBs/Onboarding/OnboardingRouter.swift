//
//  OnboardingRouter.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/6/11.
//
import SwiftUI

@MainActor
struct OnboardingRouter {
    let router: Router
    let builder: OnboardingBuilder
    
    func showOnboardingIntroView(delegate: OnboardingIntroDelete) {
        router.showScreen(.push) { router in
            builder.onboardingIntroView(router: router, delegate: delegate)
        }
    }
    
    func showOnboardingCommunityView(delegate: OnboardingCommunityDelete) {
        router.showScreen(.push) { router in
            builder.onboardingCommunityView(router: router, delegate: delegate)
        }
    }
    
    func showOnboardingColorView(delegate: OnboardingColorDelete) {
        router.showScreen(.push) { router in
            builder.onboardingColorView(router: router, delegate: delegate)
        }
    }
    
    func showOnboardingCompletedView(delegate: OnboardingCompletedDelete) {
        router.showScreen(.push) { router in
            builder.onboardingCompletedView(router: router, delegate: delegate)
        }
    }
    
    func showCreateAccountView(delegate: CreateAccountDelegate, onDisappear: (() -> Void)? = nil) {
        router.showScreen(.sheet) { router in
            builder.createAccountView(router: router, delegate: delegate)
                .presentationDetents([.medium])
                .onDisappear(perform: { onDisappear?() })
        }
    }
    
    func showAlert(error: Error) {
        
    }
    
    func dismissScreen() {
        router.dismissScreen()
    }
    
}
