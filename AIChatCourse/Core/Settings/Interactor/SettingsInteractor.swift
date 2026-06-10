//
//  SettingsInteractor.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/6/10.
//
import SwiftUI

@MainActor
protocol SettingsInteractor {
    var authUser: UserAuthInfoModel? { get }
    func trackEvent(event: LoggableEvent)
    func signOut() async throws
    func getCurrentUserId() throws -> String
    func deleteAccount() async throws
    func deleteUser() async throws
    func removeAuthorIdFromAllUserAvatars(userId: String) async throws
    func deleteAllChatsForUser(userId: String) async throws
    func deleteUserProfile()
    func updateAppState(showTabBarView: Bool)
}
extension CoreInteractor: SettingsInteractor {}
