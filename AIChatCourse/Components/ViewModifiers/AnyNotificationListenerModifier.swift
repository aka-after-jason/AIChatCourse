//
//  AnyNotificationListenerModifier.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/5/11.
//

import SwiftUI

struct AnyNotificationListenerModifier: ViewModifier {
    let notificationName: Notification.Name
    let onNotificationRecieved: @MainActor (Notification) -> Void // 主线程
    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: notificationName), perform: { notification in
                onNotificationRecieved(notification)
            })
    }
}

extension View {
    func onNotificationRecieved(notificationName: Notification.Name, onNotificationRecieved: @escaping @MainActor (Notification) -> Void) -> some View {
        modifier(AnyNotificationListenerModifier(notificationName: notificationName, onNotificationRecieved: onNotificationRecieved))
    }
}
