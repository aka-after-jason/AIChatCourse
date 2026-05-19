//
//  ABTestManager.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/5/19.
//

import SwiftUI

/// 存储需要测试的变量
struct ActiveABTestModel: Codable {
    let createAccountTest: Bool

    enum CodingKeys: String, CodingKey {
        case createAccountTest = "_20260519_CreateAccountTest"
    }

    var eventParameters: [String: Any] {
        let dict: [String: Any?] = ["test\(CodingKeys.createAccountTest.rawValue)": createAccountTest]
        return dict.compactMapValues { $0 } // drop the nil value
    }
}

protocol ABTestService {
    var activeABTestModel: ActiveABTestModel { get }
}

struct MockABTestService: ABTestService {
    let activeABTestModel: ActiveABTestModel
    init(createAccountTest: Bool? = nil) {
        self.activeABTestModel = ActiveABTestModel(createAccountTest: createAccountTest ?? false)
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
        logManager?.addUserProperties(dict: activeABTestModel.eventParameters, isHighPriority: false)
    }
}
