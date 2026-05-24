//
//  MockABTestService.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/5/24.
//
import SwiftUI

class MockABTestService: ABTestService {
    var activeABTestModel: ActiveABTestModel
    init(
        createAccountTest: Bool? = nil,
        onboardingCommunityTest: Bool? = nil,
        categoryRowTest: CategoryRowTestOption? = nil
    ) {
        self.activeABTestModel = ActiveABTestModel(
            createAccountTest: createAccountTest ?? false,
            onboardingCommunityTest: onboardingCommunityTest ?? false,
            categroyRowTest: categoryRowTest ?? .default
        )
    }

    func saveUpdatedConfig(abtestModel: ActiveABTestModel) throws {
        activeABTestModel = abtestModel
    }

    func fetchUpdatedConfig() async throws -> ActiveABTestModel {
        activeABTestModel
    }
}
