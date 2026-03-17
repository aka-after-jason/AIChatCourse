//
//  AvatarModel.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/3/17.
//

import Foundation

struct AvatarModel: Hashable {
    let avatarId: String
    let name: String?
    let characterOption: CharacterOption?
    let characterAction: CharacterAction?
    let characterLocation: CharacterLocation?
    let profileImageName: String?
    let authorId: String?
    let dateCreated: Date?

    init(
        avatarId: String,
        name: String? = nil,
        characterOption: CharacterOption? = nil,
        characterAction: CharacterAction? = nil,
        characterLocation: CharacterLocation? = nil,
        profileImageName: String? = nil,
        authorId: String? = nil,
        dateCreated: Date? = nil
    ) {
        self.avatarId = avatarId
        self.name = name
        self.characterOption = characterOption
        self.characterAction = characterAction
        self.characterLocation = characterLocation
        self.profileImageName = profileImageName
        self.authorId = authorId
        self.dateCreated = dateCreated
    }
    
    var characterDescription: String {
        AvatarDescriptionBuilder(avatar: self).characterDescription
    }

    /// 提供一些 mock 数据
    static var mock: AvatarModel {
        mocks[0]
    }

    static var mocks: [AvatarModel] {
        [
            AvatarModel(
                avatarId: UUID().uuidString,
                name: "Alpha",
                characterOption: .alian,
                characterAction: .smiling,
                characterLocation: .park,
                profileImageName: Constants.randomImageUrl,
                authorId: UUID().uuidString,
                dateCreated: .now
            ),
            AvatarModel(
                avatarId: UUID().uuidString,
                name: "Beta",
                characterOption: .cat,
                characterAction: .eating,
                characterLocation: .forest,
                profileImageName: Constants.randomImageUrl,
                authorId: UUID().uuidString,
                dateCreated: .now
            ),
            AvatarModel(
                avatarId: UUID().uuidString,
                name: "Gamma",
                characterOption: .dog,
                characterAction: .fighting,
                characterLocation: .museum,
                profileImageName: Constants.randomImageUrl,
                authorId: UUID().uuidString,
                dateCreated: .now
            ),
            AvatarModel(
                avatarId: UUID().uuidString,
                name: "Delta",
                characterOption: .man,
                characterAction: .sitting,
                characterLocation: .park,
                profileImageName: Constants.randomImageUrl,
                authorId: UUID().uuidString,
                dateCreated: .now
            )
        ]
    }
}

struct AvatarDescriptionBuilder {
    let characterOption: CharacterOption
    let characterAction: CharacterAction
    let characterLocation: CharacterLocation
    
    init(characterOption: CharacterOption, characterAction: CharacterAction, characterLocation: CharacterLocation) {
        self.characterOption = characterOption
        self.characterAction = characterAction
        self.characterLocation = characterLocation
    }
    
    init(avatar: AvatarModel) {
        self.characterOption = avatar.characterOption ?? .default
        self.characterAction = avatar.characterAction ?? .default
        self.characterLocation = avatar.characterLocation ?? .default
    }
    
    var characterDescription: String {
        "A \(characterOption.rawValue) that is \(characterAction.rawValue) in the \(characterLocation.rawValue)"
    }
}

enum CharacterOption: String {
    case man, woman, alian, dog, cat
    
    static var `default`: Self { // default 在Swift中是一个关键字
        .man
    }
}

enum CharacterAction: String {
    case smiling, sitting, eating, drinking, walking, shopping, studying, working, relaxing, fighting, crying
    
    static var `default`: Self {
        .smiling
    }
}

enum CharacterLocation: String {
    case park, mall, museum, city, desert, forest, space
    
    static var `default`: Self {
        .park
    }
}
