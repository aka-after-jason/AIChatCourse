//
//  AvatarEntity.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/5/2.
//
import SwiftData
import SwiftUI

@Model
class AvatarEntity { // 必须是class
    @Attribute(.unique) var avatarId: String // avatarId 唯一
    var name: String?
    var characterOption: CharacterOption?
    var characterAction: CharacterAction?
    var characterLocation: CharacterLocation?
    var profileImageName: String?
    var authorId: String?
    var dateCreated: Date?
    var clickCount: Int?
    var dateAdded: Date
    init(from model: AvatarModel) {
        self.avatarId = model.avatarId
        self.name = model.name
        self.characterOption = model.characterOption
        self.characterAction = model.characterAction
        self.characterLocation = model.characterLocation
        self.profileImageName = model.profileImageName
        self.authorId = model.authorId
        self.dateCreated = model.dateCreated
        self.clickCount = model.clickCount
        self.dateAdded = .now
    }
    
    @MainActor
    func toModel() -> AvatarModel {
        AvatarModel(
            avatarId: avatarId,
            name: name,
            characterOption: characterOption,
            characterAction: characterAction,
            characterLocation: characterLocation,
            profileImageName: profileImageName,
            authorId: authorId,
            dateCreated: dateCreated,
            clickCount: clickCount
        )
    }
}
