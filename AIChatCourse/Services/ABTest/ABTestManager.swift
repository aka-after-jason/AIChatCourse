//
//  ABTestManager.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/5/19.
//

import SwiftUI

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
