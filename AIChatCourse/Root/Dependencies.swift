//
//  Dependencies.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/6/8.
//
import SwiftUI

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
    let appState: AppState

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
            appState = AppState(showTabBar: isSignedIn)
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
            appState = AppState()
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
            appState = AppState()
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
        container.regiser(AppState.self, manager: appState)
        self.container = container
    }
}

// MARK: 将所有的 environment 都放在这里, 用于 preview

extension View {
    func previewEnvironment(isSignedIn: Bool = true) -> some View {
        environment(DevPreview.shared.container)
            .environment(LogManager(services: []))
            .environment(CoreBuilder(interactor: CoreInteractor(container: DevPreview.shared.container)))
    }
}

@MainActor
class DevPreview {
    static let shared = DevPreview()

    /// 每次调用container, 都会创建一个新的
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
        container.regiser(AppState.self, manager: appState)
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
    let appState: AppState

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
        appState = AppState()
    }
}
