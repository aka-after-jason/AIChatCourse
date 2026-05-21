//
//  ABTestManager.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/5/19.
//

import SwiftUI

enum CategoryRowTestOption: String, Codable, CaseIterable {
    case original, top, hidden
    
    static var `default`: Self {
        .original
    }
}

/// 存储需要测试的变量
struct ActiveABTestModel: Codable {
    private(set) var createAccountTest: Bool
    private(set) var onboardingCommunityTest: Bool
    private(set) var categroyRowTest: CategoryRowTestOption

    enum CodingKeys: String, CodingKey {
        case createAccountTest = "_20260519_CreateAccountTest"
        case onboardingCommunityTest = "_20260519_OnboardingTest"
        case categroyRowTest = "_20260519_CategroyRowTest"
    }

    var eventParameters: [String: Any] {
        let dict: [String: Any?] = [
            "test\(CodingKeys.createAccountTest.rawValue)": createAccountTest,
            "test\(CodingKeys.onboardingCommunityTest.rawValue)": onboardingCommunityTest,
            "test\(CodingKeys.categroyRowTest.rawValue)": categroyRowTest.rawValue
        ]
        return dict.compactMapValues { $0 } // drop the nil value
    }

    mutating func update(createAccountTest newValue: Bool) {
        createAccountTest = newValue
    }

    mutating func update(onboardingCommunityTest newValue: Bool) {
        onboardingCommunityTest = newValue
    }
    
    mutating func update(categoryRowTest newValue: CategoryRowTestOption) {
        categroyRowTest = newValue
    }
}

protocol ABTestService {
    var activeABTestModel: ActiveABTestModel { get }
    func saveUpdatedConfig(abtestModel: ActiveABTestModel) throws
}

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
}

class LocalABTestService: ABTestService {
    /// 使用自定义的 propertyWrapper
    @UserDefault(key: ActiveABTestModel.CodingKeys.createAccountTest.rawValue, startingValue: Bool.random()) private var createAccountTest: Bool

    @UserDefault(key: ActiveABTestModel.CodingKeys.onboardingCommunityTest.rawValue, startingValue: Bool.random()) private var onboardingCommunityTest: Bool
    
    @UserDefaultEnum(key: ActiveABTestModel.CodingKeys.categroyRowTest.rawValue, startingValue: CategoryRowTestOption.allCases.randomElement()!) private var categoryRowTest: CategoryRowTestOption

    var activeABTestModel: ActiveABTestModel {
        ActiveABTestModel(
            createAccountTest: createAccountTest,
            onboardingCommunityTest: onboardingCommunityTest,
            categroyRowTest: categoryRowTest
        )
    }

    init() {
        print(NSHomeDirectory())
    }

    func saveUpdatedConfig(abtestModel: ActiveABTestModel) throws {
        createAccountTest = abtestModel.createAccountTest
        onboardingCommunityTest = abtestModel.onboardingCommunityTest
        categoryRowTest = abtestModel.categroyRowTest
    }
}

@MainActor
@Observable
final class ABTestManager {
    private let service: ABTestService
    private let logManager: LogManager?
    var activeABTestModel: ActiveABTestModel
    init(service: ABTestService, logManager: LogManager? = nil) {
        self.service = service
        self.logManager = logManager
        self.activeABTestModel = service.activeABTestModel
        configure()
    }

    private func configure() {
        activeABTestModel = service.activeABTestModel
        logManager?.addUserProperties(dict: activeABTestModel.eventParameters, isHighPriority: false)
    }

    func override(updateABTestModel: ActiveABTestModel) throws {
        try service.saveUpdatedConfig(abtestModel: updateABTestModel)
        configure()
    }
}
