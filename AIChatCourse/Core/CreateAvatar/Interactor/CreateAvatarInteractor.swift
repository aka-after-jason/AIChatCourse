//
//  CreateAvatarInteractor.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/6/10.
//
import SwiftUI

@MainActor
protocol CreateAvatarInteractor {
    func trackEvent(event: LoggableEvent)
    func generateImage(prompt: String) async throws -> UIImage
    func getCurrentUserId() throws -> String
    func createAvatar(avatar: AvatarModel, image: UIImage) async throws
}
extension CoreInteractor: CreateAvatarInteractor {}
