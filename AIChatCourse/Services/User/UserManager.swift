//
//  UserManager.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/4/25.
//

import FirebaseFirestore
import SwiftfulFirestore
import SwiftfulUtilities
import SwiftUI

protocol UserService {
    func saveUser(user: UserModel) async throws
    func addStreamUserListener(userId: String) -> AsyncThrowingStream<UserModel, Error>
    func deleteUser(userId: String) async throws
    func markOnboardingCompleted(userId: String, profileColorHex: String) async throws
}

struct MockUserService: UserService {
    let currentUser: UserModel?
    init(currentUser: UserModel? = nil) {
        self.currentUser = currentUser
    }
    
    func saveUser(user: UserModel) async throws {}
    
    func addStreamUserListener(userId: String) -> AsyncThrowingStream<UserModel, any Error> {
        AsyncThrowingStream { continuation in
            if let currentUser {
                continuation.yield(currentUser)
            }
        }
    }
    
    func deleteUser(userId: String) async throws {}
    
    func markOnboardingCompleted(userId: String, profileColorHex: String) async throws {}
}

struct FirebaseUserService: UserService {
    var collection: CollectionReference {
        Firestore.firestore().collection(FirestoreConstants.userCollectionName)
    }
    
    func saveUser(user: UserModel) async throws {
        try collection.document(user.userId).setData(from: user, merge: true)
    }
    
    func addStreamUserListener(userId: String) -> AsyncThrowingStream<UserModel, Error> {
        collection.streamDocument(id: userId)
    }
    
    func deleteUser(userId: String) async throws {
        try await collection.document(userId).delete()
    }
    
    func markOnboardingCompleted(userId: String, profileColorHex: String) async throws {
        try await collection.document(userId).updateData([
            UserModel.CodingKeys.didCompletedOnboarding.rawValue: true,
            UserModel.CodingKeys.profileColorHex.rawValue: profileColorHex
        ])
    }
}

@MainActor
@Observable
final class UserManager { // 可以叫 UserStore, UserRepository
    private let service: UserService
    private(set) var currentUser: UserModel?
    private var listenerTask: Task<Void, Never>? // 需要泛型参数
    
    init(service: UserService) {
        self.service = service
    }
    
    func login(auth: UserAuthInfoModel, isNewUser: Bool) async throws {
        let creationVersion = isNewUser ? Utilities.appVersion : nil
        let user = UserModel(auth: auth, creationVersion: creationVersion)
        try await service.saveUser(user: user)
        addCurrentUserListener(userId: auth.uid)
    }
    
    private func addCurrentUserListener(userId: String) {
        listenerTask?.cancel()
        listenerTask = Task {
            do {
                for try await value in service.addStreamUserListener(userId: userId) {
                    self.currentUser = value
                    print("Successfully listened to user: \(value.userId)")
                }
            } catch {
                print("Error with adding listener to user: \(error)")
            }
        }
    }
    
    func markOnboardingCompleteForCurrentUser(profileColorHex: String) async throws {
        let uid = try currentUserId()
        try await service.markOnboardingCompleted(userId: uid, profileColorHex: profileColorHex)
    }
    
    func signOut() {
        listenerTask?.cancel()
        listenerTask = nil
        currentUser = nil
    }
    
    func deleteUser() async throws {
        let uid = try currentUserId()
        try await service.deleteUser(userId: uid)
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
