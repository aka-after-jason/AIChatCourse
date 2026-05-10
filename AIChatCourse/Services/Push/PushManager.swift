//
//  PushManager.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/5/10.
//

import Foundation
import SwiftfulUtilities

// MARK: Local PushNotifications

@MainActor
@Observable
final class PushManager {
    private let logManager: LogManager?
    init(logManager: LogManager? = nil) {
        self.logManager = logManager
    }
    
    func requestAuthorization() async throws -> Bool {
        let isAuthorized = try await LocalNotifications.requestAuthorization()
        logManager?.addUserProperties(dict: ["push_is_authorized": isAuthorized], isHighPriority: true)
        return isAuthorized
    }
    
    func canRequestAuthorization() async -> Bool {
        await LocalNotifications.canRequestAuthorization()
    }
    
    func schedulePushNotificationsForTheNextWeek() {
        LocalNotifications.removeAllPendingNotifications()
        LocalNotifications.removeAllDeliveredNotifications()
        
        Task {
            do {
                // Tomorrow
                try await scheduleNotification(
                    title: "Hey you! Ready to chat?",
                    subtitle: "Open AIChat to begin.",
                    triggerDate: Date().addingTimeInterval(days: 1)
                )
                
                // In 3 days
                try await scheduleNotification(
                    title: "Someone sent you a message!",
                    subtitle: "Open AIChat to responed.",
                    triggerDate: Date().addingTimeInterval(days: 3)
                )
                
                // In 5 days
                try await scheduleNotification(
                    title: "Hey stranger, We miss you!",
                    subtitle: "Don't forget about us.",
                    triggerDate: Date().addingTimeInterval(days: 5)
                )
                
                logManager?.trackEvent(event: Event.weekScheduledSuccess)
            } catch {
                logManager?.trackEvent(event: Event.weekScheduledFail(error: error))
            }
        }
    }
    
    private func scheduleNotification(title: String, subtitle: String, triggerDate: Date) async throws {
        let content = AnyNotificationContent(title: title, body: subtitle)
        let trigger = NotificationTriggerOption.date(date: triggerDate, repeats: false)
        try await LocalNotifications.scheduleNotification(content: content, trigger: trigger)
    }
}

extension PushManager {
    enum Event: LoggableEvent {
        case weekScheduledSuccess
        case weekScheduledFail(error: Error)
        var eventName: String {
            switch self {
            case .weekScheduledSuccess: return "PushManager_WeekScheduled_Success"
            case .weekScheduledFail: return "PushManager_WeekScheduled_Fail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .weekScheduledFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: CustomLogType {
            switch self {
            case .weekScheduledFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
}
