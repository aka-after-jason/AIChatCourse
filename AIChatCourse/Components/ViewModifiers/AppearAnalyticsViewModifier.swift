//
//  AppearAnalyticsViewModifier.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/5/6.
//

import SwiftUI

struct AppearAnalyticsViewModifier: ViewModifier {
    @Environment(LogManager.self) private var logManager
    let name: String
    func body(content: Content) -> some View {
        content
            .onAppear {
                logManager.trackScreenEvent(event: Event.appear(name: name))
            }
            .onDisappear {
                logManager.trackEvent(event: Event.disappear(name: name))
            }
    }
    
    enum Event: LoggableEvent {
        case appear(name: String)
        case disappear(name: String)
        
        var eventName: String {
            switch self {
            case .appear(name: let name): return "\(name)_Appear"
            case .disappear(name: let name): return "\(name)_Disappear"
            }
        }
        
        var parameters: [String: Any]? {
            return nil
        }
        
        var type: CustomLogType {
            .analytic
        }
    }
}

extension View {
    func appearAnalyticsViewModifier(name: String) -> some View {
        modifier(AppearAnalyticsViewModifier(name: name))
    }
}
