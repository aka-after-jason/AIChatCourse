//
//  ChatsInteractor.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/6/10.
//
import SwiftUI

@MainActor
protocol ChatsInteractor {
    var authUser: UserAuthInfoModel? { get }
    func trackEvent(event: LoggableEvent)
    func getCurrentUserId() throws -> String
    func getAllChats(userId: String) async throws -> [ChatModel]
    func getRecentAvatars() throws -> [AvatarModel]
}
extension CoreInteractor: ChatsInteractor {}
