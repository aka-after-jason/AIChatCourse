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
    private let service: AuthService
    private var listener: (any NSObjectProtocol)?
    private let logManager: LogManager?
    
    init(service: AuthService, logManager: LogManager? = nil) {
        self.service = service
        self.logManager = logManager
        self.authUser = service.getAuthenticatedUser() // 获取 currentUser
        self.addAuthListener()
    }
    
    private func addAuthListener() {
        logManager?.trackEvent(event: Event.authListenerStart)
        if let listener {
            service.removeAuthenticatedUserListener(listener: listener)
        }
        Task {
            for await value in service.addAuthenticatedUserListener(onListenerAttached: { listener in
                self.listener = listener
            }) {
                self.authUser = value
                logManager?.trackEvent(event: Event.authListenerSuccess(user: value))
                if let value {
                    logManager?.identifyUser(userId: value.uid, name: nil, email: value.email)
                    logManager?.addUserProperties(dict: value.eventParams, isHighPriority: true)
                    logManager?.addUserProperties(dict: Utilities.eventParameters, isHighPriority: false)
                }
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
        defer {
            addAuthListener()
        }
        return try await service.signInApple()
    }

    func signOut() throws {
        logManager?.trackEvent(event: Event.signOutStart)
        try service.signOut()
        authUser = nil
        logManager?.trackEvent(event: Event.signOutSuccess)
    }

    func deleteAccount() async throws {
        logManager?.trackEvent(event: Event.deleteAccountStart)
        try await service.deleteAccount()
        authUser = nil
        logManager?.trackEvent(event: Event.deleteAccountSuccess)
    }
    
    enum AuthError: LocalizedError {
        case notSignedIn
    }
}

extension AuthManager {
    
    enum Event: LoggableEvent {
        case authListenerStart
        case authListenerSuccess(user: UserAuthInfoModel?)
        case signOutStart
        case signOutSuccess
        case deleteAccountStart
        case deleteAccountSuccess
        var eventName: String {
            switch self {
            case .authListenerStart: return "AuthManager_AuthListener_Start"
            case .authListenerSuccess: return "AuthManager_AuthListener_Success"
            case .signOutStart: return "AuthManager_SignOut_Start"
            case .signOutSuccess: return "AuthManager_SignOut_Success"
            case .deleteAccountStart: return "AuthManager_DeleteAccount_Start"
            case .deleteAccountSuccess: return "AuthManager_DeleteAccount_Success"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .authListenerSuccess(user: let user):
                return user?.eventParams
            default:
                return nil
            }
        }
        
        var type: CustomLogType {
            switch self {
            default:
                return .analytic
            }
        }
    }
}
