//
//  LogManager.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/5/5.
//

import Foundation

@MainActor
@Observable
final class LogManager {
    private let services: [LogService] // 多个 service

    init(services: [LogService] = []) {
        self.services = services
    }

    func identifyUser(userId: String, name: String?, email: String?) {
        for service in services {
            service.identifyUser(userId: userId, name: name, email: email)
        }
    }

    func addUserProperties(dict: [String: Any], isHighPriority: Bool) {
        for service in services {
            service.addUserProperties(dict: dict, isHighPriority: isHighPriority)
        }
    }

    func deleteUserProfile() {
        for service in services {
            service.deleteUserProfile()
        }
    }

    func trackEvent(eventName: String, parameters: [String: Any]? = nil, type: CustomLogType = .analytic) {
        let event = AnyLoggableEvent(eventName: eventName, parameters: parameters, type: type)
        for service in services {
            service.trackEvent(event: event)
        }
    }

    func trackEvent(event: LoggableEvent) {
        for service in services {
            service.trackEvent(event: event)
        }
    }

    func trackEvent(event: AnyLoggableEvent) {
        for service in services {
            service.trackEvent(event: event)
        }
    }

    func trackScreenEvent(event: LoggableEvent) {
        for service in services {
            service.trackScreenEvent(event: event)
        }
    }
}
