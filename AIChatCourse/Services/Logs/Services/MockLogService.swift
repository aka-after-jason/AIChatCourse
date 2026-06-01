//
//  MockLogService.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/6/1.
//

import SwiftUI

struct MockLogService: LogService {
    func identifyUser(userId: String, name: String?, email: String?) {}

    func addUserProperties(dict: [String: Any], isHighPriority: Bool) {}

    func deleteUserProfile() {}

    func trackEvent(event: any LoggableEvent) {}

    func trackScreenEvent(event: any LoggableEvent) {}
}
