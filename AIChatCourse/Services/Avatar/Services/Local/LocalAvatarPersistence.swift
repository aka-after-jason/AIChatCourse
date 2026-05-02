//
//  LocalAvatarPersistence.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/5/2.
//

protocol LocalAvatarPersistence {
    func addRecentAvatar(avatar: AvatarModel) throws
    func getRecentAvatars() throws -> [AvatarModel]
}
