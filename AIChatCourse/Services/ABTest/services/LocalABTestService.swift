//
//  LocalABTestService.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/5/24.
//

import SwiftUI

class LocalABTestService: ABTestService {
    /// 使用自定义的 propertyWrapper
    @UserDefault(key: ActiveABTestModel.CodingKeys.createAccountTest.rawValue, startingValue: Bool.random()) private var createAccountTest: Bool

    @UserDefault(key: ActiveABTestModel.CodingKeys.onboardingCommunityTest.rawValue, startingValue: Bool.random()) private var onboardingCommunityTest: Bool

    @UserDefaultEnum(key: ActiveABTestModel.CodingKeys.categroyRowTest.rawValue, startingValue: CategoryRowTestOption.allCases.randomElement()!) private var categoryRowTest: CategoryRowTestOption
    
    @UserDefaultEnum(key: ActiveABTestModel.CodingKeys.paywallTest.rawValue, startingValue: PaywallTestOption.allCases.randomElement()!) private var paywallTest: PaywallTestOption

    var activeABTestModel: ActiveABTestModel {
        ActiveABTestModel(
            createAccountTest: createAccountTest,
            onboardingCommunityTest: onboardingCommunityTest,
            categroyRowTest: categoryRowTest,
            paywallTest: paywallTest
        )
    }

    init() {
        print(NSHomeDirectory())
    }

    func saveUpdatedConfig(abtestModel: ActiveABTestModel) throws {
        createAccountTest = abtestModel.createAccountTest
        onboardingCommunityTest = abtestModel.onboardingCommunityTest
        categoryRowTest = abtestModel.categroyRowTest
        paywallTest = abtestModel.paywallTest
    }

    func fetchUpdatedConfig() async throws -> ActiveABTestModel {
        activeABTestModel
    }
}
