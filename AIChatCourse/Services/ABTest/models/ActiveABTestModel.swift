//
//  ActiveABTestModel.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/5/24.
//

import FirebaseRemoteConfig
import SwiftUI

/// 存储需要测试的变量
struct ActiveABTestModel: Codable {
    private(set) var createAccountTest: Bool
    private(set) var onboardingCommunityTest: Bool
    private(set) var categroyRowTest: CategoryRowTestOption
    private(set) var paywallTest: PaywallTestOption

    enum CodingKeys: String, CodingKey {
        case createAccountTest = "_20260519_CreateAccountTest"
        case onboardingCommunityTest = "_20260519_OnboardingTest"
        case categroyRowTest = "_20260519_CategroyRowTest"
        case paywallTest = "_20260519_PaywallTest"
    }

    var eventParameters: [String: Any] {
        let dict: [String: Any?] = [
            "test\(CodingKeys.createAccountTest.rawValue)": createAccountTest,
            "test\(CodingKeys.onboardingCommunityTest.rawValue)": onboardingCommunityTest,
            "test\(CodingKeys.categroyRowTest.rawValue)": categroyRowTest.rawValue,
            "test\(CodingKeys.paywallTest.rawValue)": paywallTest.rawValue
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
    
    mutating func update(paywallTest newValue: PaywallTestOption) {
        paywallTest = newValue
    }
}

extension ActiveABTestModel {
    /// 读取 firebase RemoteConfig, 下面这些都可以在 firebase 中设置
    init(config: RemoteConfig) {
        
        // createAccountTest
        let createAccountTest = config.configValue(forKey: ActiveABTestModel.CodingKeys.createAccountTest.rawValue).boolValue
        print("FOUND CREATE ACCOUNT DATA: \(createAccountTest.description)")
        self.createAccountTest = createAccountTest

        // onboardingCommunityTest
        let onboardingCommunityTest = config.configValue(forKey: ActiveABTestModel.CodingKeys.onboardingCommunityTest.rawValue).boolValue
        self.onboardingCommunityTest = onboardingCommunityTest

        // categroyRowTest
        let categoryRowTestStringValue = config.configValue(forKey: ActiveABTestModel.CodingKeys.categroyRowTest.rawValue).stringValue
        if let option = CategoryRowTestOption(rawValue: categoryRowTestStringValue) {
            self.categroyRowTest = option
        } else {
            self.categroyRowTest = .default
        }
        
        // paywallTest
        let paywallTestStringValue = config.configValue(forKey: ActiveABTestModel.CodingKeys.paywallTest.rawValue).stringValue
        if let option = PaywallTestOption(rawValue: paywallTestStringValue) {
            self.paywallTest = option
        } else {
            self.paywallTest = .default
        }
    }

    /// Converted to a NSObject dictionary to setDefaults within FirebaseABTestService
    var asNSObjectDictionary: [String: NSObject]? {
        [
            CodingKeys.createAccountTest.rawValue: createAccountTest as NSObject,
            CodingKeys.onboardingCommunityTest.rawValue: onboardingCommunityTest as NSObject,
            CodingKeys.categroyRowTest.rawValue: categroyRowTest.rawValue as NSObject,
            CodingKeys.paywallTest.rawValue: paywallTest.rawValue as NSObject
        ]
    }
}
