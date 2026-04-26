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
    private(set) var currentUser: UserModel?
    private var listenerTask: Task<Void, Never>? // 需要泛型参数
    
    init(services: UserServices) {
        self.remote = services.remote
        self.local = services.local
        self.currentUser = local.getCurrentUser() // synchronous
        print("Loaded currentUser on launch: \(String(describing: currentUser?.userId))")
        print(NSHomeDirectory())
    }
    
    func login(auth: UserAuthInfoModel, isNewUser: Bool) async throws {
        let creationVersion = isNewUser ? Utilities.appVersion : nil
        let user = UserModel(auth: auth, creationVersion: creationVersion)
        try await remote.saveUser(user: user)
        addCurrentUserListener(userId: auth.uid)
    }
    
    private func addCurrentUserListener(userId: String) {
        listenerTask?.cancel()
        listenerTask = Task {
            do {
                for try await value in remote.addStreamUserListener(userId: userId) {
                    self.currentUser = value
                    self.saveCurrentUserLocally()
                    print("Successfully listened to user: \(value.userId)")
                }
            } catch {
                print("Error with adding listener to user: \(error)")
            }
        }
    }
    
    private func saveCurrentUserLocally() {
        do {
            try local.saveCurrentUser(user: currentUser)
            print("Success saved currentUser locally!")
        } catch {
            print("Failed to save currentUser locally: \(error)")
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
    }
    
    func deleteUser() async throws {
        let uid = try currentUserId()
        try await remote.deleteUser(userId: uid)
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
