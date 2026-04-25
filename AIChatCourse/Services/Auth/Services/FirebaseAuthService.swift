//
//  FirebaseAuthService.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/4/24.
//

import FirebaseAuth
import Foundation
import SignInAppleAsync
import SwiftUI

struct FirebaseAuthService: AuthService {
    func getAuthenticatedUser() -> UserAuthInfoModel? {
        guard let user = Auth.auth().currentUser else { return nil }
        return UserAuthInfoModel(user: user)
    }

    func signInAnonymously() async throws -> (user: UserAuthInfoModel, isNewUser: Bool) {
        let authDataResult = try await Auth.auth().signInAnonymously()
        return authDataResult.asUserAuthInfo
    }
    
    // MARK: 苹果登录步骤:
    // MARK: 1. xcode需要开启sign in with apple
    // MARK: 2. firebase -> authentication -> signin methond 添加 apple登录
    func signInApple() async throws -> (user: UserAuthInfoModel, isNewUser: Bool) {
        let helper = SignInWithAppleHelper()
        let response = try await helper.signIn()
        
        // 创建 credential, 因为 firebase 需要
        let credential = OAuthProvider.credential(
            providerID: AuthProviderID.apple,
            idToken: response.token,
            rawNonce: response.nonce
        )
        
        if let currentUser = Auth.auth().currentUser, currentUser.isAnonymous {
            do {
                // Try to link to existing anonymous account
                let authDataResult = try await currentUser.link(with: credential)
                return authDataResult.asUserAuthInfo
            } catch let error as NSError {
                let authError = AuthErrorCode(rawValue: error.code)
                switch authError {
                case .providerAlreadyLinked, .credentialAlreadyInUse:
                    if let secondaryCredential = error.userInfo["FIRAuthErrorUserInfoUpdatedCredentialKey"] as? AuthCredential {
                        let authDataResult = try await Auth.auth().signIn(with: secondaryCredential)
                        return authDataResult.asUserAuthInfo
                    }
                default:
                    break
                }
            }
        }
        
        // Otherwise sign in to new account
        let authDataResult = try await Auth.auth().signIn(with: credential)
        return authDataResult.asUserAuthInfo
    }
    
    func signOut() throws {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Failed to sign out: \(error.localizedDescription)")
        }
    }
    
    func deleteAccount() async throws {
        guard let currentUser = Auth.auth().currentUser else {
            throw CustomAuthError.userNotFound
        }
        try await currentUser.delete()
    }
    
    enum CustomAuthError: LocalizedError {
        case userNotFound
        
        var errorDescription: String? {
            switch self {
            case .userNotFound:
                return "Current authenticated user not found."
            }
        }
    }
}

// MARK: 对 firebase 提供的 AuthDataResult 扩展

extension AuthDataResult {
    /// 将 AuthDataResult 转成 自己定义的 UserAuthInfoModel
    var asUserAuthInfo: (user: UserAuthInfoModel, isNewUser: Bool) {
        let userAuthInfo = UserAuthInfoModel(user: user)
        let isNewUser = additionalUserInfo?.isNewUser ?? true
        return (userAuthInfo, isNewUser)
    }
}
