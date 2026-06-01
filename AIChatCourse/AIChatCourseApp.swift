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
 module1: View Layers
 module2: Data Layers (firebase)
 module3: MVP Essentials: Core Updates
 module4: MVP Essentials: Growth Updates
 module5: Testing & CI/CD
 module6: Enterprise Architecture: MVVM
 module7: Enterprise Architecture: VIPER
 module8: Swift Packages
 */

// 4. MVVM Architecture
/*
 - DataManager is shared accross the application, but access from the ViewModel
 - ViewModels are responsible for business logic
 - ViewModel holds the array of products

 Pros:
 - Seperated the View from the business logic
 - Business logic is now testable
 - View code is much cleaner

 Cons:
 - More difficult to set up and inject dependencies
 - ViewModel lifecycle is outside of View lifecycle (cannot use SwiftUI Property Wrappers)
 */

/*
 DI: Dependency Injection
 https://github.com/Swinject/Swinject
 */

@main
struct AIChatCourseApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            AppView()
                .environment(delegate.dependencies.container)
                .environment(delegate.dependencies.purchaseManager)
                .environment(delegate.dependencies.aiManager)
                .environment(delegate.dependencies.avatarManager)
                .environment(delegate.dependencies.userManager)
                .environment(delegate.dependencies.authManager)
                .environment(delegate.dependencies.chatManager)
                .environment(delegate.dependencies.logManager)
                .environment(delegate.dependencies.pushManager)
                .environment(delegate.dependencies.abtestManager)
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

/// 存储所有的 manager
@MainActor
@Observable
class DependencyContainer {
    private var managers: [String: Any] = [:]

    /// 注册 manager
    func regiser<T>(_ type: T.Type, manager: T) {
        let key = "\(type)"
        managers[key] = manager
    }

    func register<T>(_ type: T.Type, manager: () -> T) {
        let key = "\(type)"
        managers[key] = manager()
    }

    /// 获取 manager
    func resolve<T>(_ type: T.Type) -> T? {
        let key = "\(type)"
        return managers[key] as? T
    }
}

struct Dependencies {
    let container: DependencyContainer

    let authManager: AuthManager
    let userManager: UserManager
    let aiManager: AIManager
    let avatarManager: AvatarManager
    let chatManager: ChatManager
    let logManager: LogManager
    let pushManager: PushManager
    let abtestManager: ABTestManager
    let purchaseManager: PurchaseManager

    // swiftlint:disable:next function_body_length
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
            abtestManager = ABTestManager(service: MockABTestService(), logManager: logManager)
            purchaseManager = PurchaseManager(service: MockPurchaseService(), logManager: logManager)
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
            abtestManager = ABTestManager(service: LocalABTestService(), logManager: logManager)
            purchaseManager = PurchaseManager(
                service: RevenueCatPurchaseService(apiKey: Keys.revenueCatApiKey), // StoreKitPurchaseService(),
                logManager: logManager
            )
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
            abtestManager = ABTestManager(service: FirebaseABTestService(), logManager: logManager)
            purchaseManager = PurchaseManager(service: StoreKitPurchaseService(), logManager: logManager)
            print("This is Production env!") // 这里添加打印, 因为 release 环境取消了 debug executable, 断点没有用
        }

        pushManager = PushManager(logManager: logManager)

        // 创建 container
        let container = DependencyContainer()
        // 注册 manager
        container.regiser(AuthManager.self, manager: authManager)
        container.regiser(UserManager.self, manager: userManager)
        container.regiser(AIManager.self, manager: aiManager)
        container.regiser(AvatarManager.self, manager: avatarManager)
        container.regiser(ChatManager.self, manager: chatManager)
        container.regiser(LogManager.self, manager: logManager)
        container.regiser(PushManager.self, manager: pushManager)
        container.regiser(ABTestManager.self, manager: abtestManager)
        container.regiser(PurchaseManager.self, manager: purchaseManager)
        self.container = container
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
        self
            .environment(DevPreview.shared.container)
            .environment(PurchaseManager(service: MockPurchaseService()))
            .environment(AIManager(service: MockAIService()))
            .environment(AvatarManager(service: MockAvatarService()))
            .environment(UserManager(services: MockUserServices(user: isSignedIn ? .mock : nil)))
            .environment(AuthManager(service: MockAuthService(user: isSignedIn ? .mock(isAnonymous: false) : nil)))
            .environment(ChatManager(service: MockChatService()))
            .environment(LogManager(services: []))
            .environment(PushManager())
            .environment(ABTestManager(service: MockABTestService()))
            .environment(AppState())
    }
}

@MainActor
class DevPreview {
    static let shared = DevPreview()

    // 每次调用container, 都会创建一个新的
    var container: DependencyContainer {
        // 创建 container
        let container = DependencyContainer()
        // 注册 manager
        container.regiser(AuthManager.self, manager: authManager)
        container.regiser(UserManager.self, manager: userManager)
        container.regiser(AIManager.self, manager: aiManager)
        container.regiser(AvatarManager.self, manager: avatarManager)
        container.regiser(ChatManager.self, manager: chatManager)
        container.regiser(LogManager.self, manager: logManager)
        container.regiser(PushManager.self, manager: pushManager)
        container.regiser(ABTestManager.self, manager: abtestManager)
        container.regiser(PurchaseManager.self, manager: purchaseManager)
        return container
    }

    let authManager: AuthManager
    let userManager: UserManager
    let aiManager: AIManager
    let avatarManager: AvatarManager
    let chatManager: ChatManager
    let logManager: LogManager
    let pushManager: PushManager
    let abtestManager: ABTestManager
    let purchaseManager: PurchaseManager

    init(isSignedIn: Bool = true) {
        authManager = AuthManager(service: MockAuthService(user: isSignedIn ? .mock(isAnonymous: false) : nil))
        userManager = UserManager(services: MockUserServices(user: isSignedIn ? .mock : nil))
        aiManager = AIManager(service: MockAIService())
        avatarManager = AvatarManager(service: MockAvatarService())
        chatManager = ChatManager(service: MockChatService())
        logManager = LogManager(services: [])
        pushManager = PushManager()
        abtestManager = ABTestManager(service: MockABTestService())
        purchaseManager = PurchaseManager(service: MockPurchaseService())
    }
}
