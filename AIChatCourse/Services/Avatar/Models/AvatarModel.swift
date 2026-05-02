//
//  AvatarModel.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/3/17.
//

import Foundation
import IdentifiableByString

struct AvatarModel: Codable, Hashable, StringIdentifiable {
    var id: String {
        avatarId
    }
    let avatarId: String
    let name: String?
    let characterOption: CharacterOption?
    let characterAction: CharacterAction?
    let characterLocation: CharacterLocation?
    private(set) var profileImageName: String?
    let authorId: String?
    let dateCreated: Date?
    let clickCount: Int?

    init(
        avatarId: String,
        name: String? = nil,
        characterOption: CharacterOption? = nil,
        characterAction: CharacterAction? = nil,
        characterLocation: CharacterLocation? = nil,
        profileImageName: String? = nil,
        authorId: String? = nil,
        dateCreated: Date? = nil,
        clickCount: Int? = nil
    ) {
        self.avatarId = avatarId
        self.name = name
        self.characterOption = characterOption
        self.characterAction = characterAction
        self.characterLocation = characterLocation
        self.profileImageName = profileImageName
        self.authorId = authorId
        self.dateCreated = dateCreated
        self.clickCount = clickCount
    }

    enum CodingKeys: String, CodingKey {
        case avatarId = "avatar_id"
        case name
        case characterOption = "character_option"
        case characterAction = "character_action"
        case characterLocation = "character_location"
        case profileImageName = "profile_image_name"
        case authorId = "author_id"
        case dateCreated = "date_created"
        case clickCount = "click_count"
    }

    var characterDescription: String {
        AvatarDescriptionBuilder(avatar: self).characterDescription
    }

    /// 更新 profileImageName 的值
    mutating func updateProfileImage(imageName: String) {
        profileImageName = imageName
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
                characterOption: .alien,
                characterAction: .smiling,
                characterLocation: .park,
                profileImageName: Constants.randomImageUrl,
                authorId: UUID().uuidString,
                dateCreated: .now,
                clickCount: 10
            ),
            AvatarModel(
                avatarId: UUID().uuidString,
                name: "Beta",
                characterOption: .cat,
                characterAction: .eating,
                characterLocation: .forest,
                profileImageName: Constants.randomImageUrl,
                authorId: UUID().uuidString,
                dateCreated: .now,
                clickCount: 9
            ),
            AvatarModel(
                avatarId: UUID().uuidString,
                name: "Gamma",
                characterOption: .dog,
                characterAction: .fighting,
                characterLocation: .museum,
                profileImageName: Constants.randomImageUrl,
                authorId: UUID().uuidString,
                dateCreated: .now,
                clickCount: 4
            ),
            AvatarModel(
                avatarId: UUID().uuidString,
                name: "Delta",
                characterOption: .man,
                characterAction: .sitting,
                characterLocation: .park,
                profileImageName: Constants.randomImageUrl,
                authorId: UUID().uuidString,
                dateCreated: .now,
                clickCount: 100
            )
        ]
    }
}
