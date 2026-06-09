//
//  AIChatCourseApp.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/3/15.
//
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
struct AppEntryPoint {
    static func main() {
        if Utilities.isUnitTesting {
            TestingApp.main()
        } else {
            AIChatCourseApp.main()
        }
    }
}

/// 主 app
struct AIChatCourseApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            delegate.builder.appView()
            .environment(delegate.dependencies.logManager)
        }
    }
}

/// 测试app
struct TestingApp: App {
    var body: some Scene {
        WindowGroup {
            Text("Testing")
        }
    }
}
