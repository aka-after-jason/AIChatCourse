//
//  AppView.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/3/16.
//

import FirebaseFunctions
import SwiftfulUI
import SwiftfulUtilities
import SwiftUI

// tabbar - signed in
// onboarding - signed out

struct AppView: View {
    // 由于使用了 @Observable, 这里需要使用 @State
    @State var appState: AppState = .init()
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    @Environment(LogManager.self) private var logManager
    @Environment(\.scenePhase) private var scenePhase // LifeCycle: SwiftUI 使用这个
    @Environment(PurchaseManager.self) private var purchaseManager
    var body: some View {
        // RootView 来自 SwiftfulUI 框架
        RootView(
            delegate: RootDelegate(
                onApplicationDidAppear: nil,
                onApplicationWillEnterForeground: { _ in
                    Task { await checkUserStatus() }
                },
                onApplicationDidBecomeActive: nil,
                onApplicationWillResignActive: nil,
                onApplicationDidEnterBackground: nil,
                onApplicationWillTerminate: nil
            )
        ) {
            AppViewBuilder(
                showTabBar: appState.showTabBar,
                tabbarView: {
                    TabBarView()
                },
                onboardingView: {
                    WelcomeView()
                }
            )
            // 由于使用了 @Observable, 这里需要使用 environment,不是 environmentObject
            .environment(appState) // TabBarView 和 WelcomeView 都能访问
            // .environment(<#T##object: (Observable & AnyObject)?##(Observable & AnyObject)?#>) // 用于class, 且遵循了 @Observable
            // .environment(<#T##keyPath: WritableKeyPath<EnvironmentValues, V>##WritableKeyPath<EnvironmentValues, V>#>, <#T##value: V##V#>) // 用于struct
            .task {
                await checkUserStatus()
            }
            /*
             .task {
                 await getDataFromMyNewEndpoint()
             }
              */
            .task {
                try? await Task.sleep(for: .seconds(2))
                await showATTPromptIfNeeded()
            }
            // 监听 appState 中的 showTabBar
            .onChange(of: appState.showTabBar) { _, showTabBar in
                if !showTabBar {
                    Task { await checkUserStatus() }
                }
            }

            // MARK: 这种方式也不够全面, 推荐使用 NotificationCenter 来处理

            /*
             .onChange(of: scenePhase) { _, newValue in
                 switch newValue {
                 case .active:
                     print("App is active")
                 case .inactive:
                     print("App is inactive")
                 case .background:
                     print("App is background")
                 @unknown default:
                     print("Unexpected state")
                 }
             }
              */

            // 想要监听哪个, 只需要修改 notificationName 参数
            /*
             .onNotificationRecieved(notificationName: UIApplication.willEnterForegroundNotification) { _ in
                 Task { await checkUserStatus() }
             }
              */
        }
    }

    /// Test
    /// 读取 firebase cloud functions
    func getDataFromMyNewEndpoint() async {
        logManager.trackEvent(eventName: "HelloDev:: Start")
        do {
            let result = try await Functions.functions().httpsCallable("helloDeveloper").call()
            let string = result.data as? String
            logManager.trackEvent(eventName: "HelloDev:: \(string ?? "nostring")")
        } catch {
            logManager.trackEvent(eventName: "HelloDev:: Error: \(error.localizedDescription)")
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
                try await purchaseManager.logIn(
                    userId: user.uid,
                    attributes: PurchaseProfileAttributes(email: user.email)
                )
            } catch {
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
                try await purchaseManager.logIn(userId: user.uid)
                JPushManager.shared.setAlias(user.uid)
                JPushManager.shared.setTags(["ios", "user"])
                logManager.trackEvent(event: Event.anonymousAuthSuccess)
            } catch {
                logManager.trackEvent(event: Event.anonymousAuthFail(error: error))
                try? await Task.sleep(for: .seconds(3))
                await checkUserStatus()
            }
        }
    }

    /// 苹果审核需要, 没有则不会通过
    private func showATTPromptIfNeeded() async {
        #if !DEBUG
        let status = await AppTrackingTransparencyHelper.requestTrackingAuthorization()
        logManager.trackEvent(event: Event.attStatus(dict: status.eventParameters))
        #endif
    }
}

extension AppView {
    enum Event: LoggableEvent {
        case existingAuthStart
        case existingAuthFail(error: Error)
        case anonymousAuthStart
        case anonymousAuthSuccess
        case anonymousAuthFail(error: Error)
        case attStatus(dict: [String: Any])
        var eventName: String {
            switch self {
            case .existingAuthStart: return "AppView_ExistingAuth_Start"
            case .existingAuthFail: return "AppView_ExistingAuth_Fail"
            case .anonymousAuthStart: return "AppView_AnonymousAuth_Start"
            case .anonymousAuthSuccess: return "AppView_AnonymousAuth_Success"
            case .anonymousAuthFail: return "AppView_AnonymousAuth_Fail"
            case .attStatus: return "AppView_ATTStatus"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .existingAuthFail(error: let error), .anonymousAuthFail(error: let error):
                return error.eventParameters
            case .attStatus(dict: let dict):
                return dict
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
