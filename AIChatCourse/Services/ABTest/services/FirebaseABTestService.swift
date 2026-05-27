//
//  FirebaseABTestService.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/5/24.
//

import FirebaseRemoteConfig

class FirebaseABTestService: ABTestService {
    var activeABTestModel: ActiveABTestModel {
        ActiveABTestModel(config: RemoteConfig.remoteConfig())
    }

    init() {
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        RemoteConfig.remoteConfig().configSettings = settings

        // default value
        let defaultValues = ActiveABTestModel(
            createAccountTest: false,
            onboardingCommunityTest: false,
            categroyRowTest: .default,
            paywallTest: .default
        )
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
