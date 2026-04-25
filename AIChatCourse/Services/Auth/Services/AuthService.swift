//
//  AuthService.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/4/25.
//

import SwiftUI

/// 扩展一个 keypath
extension EnvironmentValues {
    @Entry var authService: AuthService = MockAuthService() // by default
}

protocol AuthService {
    func getAuthenticatedUser() -> UserAuthInfoModel?
    func signInAnonymously() async throws -> (user: UserAuthInfoModel, isNewUser: Bool)
    func signInApple() async throws -> (user: UserAuthInfoModel, isNewUser: Bool)
    func signOut() throws
    func deleteAccount() async throws
}
