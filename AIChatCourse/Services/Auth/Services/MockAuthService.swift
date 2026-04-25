//
//  MockAuthService.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/4/25.
//
import Foundation

struct MockAuthService: AuthService {
    let currentUser: UserAuthInfoModel?
    init(currentUser: UserAuthInfoModel? = nil) {
        self.currentUser = currentUser
    }
    
    func getAuthenticatedUser() -> UserAuthInfoModel? {
        currentUser
    }
    
    func signInAnonymously() async throws -> (user: UserAuthInfoModel, isNewUser: Bool) {
        let user = UserAuthInfoModel.mock(isAnonymous: true)
        return (user, true)
    }
    
    func signInApple() async throws -> (user: UserAuthInfoModel, isNewUser: Bool) {
        let user = UserAuthInfoModel.mock(isAnonymous: false)
        return (user, false)
    }
    
    func signOut() throws {
        
    }
    
    func deleteAccount() async throws {
        
    }
    
    
}
