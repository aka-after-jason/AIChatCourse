//
//  CreateAccountInteractor.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/6/10.
//
import SwiftUI

@MainActor
protocol CreateAccountInteractor {
    func trackEvent(event: LoggableEvent)
    func signInApple() async throws -> (user: UserAuthInfoModel, isNewUser: Bool)
    func login(user: UserAuthInfoModel, isNewUser: Bool) async throws
}
extension CoreInteractor: CreateAccountInteractor {}
