//
//  UserManager.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/4/25.
//

import SwiftfulUtilities
import SwiftUI

@MainActor
@Observable
final class UserManager { // 可以叫 UserStore, UserRepository
    private let remote: RemoteUserService
    private let local: LocalUserPersistance
    private let logManager: LogManager? // 因为这里不是View, 不能使用 @Environment, 采用注入的方式
    private(set) var currentUser: UserModel?
    private var listenerTask: Task<Void, Never>? // 需要泛型参数
    
    init(services: UserServices, logManager: LogManager? = nil) {
        self.remote = services.remote
        self.local = services.local
        self.currentUser = local.getCurrentUser() // synchronous
        self.logManager = logManager
        print("Loaded currentUser on launch: \(String(describing: currentUser?.userId))")
        print(NSHomeDirectory())
    }
    
    func login(auth: UserAuthInfoModel, isNewUser: Bool) async throws {
        let creationVersion = isNewUser ? Utilities.appVersion : nil
        let user = UserModel(auth: auth, creationVersion: creationVersion)
        logManager?.trackEvent(event: Event.logInStart(user: user))
        try await remote.saveUser(user: user)
        logManager?.trackEvent(event: Event.logInSuccess(user: user))
        addCurrentUserListener(userId: auth.uid)
    }
    
    private func addCurrentUserListener(userId: String) {
        logManager?.trackEvent(event: Event.remoteListenerStart)
        listenerTask?.cancel()
        listenerTask = Task {
            do {
                for try await value in remote.addStreamUserListener(userId: userId) {
                    self.currentUser = value
                    logManager?.trackEvent(event: Event.remoteListenerSuccess(user: value))
                    logManager?.addUserProperties(dict: value.eventParameters, isHighPriority: true)
                    self.saveCurrentUserLocally()
                }
            } catch {
                logManager?.trackEvent(event: Event.remoteListenerFail(error: error))
            }
        }
    }
    
    private func saveCurrentUserLocally() {
        logManager?.trackEvent(event: Event.saveLocalStart(user: currentUser))
        Task {
            do {
                try local.saveCurrentUser(user: currentUser)
                logManager?.trackEvent(event: Event.saveLocalSuccess(user: currentUser))
            } catch {
                logManager?.trackEvent(event: Event.saveLocalFail(error: error))
            }
        }
    }
    
    func markOnboardingCompleteForCurrentUser(profileColorHex: String) async throws {
        let uid = try currentUserId()
        try await remote.markOnboardingCompleted(userId: uid, profileColorHex: profileColorHex)
    }
    
    func signOut() {
        listenerTask?.cancel()
        listenerTask = nil
        currentUser = nil
        logManager?.trackEvent(event: Event.signOut)
    }
    
    func deleteUser() async throws {
        logManager?.trackEvent(event: Event.deleteAccountStart)
        let uid = try currentUserId()
        try await remote.deleteUser(userId: uid)
        logManager?.trackEvent(event: Event.deleteAccountSuccess)
        signOut()
    }
    
    private func currentUserId() throws -> String {
        guard let uid = currentUser?.userId else {
            throw UserManagerError.noUserId
        }
        return uid
    }
    
    enum UserManagerError: LocalizedError {
        case noUserId
    }
}

extension UserManager {
    
    enum Event: LoggableEvent {
        case logInStart(user: UserModel)
        case logInSuccess(user: UserModel)
        case remoteListenerStart
        case remoteListenerSuccess(user: UserModel)
        case remoteListenerFail(error: Error)
        case saveLocalStart(user: UserModel?)
        case saveLocalSuccess(user: UserModel?)
        case saveLocalFail(error: Error)
        case signOut
        case deleteAccountStart
        case deleteAccountSuccess
        var eventName: String {
            switch self {
            case .logInStart: return "UserManager_LogIn_Start"
            case .logInSuccess: return "UserManager_LogIn_Success"
            case .remoteListenerStart: return "UserManager_RemoteListener_Start"
            case .remoteListenerSuccess: return "UserManager_RemoteListener_Success"
            case .remoteListenerFail: return "UserManager_RemoteListener_Fail"
            case .saveLocalStart: return "UserManager_SaveLocal_Start"
            case .saveLocalSuccess: return "UserManager_SaveLocal_Success"
            case .saveLocalFail: return "UserManager_SaveLocal_Fail"
            case .signOut: return "UserManager_SignOut"
            case .deleteAccountStart: return "UserManager_DeleteAccount_Start"
            case .deleteAccountSuccess: return "UserManager_DeleteAccount_Success"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .logInStart(user: let user), .logInSuccess(user: let user), .remoteListenerSuccess(user: let user):
                return user.eventParameters
            case .saveLocalStart(user: let user), .saveLocalSuccess(user: let user):
                return user?.eventParameters
            case .saveLocalFail(error: let error), .remoteListenerFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: CustomLogType {
            switch self {
            case .saveLocalFail, .remoteListenerFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
}
