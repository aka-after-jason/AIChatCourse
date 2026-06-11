//
//  OnboardingInteractor.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/6/11.
//
import SwiftUI

@MainActor
struct OnboardingInteractor {
    private let abtestManager: ABTestManager
    private let logManager: LogManager
    private let appState: AppState
    private let userManager: UserManager
    private let purchaseManager: PurchaseManager
    private let authManager: AuthManager
    
    init(container: DependencyContainer) {
        abtestManager = container.resolve(ABTestManager.self)!
        logManager = container.resolve(LogManager.self)!
        appState = container.resolve(AppState.self)!
        userManager = container.resolve(UserManager.self)!
        purchaseManager = container.resolve(PurchaseManager.self)!
        authManager = container.resolve(AuthManager.self)!
    }
    
    var activeABTestModel: ActiveABTestModel {
        abtestManager.activeABTestModel
    }
    
    func trackEvent(event: LoggableEvent) {
        logManager.trackEvent(event: event)
    }
    
    func updateAppState(showTabBarView: Bool) {
        appState.updateViewState(showTabBarView: showTabBarView)
    }
    
    func markOnboardingCompleteForCurrentUser(profileColorHex: String) async throws {
        try await userManager.markOnboardingCompleteForCurrentUser(profileColorHex: profileColorHex)
    }
    
    func signInApple() async throws -> (user: UserAuthInfoModel, isNewUser: Bool) {
        try await authManager.signInApple()
    }
    
    /// 用户登录和订阅登录放到了一起
    func login(user: UserAuthInfoModel, isNewUser: Bool) async throws {
        try await userManager.login(auth: user, isNewUser: isNewUser)
        try await purchaseManager.logIn(userId: user.uid, attributes: PurchaseProfileAttributes(
            email: user.email,
            firebaseAppInstanceID: FirebaseAnalyticsService.appInstanceID,
            mixpanelDistinctID: MixpanelService.distinctId
        ))
    }
}
