//
//  ProfileViewTests.swift
//  AIChatCourseTests
//
//  Created by Elaine on 2026/6/1.
//

import Testing
import SwiftUI
@testable import AIChatCourse

// 在 MVVM 架构中测试

@MainActor
struct ProfileViewTests {

    @Test("LoadData does set current user")
    func testLoadDataDoesSetCurrentUser() async throws {
        let container = DependencyContainer()
        
        let authManager = AuthManager(service: MockAuthService())
        
        let mockUser = UserModel.mock
        let userManager = UserManager(services: MockUserServices(user: mockUser))
        
        let avatarManager = AvatarManager(service: MockAvatarService())
        
        let mockLogService = MockLogService()
        let logManager = LogManager(services: [mockLogService])
        
        container.regiser(AuthManager.self, manager: authManager)
        container.regiser(UserManager.self, manager: userManager)
        container.regiser(AvatarManager.self, manager: avatarManager)
        container.regiser(LogManager.self, manager: logManager)
        
        // Given
        let viewModel = ProfileViewModel(interactor: ProductProfileViewModelInteractor(container: container))
        
        // When
        await viewModel.loadData()
        
        // Then
        #expect(viewModel.currentUser?.userId == mockUser.userId)
    }

}
