//
//  UserModelTests.swift
//  AIChatCourseTests
//
//  Created by Elaine on 2026/5/31.
//

@testable import AIChatCourse
import SwiftUI
import Testing

@MainActor
struct UserModelTests {
    @Test("UserModel Initialization with Full Data")
    func initializationWithFullData() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        let randomUserId = String.random
        let randomEmail = "\(String.random)@example.com"
        let randomIsAnonymous = Bool.random
        let randomCreationVersion = String.random
        let randomCreationDate = Date.random
        let randomLastSignInDate = Date.random
        let randomDidCompleteOnboarding = Bool.random
        let randomProfileColorHex = String.randomHexColor()
        
        let user = UserModel(
            userId: randomUserId,
            email: randomEmail,
            isAnonymous: randomIsAnonymous,
            creationVersion: randomCreationVersion,
            creationDate: randomCreationDate,
            lastSignInDate: randomLastSignInDate,
            didCompletedOnboarding: randomDidCompleteOnboarding,
            profileColorHex: randomProfileColorHex
        )
        
        #expect(user.userId == randomUserId)
        #expect(user.email == randomEmail)
        #expect(user.isAnonymous == randomIsAnonymous)
        #expect(user.creationVersion == randomCreationVersion)
        #expect(user.lastSignInDate == randomLastSignInDate)
        #expect(user.didCompletedOnboarding == randomDidCompleteOnboarding)
        #expect(user.profileColorHex == randomProfileColorHex)
     }
    
    @Test("UserModel Event Parameters")
    func testEventParameters() async throws {
        let randomUserId = String.random
        let randomEmail = "\(String.random)@example.com"
        let randomIsAnonymous = Bool.random
        let randomCreationVersion = String.random
        let randomCreationDate = Date.random
        let randomLastSignInDate = Date.random
        let randomDidCompleteOnboarding = Bool.random
        let randomProfileColorHex = String.randomHexColor()
        
        let user = UserModel(
            userId: randomUserId,
            email: randomEmail,
            isAnonymous: randomIsAnonymous,
            creationVersion: randomCreationVersion,
            creationDate: randomCreationDate,
            lastSignInDate: randomLastSignInDate,
            didCompletedOnboarding: randomDidCompleteOnboarding,
            profileColorHex: randomProfileColorHex
        )
        let params = user.eventParameters
        #expect(params["user_user_id"] as? String == randomUserId)
        #expect(params["user_email"] as? String == randomEmail)
        #expect(params["user_is_anonymous"] as? Bool == randomIsAnonymous)
    }
}
