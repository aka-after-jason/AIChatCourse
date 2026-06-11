//
//  AppDelegate.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/6/8.
//
import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    var dependencies: Dependencies!
    var builder: RootBuilder!
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        let config: BuildConfiguration

        #if MOCK
        config = .mock(isSignedIn: true) // isSignedIn: default by true
        #elseif DEV
        config = .dev
        #else
        config = .prod
        #endif

        config.configure() // 先执行 FirebaseApp.configure()
        dependencies = Dependencies(config: config)
        builder = RootBuilder(
            interactor: RootInteractor(container: dependencies.container),
            loggedInRIB: {
                CoreBuilder(interactor: CoreInteractor(container: self.dependencies.container))
            },
            loggedOutRIB: {
                OnboardingBuilder(interactor: OnboardingInteractor(container: self.dependencies.container))
            }
        )

        // JPush
        // JPushManager.shared.configure(launchOptions: launchOptions)

        return true
    }
}

enum BuildConfiguration {
    case mock(isSignedIn: Bool)
    case dev
    case prod

    func configure() {
        switch self {
        case .mock:
            // Mock build does NOT run Firebase.
            break
        case .dev:
            // 加载plist
            let plist = Bundle.main.path(forResource: "GoogleService-Info-Dev", ofType: "plist")!
            let options = FirebaseOptions(contentsOfFile: plist)!
            FirebaseApp.configure(options: options)
        case .prod:
            // 加载plist
            let plist = Bundle.main.path(forResource: "GoogleService-Info-Prod", ofType: "plist")!
            let options = FirebaseOptions(contentsOfFile: plist)!
            FirebaseApp.configure(options: options)
        }
    }
}

// MARK: JPush

extension AppDelegate {
    /// JPush
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        JPushManager.shared.registerDeviceToken(deviceToken)
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("APNs 注册失败:", error.localizedDescription)
    }

    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        JPushManager.shared.handleRemoteNotification(userInfo)
        completionHandler(.newData)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        JPushManager.shared.cleanBadge()
    }
}

// MARK: AppDelegate in SwiftUI, Lifecycle

extension AppDelegate {
    /**
     可以在这里添加一系列的生命周期方法
     使用 AppDelegate 是 OC 或者 UIKit的方式
     在SwiftUI 中, 苹果推荐使用 scenePhase,但是 scenePhase 不够全面, 目前只有3种状态
        1. active
        2. inactive
        3. background

     推荐使用 NotificationCenter 来做, 更全面
     */
    func applicationDidEnterBackground(_ application: UIApplication) {}
    func applicationWillTerminate(_ application: UIApplication) {}
}
