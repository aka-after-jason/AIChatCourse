//
//  AppView.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/3/16.
//

import SwiftUI

// tabbar - signed in
// onboarding - signed out

struct AppView: View {
    // 由于使用了 @Observable, 这里需要使用 @State
    @State var appState: AppState = .init()
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    @Environment(LogManager.self) private var logManager
    var body: some View {
        AppViewBuilder(
            showTabBar: appState.showTabBar,
            tabbarView: {
                TabBarView()
            },
            onboardingView: {
                WelcomeView()
            }
        )
        .appearAnalyticsViewModifier(name: "AppView")
        // 由于使用了 @Observable, 这里需要使用 environment,不是 environmentObject
        .environment(appState) // TabBarView 和 WelcomeView 都能访问
        // .environment(<#T##object: (Observable & AnyObject)?##(Observable & AnyObject)?#>) // 用于class, 且遵循了 @Observable
        // .environment(<#T##keyPath: WritableKeyPath<EnvironmentValues, V>##WritableKeyPath<EnvironmentValues, V>#>, <#T##value: V##V#>) // 用于struct
        .task {
            await checkUserStatus()
        }
        // 监听 appState 中的 showTabBar
        .onChange(of: appState.showTabBar) { _, showTabBar in
            if !showTabBar {
                Task { await checkUserStatus() }
            }
        }
    }
}

enum Event: LoggableEvent {
    case existingAuthStart
    case existingAuthFail(error: Error)
    case anonymousAuthStart
    case anonymousAuthSuccess
    case anonymousAuthFail(error: Error)
    var eventName: String {
        switch self {
        case .existingAuthStart:    return "AppView_ExistingAuth_Start"
        case .existingAuthFail:     return "AppView_ExistingAuth_Fail"
        case .anonymousAuthStart:   return "AppView_AnonymousAuth_Start"
        case .anonymousAuthSuccess: return "AppView_AnonymousAuth_Success"
        case .anonymousAuthFail:    return "AppView_AnonymousAuth_Fail"
        }
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .existingAuthFail(error: let error), .anonymousAuthFail(error: let error):
            return error.eventParameters
        default:
            return nil
        }
    }
    
    var type: CustomLogType {
        switch self {
        case .existingAuthFail, .anonymousAuthFail:
            return .severe
        default:
            return .analytic
        }
    }
    
}


extension AppView {
    private func checkUserStatus() async {
        if let user = authManager.authUser {
            // user is authenticated
            logManager.trackEvent(event: Event.existingAuthStart)
            do {
                try await userManager.login(auth: user, isNewUser: false)
            } catch let error {
                logManager.trackEvent(event: Event.existingAuthFail(error: error))
                try? await Task.sleep(for: .seconds(3))
                await checkUserStatus()
            }
        } else {
            // user is not authenticated
            logManager.trackEvent(event: Event.anonymousAuthStart)
            do {
                let (user, isNewUser) = try await authManager.signInAnonymously()
                try await userManager.login(auth: user, isNewUser: isNewUser)
                logManager.trackEvent(event: Event.anonymousAuthSuccess)
            } catch {
                logManager.trackEvent(event: Event.anonymousAuthFail(error: error))
                try? await Task.sleep(for: .seconds(3))
                await checkUserStatus()
            }
        }
    }
}

#Preview("AppView Tabbar") {
    AppView(appState: AppState(showTabBar: true))
        .environment(UserManager(services: MockUserServices(user: .mock)))
        .environment(AuthManager(service: MockAuthService(user: .mock(isAnonymous: true))))
}

#Preview("AppView Onboarding") {
    AppView(appState: AppState(showTabBar: false))
        .environment(UserManager(services: MockUserServices(user: nil)))
        .environment(AuthManager(service: MockAuthService(user: nil)))
}
