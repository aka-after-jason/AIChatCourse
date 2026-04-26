//
//  RemoteUserService.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/4/26.
//

protocol RemoteUserService {
    func saveUser(user: UserModel) async throws
    func addStreamUserListener(userId: String) -> AsyncThrowingStream<UserModel, Error>
    func deleteUser(userId: String) async throws
    func markOnboardingCompleted(userId: String, profileColorHex: String) async throws
}
