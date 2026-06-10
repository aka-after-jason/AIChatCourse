//
//  ProfileInteractor.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/6/10.
//
import SwiftUI

// 目的:
// 1. 不需要导入manager中所有的方法, 用到什么方法,在 protocol 里面添加
// 2. 方便单元测试

@MainActor
protocol ProfileInteractor {
    var currentUser: UserModel? { get }

    func getCurrentUserId() throws -> String
    func getAvatarsForAuthor(userId: String) async throws -> [AvatarModel]
    func removeAuthorIdFromAvatar(avatarId: String) async throws
    func trackEvent(event: LoggableEvent)
}
extension CoreInteractor: ProfileInteractor {}
