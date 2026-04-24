//
//  FirebaseAuthService.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/4/24.
//

import FirebaseAuth
import Foundation
import SwiftUI

/// 扩展一个 keypath
extension EnvironmentValues {
    @Entry var authService: FirebaseAuthService = .init()
}

struct FirebaseAuthService {
    func getAuthenticatedUser() -> UserAuthInfoModel? {
        guard let user = Auth.auth().currentUser else { return nil }
        return UserAuthInfoModel(user: user)
    }

    func signInAnonymously() async throws -> (user: UserAuthInfoModel, isNewUser: Bool) {
        let authDataResult = try await Auth.auth().signInAnonymously()
        let userAuthInfo = UserAuthInfoModel(user: authDataResult.user)
        let isNewUser = authDataResult.additionalUserInfo?.isNewUser ?? true
        return (userAuthInfo, isNewUser)
    }
}

struct UserAuthInfoModel {
    let uid: String
    let email: String?
    let isAnonymous: Bool
    let creationDate: Date?
    let lastSignInDate: Date?

    init(
        uid: String,
        email: String? = nil,
        isAnonymous: Bool = false,
        creationDate: Date? = nil,
        lastSignInDate: Date? = nil
    ) {
        self.uid = uid
        self.email = email
        self.isAnonymous = isAnonymous
        self.creationDate = creationDate
        self.lastSignInDate = lastSignInDate
    }

    init(user: User) { // User from firebase
        self.uid = user.uid
        self.email = user.email
        self.isAnonymous = user.isAnonymous
        self.creationDate = user.metadata.creationDate
        self.lastSignInDate = user.metadata.lastSignInDate
    }
}
