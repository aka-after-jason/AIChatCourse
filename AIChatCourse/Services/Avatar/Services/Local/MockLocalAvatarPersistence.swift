//
//  MockLocalAvatarPersistence.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/5/2.
//

struct MockLocalAvatarPersistence: LocalAvatarPersistence {
    func addRecentAvatar(avatar: AvatarModel) throws {
        
    }
    
    func getRecentAvatars() throws -> [AvatarModel] {
        AvatarModel.mocks.shuffled()
    }
}
