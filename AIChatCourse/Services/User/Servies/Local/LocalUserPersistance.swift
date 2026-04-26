//
//  LocalUserPersistance.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/4/26.
//

protocol LocalUserPersistance {
    func getCurrentUser() -> UserModel?
    func saveCurrentUser(user: UserModel?) throws
}
