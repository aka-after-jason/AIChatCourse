//
//  AppView.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/3/16.
//
import SwiftfulUI
import SwiftUI

// tabbar - signed in
// onboarding - signed out

struct AppView<TabbarView: View, OnboardingView: View>: View {
    // @Environment(\.scenePhase) private var scenePhase // LifeCycle: SwiftUI 使用这个
    @State var viewModel: AppViewModel
    @ViewBuilder var tabbarView: () -> TabbarView
    @ViewBuilder var onboardingView: () -> OnboardingView
    var body: some View {
        // RootView 来自 SwiftfulUI 框架
        RootView(
            delegate: RootDelegate(
                onApplicationDidAppear: nil,
                onApplicationWillEnterForeground: { _ in
                    Task { await viewModel.checkUserStatus() }
                },
                onApplicationDidBecomeActive: nil,
                onApplicationWillResignActive: nil,
                onApplicationDidEnterBackground: nil,
                onApplicationWillTerminate: nil
            )
        ) {
            AppViewBuilder(
                showTabBar: viewModel.showTabBar,
                tabbarView: {
                    tabbarView()
                },
                onboardingView: {
                    onboardingView()
                }
            )
            // 由于使用了 @Observable, 这里需要使用 environment,不是 environmentObject
            // .environment(<#T##object: (Observable & AnyObject)?##(Observable & AnyObject)?#>) // 用于class, 且遵循了 @Observable
            // .environment(<#T##keyPath: WritableKeyPath<EnvironmentValues, V>##WritableKeyPath<EnvironmentValues, V>#>, <#T##value: V##V#>) // 用于struct
            .task {
                await viewModel.checkUserStatus()
            }
            /*
             .task {
                 await getDataFromMyNewEndpoint()
             }
              */
            .task {
                try? await Task.sleep(for: .seconds(2))
                await viewModel.showATTPromptIfNeeded()
            }
            // 监听 appState 中的 showTabBar
            .onChange(of: viewModel.showTabBar) { _, showTabBar in
                if !showTabBar {
                    Task { await viewModel.checkUserStatus() }
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
}

#Preview("AppView Tabbar") {
    let container = DevPreview.shared.container
    container.regiser(UserManager.self, manager: UserManager(services: MockUserServices(user: .mock)))
    container.regiser(AuthManager.self, manager: AuthManager(service: MockAuthService(user: .mock(isAnonymous: true))))
    container.regiser(AppState.self, manager: AppState(showTabBar: true))
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    return builder.appView()
        .previewEnvironment()
}

#Preview("AppView Onboarding") {
    let container = DevPreview.shared.container
    container.regiser(UserManager.self, manager: UserManager(services: MockUserServices(user: nil)))
    container.regiser(AuthManager.self, manager: AuthManager(service: MockAuthService(user: nil)))
    container.regiser(AppState.self, manager: AppState(showTabBar: false))
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    return builder.appView()
    .previewEnvironment()
}
