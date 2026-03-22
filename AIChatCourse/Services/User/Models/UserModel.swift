//
//  UserModel.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/3/21.
//

import Foundation
import SwiftUI

struct UserModel {
    let userId: String
    let dateCreated: Date?
    let didCompletedOnboarding: Bool?
    let profileColorHex: String?

    init(
        userId: String,
        dateCreated: Date? = nil,
        didCompletedOnboarding: Bool? = nil,
        profileColorHex: String? = nil
    ) {
        self.userId = userId
        self.dateCreated = dateCreated
        self.didCompletedOnboarding = didCompletedOnboarding
        self.profileColorHex = profileColorHex
    }
    
    // 提供一个计算属性: 将profileColorHex转成Color
    var profileColorCalculated: Color {
        guard let profileColorHex else {return .accent}
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
                dateCreated: now,
                didCompletedOnboarding: true,
                profileColorHex: "#FF5733"
            ),
            UserModel(
                userId: "user2",
                dateCreated: now.addingTimeInterval(days: -1),
                didCompletedOnboarding: false,
                profileColorHex: "#33A1FF"
            ),
            UserModel(
                userId: "user3",
                dateCreated: now.addingTimeInterval(days: -3, hours: -2),
                didCompletedOnboarding: true,
                profileColorHex: "#7DFF33"
            ),
            UserModel(
                userId: "user4",
                dateCreated: now.addingTimeInterval(days: -5, hours: -4),
                didCompletedOnboarding: false,
                profileColorHex: "#FF33A1"
            )
        ]
    }
}
