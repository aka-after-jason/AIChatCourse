//
//  MockUserService.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/4/26.
//

struct MockUserService: RemoteUserService {
    let currentUser: UserModel?
    init(user: UserModel? = nil) {
        self.currentUser = user
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
