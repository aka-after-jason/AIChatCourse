//
//  LoggableEvent.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/5/5.
//

protocol LoggableEvent {
    var eventName: String { get }
    var parameters: [String: Any]? { get }
    var type: CustomLogType { get }
}

struct AnyLoggableEvent: LoggableEvent {
    let eventName: String
    let parameters: [String: Any]?
    let type: CustomLogType

    init(eventName: String, parameters: [String: Any]? = nil, type: CustomLogType = .analytic) {
        self.eventName = eventName
        self.parameters = parameters
        self.type = type
    }
}
