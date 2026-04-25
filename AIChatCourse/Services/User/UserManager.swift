//
//  UserManager.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/4/25.
//

import SwiftUI
import FirebaseFirestore
import SwiftfulUtilities

protocol UserService {
    func saveUser(user: UserModel) async throws
}

struct FirebaseUserService: UserService {
    var collection: CollectionReference {
        Firestore.firestore().collection(FirestoreConstants.userCollectionName)
    }
    
    func saveUser(user: UserModel) async throws {
        try collection.document(user.userId).setData(from: user, merge: true)
    }
}

@MainActor
@Observable
final class UserManager {
    private let service: UserService
    private(set) var currentUser: UserModel?
    
    init(service: UserService) {
        self.service = service
    }
    
    func login(auth: UserAuthInfoModel, isNewUser: Bool) async throws {
        let creationVersion = isNewUser ? Utilities.appVersion : nil
        let user = UserModel(auth: auth, creationVersion: creationVersion)
        try await service.saveUser(user: user)
    }
}
