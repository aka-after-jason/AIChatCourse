//
//  ABTestManager.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/5/19.
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

protocol ABTestService {
    var activeABTestModel: ActiveABTestModel { get }
    func saveUpdatedConfig(abtestModel: ActiveABTestModel) throws
    func fetchUpdatedConfig() async throws -> ActiveABTestModel
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
    
    func fetchUpdatedConfig() async throws -> ActiveABTestModel {
        activeABTestModel
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
    
    func fetchUpdatedConfig() async throws -> ActiveABTestModel {
        activeABTestModel
    }
}

class FirebaseABTestService: ABTestService {
    var activeABTestModel: ActiveABTestModel {
        ActiveABTestModel(config: RemoteConfig.remoteConfig())
    }

    init() {
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        RemoteConfig.remoteConfig().configSettings = settings

        // default value
        let defaultValues = ActiveABTestModel(createAccountTest: false, onboardingCommunityTest: false, categroyRowTest: .default)
        RemoteConfig.remoteConfig().setDefaults(defaultValues.asNSObjectDictionary)
        RemoteConfig.remoteConfig().activate()
    }

    func saveUpdatedConfig(abtestModel: ActiveABTestModel) throws {
        assertionFailure("Error: Firebase ABTest are not configurable from the client.")
    }

    func fetchUpdatedConfig() async throws -> ActiveABTestModel {
        let status = try await RemoteConfig.remoteConfig().fetchAndActivate()
        switch status {
        case .successFetchedFromRemote, .successUsingPreFetchedData:
            return activeABTestModel
        case .error:
            throw RemoteConfigError.failedToFetch
        default:
            throw RemoteConfigError.failedToFetch
        }
    }

    enum RemoteConfigError: LocalizedError {
        case failedToFetch
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
        Task {
            do {
                activeABTestModel = try await service.fetchUpdatedConfig()
                logManager?.addUserProperties(dict: activeABTestModel.eventParameters, isHighPriority: false)
                logManager?.trackEvent(event: Event.fetchRemoteConfigSuccess)
            } catch {
                logManager?.trackEvent(event: Event.fetchRemoteConfigFail(error: error))
            }
        }
    }

    func override(updateABTestModel: ActiveABTestModel) throws {
        try service.saveUpdatedConfig(abtestModel: updateABTestModel)
        configure()
    }
}

extension ABTestManager {
    
    enum Event: LoggableEvent {
        case fetchRemoteConfigSuccess
        case fetchRemoteConfigFail(error: Error)
        
        var eventName: String {
            switch self {
            case .fetchRemoteConfigSuccess: return "ABTestManager_RemoteConfig_Success"
            case .fetchRemoteConfigFail: return "ABTestManager_RemoteConfig_Fail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .fetchRemoteConfigFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: CustomLogType {
            switch self {
            case .fetchRemoteConfigFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
}
