//
//  RootBuilder.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/6/11.
//
import SwiftUI

@MainActor
struct RootBuilder: Builder {
    let interactor: RootInteractor
    let loggedInRIB: Builder
    
    func build() -> AnyView {
        appView().any()
    }
    
    func appView() -> some View {
        AppView(
            viewModel: AppViewModel(interactor: interactor),
            tabbarView: {
                loggedInRIB.build()
            },
            onboardingView: {
                Text("onboardingView")
            }
        )
    }
}

@MainActor
struct RootInteractor {
    private let authManager: AuthManager
    private let appState: AppState
    private let logManager: LogManager
    private let userManager: UserManager
    private let purchaseManager: PurchaseManager
    
    init(container: DependencyContainer) {
        self.authManager = container.resolve(AuthManager.self)!
        self.userManager = container.resolve(UserManager.self)!
        self.logManager = container.resolve(LogManager.self)!
        self.purchaseManager = container.resolve(PurchaseManager.self)!
        self.appState = container.resolve(AppState.self)!
    }
    
    var authUser: UserAuthInfoModel? {
        authManager.authUser
    }
    
    var showTabBar: Bool {
        appState.showTabBar
    }
    
    func trackEvent(event: any LoggableEvent) {
        logManager.trackEvent(event: event)
    }
    
    func trackEvent(eventName: String, parameters: [String: Any]?, type: CustomLogType) {
        logManager.trackEvent(eventName: eventName, parameters: parameters, type: type)
    }
    
    func login(user: UserAuthInfoModel, isNewUser: Bool) async throws {
        try await userManager.login(auth: user, isNewUser: isNewUser)
        try await purchaseManager.logIn(userId: user.uid, attributes: PurchaseProfileAttributes(
            email: user.email,
            firebaseAppInstanceID: FirebaseAnalyticsService.appInstanceID,
            mixpanelDistinctID: MixpanelService.distinctId
        ))
    }
    
    func signInAnonymously() async throws -> (user: UserAuthInfoModel, isNewUser: Bool) {
        try await authManager.signInAnonymously()
    }
}

@MainActor
struct RootRouter {
    let router: Router
    let builder: RootBuilder
}
