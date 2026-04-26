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
                .environment(delegate.userManager)
                .environment(delegate.authManager)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    var authManager: AuthManager!
    var userManager: UserManager!
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        // 放在这里只会初始化一次
        authManager = AuthManager(service: FirebaseAuthService())
        userManager = UserManager(services: ProductionUserServices())

        return true
    }
}
