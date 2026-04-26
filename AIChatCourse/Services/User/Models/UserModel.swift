//
//  UserModel.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/3/21.
//

import Foundation
import SwiftUI

struct UserModel: Codable {
    let userId: String
    let email: String?
    let isAnonymous: Bool?
    let creationVersion: String?
    let creationDate: Date?
    let lastSignInDate: Date?
    let didCompletedOnboarding: Bool?
    let profileColorHex: String?

    init(
        userId: String,
        email: String? = nil,
        isAnonymous: Bool? = nil,
        creationVersion: String? = nil,
        creationDate: Date? = nil,
        lastSignInDate: Date? = nil,
        didCompletedOnboarding: Bool? = nil,
        profileColorHex: String? = nil
    ) {
        self.userId = userId
        self.email = email
        self.isAnonymous = isAnonymous
        self.creationVersion = creationVersion
        self.creationDate = creationDate
        self.lastSignInDate = lastSignInDate
        self.didCompletedOnboarding = didCompletedOnboarding
        self.profileColorHex = profileColorHex
    }

    init(auth: UserAuthInfoModel, creationVersion: String?) {
        self.init(
            userId: auth.uid,
            email: auth.email,
            isAnonymous: auth.isAnonymous,
            creationVersion: creationVersion,
            creationDate: auth.creationDate,
            lastSignInDate: auth.lastSignInDate
        )
    }

    enum CodingKeys: String, CodingKey { // snake_case
        case userId = "user_id"
        case email
        case isAnonymous = "is_anonymous"
        case creationVersion = "creation_version"
        case creationDate = "creation_date"
        case lastSignInDate = "last_sign_in_date"
        case didCompletedOnboarding = "did_complete_onboarding"
        case profileColorHex = "profile_color_hex"
    }

    // 提供一个计算属性: 将profileColorHex转成Color
    var profileColorCalculated: Color {
        guard let profileColorHex else { return .accent }
        return Color(hex: profileColorHex)
    }

    /// mock data
    static var mock: UserModel {
        mocks[0]
    }

    static var mocks: [UserModel] {
        let now = Date()
        return [
            UserModel(
                userId: "user1",
                creationDate: now,
                didCompletedOnboarding: true,
                profileColorHex: "#FF5733"
            ),
            UserModel(
                userId: "user2",
                creationDate: now.addingTimeInterval(days: -1),
                didCompletedOnboarding: false,
                profileColorHex: "#33A1FF"
            ),
            UserModel(
                userId: "user3",
                creationDate: now.addingTimeInterval(days: -3, hours: -2),
                didCompletedOnboarding: true,
                profileColorHex: "#7DFF33"
            ),
            UserModel(
                userId: "user4",
                creationDate: now.addingTimeInterval(days: -5, hours: -4),
                didCompletedOnboarding: false,
                profileColorHex: "#FF33A1"
            )
        ]
    }
}
