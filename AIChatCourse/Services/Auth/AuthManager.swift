//
//  AuthManager.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/4/25.
//

import SwiftUI

@MainActor
@Observable
final class AuthManager { // 实现 AuthService 协议中的所有方法
    
    private(set) var authUser: UserAuthInfoModel? // stored in memory
    private var service: AuthService
    private var listener: (any NSObjectProtocol)?
    
    init(service: AuthService) {
        self.service = service
        self.authUser = service.getAuthenticatedUser() // 获取 currentUser
        self.addAuthListener()
    }
    
    private func addAuthListener() {
        Task {
            for await value in service.addAuthenticatedUserListener(onListenerAttached: { listener in
                self.listener = listener
            }) {
                self.authUser = value
                print("CurrentUser listener success: \(value?.uid ?? "no uid")")
            }
        }
    }
    
    func getCurrentUserId() throws -> String {
        guard let uid = authUser?.uid else {
            throw AuthError.notSignedIn
        }
        return uid
    }
    
    func signInAnonymously() async throws -> (user: UserAuthInfoModel, isNewUser: Bool) {
        try await service.signInAnonymously()
    }

    func signInApple() async throws -> (user: UserAuthInfoModel, isNewUser: Bool) {
        try await service.signInApple()
    }

    func signOut() throws {
        try service.signOut()
        authUser = nil
    }

    func deleteAccount() async throws {
        try await service.deleteAccount()
        authUser = nil
    }
    
    enum AuthError: LocalizedError {
        case notSignedIn
    }
}
