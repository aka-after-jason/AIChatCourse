//
//  ABTestManager.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/5/19.
//

import SwiftUI

/// 存储需要测试的变量
struct ActiveABTestModel: Codable {
    private(set) var createAccountTest: Bool

    enum CodingKeys: String, CodingKey {
        case createAccountTest = "_20260519_CreateAccountTest"
    }

    var eventParameters: [String: Any] {
        let dict: [String: Any?] = ["test\(CodingKeys.createAccountTest.rawValue)": createAccountTest]
        return dict.compactMapValues { $0 } // drop the nil value
    }
    
    mutating func update(createAccountTest newValue: Bool) {
        createAccountTest = newValue
    }
}

protocol ABTestService {
    var activeABTestModel: ActiveABTestModel { get }
    func saveUpdatedConfig(abtestModel: ActiveABTestModel) throws
}

class MockABTestService: ABTestService {
    var activeABTestModel: ActiveABTestModel
    init(createAccountTest: Bool? = nil) {
        self.activeABTestModel = ActiveABTestModel(createAccountTest: createAccountTest ?? false)
    }

    func saveUpdatedConfig(abtestModel: ActiveABTestModel) throws {
        activeABTestModel = abtestModel
    }
}

class LocalABTestService: ABTestService {
    /// 使用自定义的 propertyWrapper
    @UserDefault(key: ActiveABTestModel.CodingKeys.createAccountTest.rawValue, startingValue: Bool.random()) private var createAccountTest: Bool

    var activeABTestModel: ActiveABTestModel {
        ActiveABTestModel(createAccountTest: createAccountTest)
    }

    init() {
        print(NSHomeDirectory())
    }

    func saveUpdatedConfig(abtestModel: ActiveABTestModel) throws {
        createAccountTest = abtestModel.createAccountTest
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
