//
//  LogService.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/5/5.
//

protocol LogService {
    func identifyUser(userId: String, name: String?, email: String?)
    func addUserProperties(dict: [String: Any])
    func deleteUserProfile()

    func trackEvent(event: LoggableEvent)
    func trackScreenEvent(event: LoggableEvent)
}

protocol LoggableEvent {
    var eventName: String { get }
    var parameters: [String: Any]? { get }
    var type: CustomLogType { get }
}
