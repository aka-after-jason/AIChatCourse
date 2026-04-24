//
//  AIChatCourseApp.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/3/15.
//

import FirebaseCore
import SwiftUI

// MARK: SwiftUI advanced architecture

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
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()

        return true
    }
}
