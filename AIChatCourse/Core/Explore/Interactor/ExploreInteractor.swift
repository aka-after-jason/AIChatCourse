//
//  ExploreInteractor.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/6/10.
//
import SwiftUI

@MainActor
protocol ExploreInteractor {
    var categoryRowTest: CategoryRowTestOption { get }
    var authUser: UserAuthInfoModel? { get }
    var createAccountTest: Bool { get }
    func canRequestAuthorization() async -> Bool
    func requestAuthorization() async throws -> Bool
    func schedulePushNotificationsForTheNextWeek()
    func getFeaturedAvatars() async throws -> [AvatarModel]
    func getPopularAvatars() async throws -> [AvatarModel]
    func trackEvent(event: LoggableEvent)
}
extension CoreInteractor: ExploreInteractor {}
