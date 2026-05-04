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
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    var dependencies: Dependencies!
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()

        #if MOCK
        dependencies = Dependencies(config: .mock(isSignedIn: true)) // isSignedIn default by true
        #elseif DEV
        dependencies = Dependencies(config: .dev)
        #else
        dependencies = Dependencies(config: .prod)
        #endif
        return true
    }
}

enum BuildConfiguration {
    case mock(isSignedIn: Bool)
    case dev
    case prod
}

struct Dependencies {
    let authManager: AuthManager
    let userManager: UserManager
    let aiManager: AIManager
    let avatarManager: AvatarManager
    let chatManager: ChatManager

    init(config: BuildConfiguration) {
        // Multiple schemes
        // Mock - mock dependencies
        // Development - production denpendencies + some extra dev tools
        // Production - production denpendencies

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

        switch config {
        case .mock(isSignedIn: let isSignedIn):
            // Mock
            authManager = AuthManager(service: MockAuthService(user: isSignedIn ? .mock(isAnonymous: false) : nil))
            userManager = UserManager(services: MockUserServices(user: isSignedIn ? .mock : nil))
            aiManager = AIManager(service: MockAIService())
            avatarManager = AvatarManager(service: MockAvatarService(), local: MockLocalAvatarPersistence())
            chatManager = ChatManager(service: MockChatService())
        case .dev:
            // DEV
            authManager = AuthManager(service: FirebaseAuthService())
            userManager = UserManager(services: ProductionUserServices())
            aiManager = AIManager(service: OpenAIService())
            avatarManager = AvatarManager(service: FirebaseAvatarService(), local: SwiftDataLocalAvatarPersistence())
            chatManager = ChatManager(service: FirebaseChatService())
        case .prod:
            // Production
            authManager = AuthManager(service: FirebaseAuthService())
            userManager = UserManager(services: ProductionUserServices())
            aiManager = AIManager(service: OpenAIService())
            avatarManager = AvatarManager(service: FirebaseAvatarService(), local: SwiftDataLocalAvatarPersistence())
            chatManager = ChatManager(service: FirebaseChatService())
            print("This is Production env!") // 这里添加打印, 因为 release 环境取消了 debug executable, 断点没有用
        }
    }
}

// MARK: 将所有的 environment 都放在这里, 用于 preview

extension View {
    func previewEnvironment(isSignedIn: Bool = true) -> some View {
        environment(AIManager(service: MockAIService()))
            .environment(AvatarManager(service: MockAvatarService()))
            .environment(UserManager(services: MockUserServices(user: isSignedIn ? .mock : nil)))
            .environment(AuthManager(service: MockAuthService(user: isSignedIn ? .mock(isAnonymous: false) : nil)))
            .environment(ChatManager(service: MockChatService()))
            .environment(AppState())
    }
}
