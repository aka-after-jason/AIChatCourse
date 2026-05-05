//
//  LogService.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/5/5.
//

protocol LogService {
    func identifyUser(userId: String, name: String?, email: String?)
    func addUserProperties(dict: [String: Any], isHighPriority: Bool)
    func deleteUserProfile()

    func trackEvent(event: LoggableEvent)
    func trackScreenEvent(event: LoggableEvent)
}
