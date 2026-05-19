//
//  AIChatCourseApp.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/3/15.
//

import FirebaseCore
import SwiftUI

// MARK: SwiftUI advanced architecture

// MARK: Firestore 创建在台湾直连

/*
 module1: view layers
 module2: data layers (firebase)
 */

@main
struct AIChatCourseApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            AppView()
                .environment(delegate.dependencies.aiManager)
                .environment(delegate.dependencies.avatarManager)
                .environment(delegate.dependencies.userManager)
                .environment(delegate.dependencies.authManager)
                .environment(delegate.dependencies.chatManager)
                .environment(delegate.dependencies.logManager)
                .environment(delegate.dependencies.pushManager)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    var dependencies: Dependencies!
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

struct Dependencies {
    let authManager: AuthManager
    let userManager: UserManager
    let aiManager: AIManager
    let avatarManager: AvatarManager
    let chatManager: ChatManager
    let logManager: LogManager
    let pushManager: PushManager

    init(config: BuildConfiguration) {
        // Multiple schemes
        // Mock - mock dependencies
        // Development - production denpendencies + some extra dev tools
        // Production - production denpendencies

        // Xcode 左侧点击项目蓝色图标 → 选中 Project → Info → Configurations
        // 新增一个 mock

        // 该项目创建了三个schemes
        // AIChatCourse-Mock 对应 Mock
        // AIChatCourse-Development 对应 debug
        // AIChatCourse-Production 对应 release

        // 设置编译标识- go to build Settings -> Other Swift Flags
        // 添加 Debug 对应 -DDEV (-D 表示编译参数, 必须要加)
        // 添加 Mock 对应 -DMOCK (-D 表示编译参数, 必须要加)

        // 创建三个bundle id
        // com.aka.AIChat.mock 对应 mock
        // com.aka.AIChat.dev 对应 development
        // com.aka.AIChat 对应 production

        // 修改对应的 display name
        // 新增了一个 APP_DISPLAY_NAME 字段: go to target -> build settings -> 点击 + 号, Add User-defined Setting
        // 在 info.plist 新增 Bundle display name 字段: $(APP_DISPLAY_NAME)

        switch config {
        case .mock(isSignedIn: let isSignedIn):
            // Mock
            logManager = LogManager(services: [
                ConsoleService(printParameters: true)
            ])
            authManager = AuthManager(service: MockAuthService(user: isSignedIn ? .mock(isAnonymous: false) : nil), logManager: logManager)
            userManager = UserManager(services: MockUserServices(user: isSignedIn ? .mock : nil), logManager: logManager)
            aiManager = AIManager(service: MockAIService())
            avatarManager = AvatarManager(service: MockAvatarService(), local: MockLocalAvatarPersistence())
            chatManager = ChatManager(service: MockChatService())
        case .dev:
            // DEV
            logManager = LogManager(services: [
                ConsoleService(printParameters: true),
                FirebaseAnalyticsService(),
                MixpanelService(token: Keys.mixpanelToken, loggingEnabled: false),
                FirebaseCrashlyticsService()
            ])
            authManager = AuthManager(service: FirebaseAuthService(), logManager: logManager)
            userManager = UserManager(services: ProductionUserServices(), logManager: logManager)
            aiManager = AIManager(service: OpenAIService())
            avatarManager = AvatarManager(service: FirebaseAvatarService(), local: SwiftDataLocalAvatarPersistence())
            chatManager = ChatManager(service: FirebaseChatService())
        case .prod:
            // Production
            logManager = LogManager(services: [
                FirebaseAnalyticsService(),
                MixpanelService(token: Keys.mixpanelToken),
                FirebaseCrashlyticsService()
            ])
            authManager = AuthManager(service: FirebaseAuthService(), logManager: logManager)
            userManager = UserManager(services: ProductionUserServices(), logManager: logManager)
            aiManager = AIManager(service: OpenAIService())
            avatarManager = AvatarManager(service: FirebaseAvatarService(), local: SwiftDataLocalAvatarPersistence())
            chatManager = ChatManager(service: FirebaseChatService())
            print("This is Production env!") // 这里添加打印, 因为 release 环境取消了 debug executable, 断点没有用
        }

        pushManager = PushManager(logManager: logManager)
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

// MARK: 将所有的 environment 都放在这里, 用于 preview

extension View {
    func previewEnvironment(isSignedIn: Bool = true) -> some View {
        environment(AIManager(service: MockAIService()))
            .environment(AvatarManager(service: MockAvatarService()))
            .environment(UserManager(services: MockUserServices(user: isSignedIn ? .mock : nil)))
            .environment(AuthManager(service: MockAuthService(user: isSignedIn ? .mock(isAnonymous: false) : nil)))
            .environment(ChatManager(service: MockChatService()))
            .environment(LogManager(services: []))
            .environment(PushManager())
            .environment(AppState())
    }
}
