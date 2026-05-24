//
//  ActiveABTestModel.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/5/24.
//

import FirebaseRemoteConfig
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

extension ActiveABTestModel {
    /// 读取 firebase RemoteConfig
    init(config: RemoteConfig) {
        let createAccountTest = config.configValue(forKey: ActiveABTestModel.CodingKeys.createAccountTest.rawValue).boolValue
        print("FOUND CREATE ACCOUNT DATA: \(createAccountTest.description)")
        self.createAccountTest = createAccountTest

        let onboardingCommunityTest = config.configValue(forKey: ActiveABTestModel.CodingKeys.onboardingCommunityTest.rawValue).boolValue
        self.onboardingCommunityTest = onboardingCommunityTest

        let categoryRowTestStringValue = config.configValue(forKey: ActiveABTestModel.CodingKeys.categroyRowTest.rawValue).stringValue
        if let option = CategoryRowTestOption(rawValue: categoryRowTestStringValue) {
            self.categroyRowTest = option
        } else {
            self.categroyRowTest = .default
        }
    }

    /// Converted to a NSObject dictionary to setDefaults within FirebaseABTestService
    var asNSObjectDictionary: [String: NSObject]? {
        [
            CodingKeys.createAccountTest.rawValue: createAccountTest as NSObject,
            CodingKeys.onboardingCommunityTest.rawValue: onboardingCommunityTest as NSObject,
            CodingKeys.categroyRowTest.rawValue: categroyRowTest.rawValue as NSObject
        ]
    }
}
