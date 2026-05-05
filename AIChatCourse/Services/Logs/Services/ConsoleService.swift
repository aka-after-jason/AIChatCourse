//
//  ConsoleService.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/5/5.
//
import SwiftUI
import OSLog

struct ConsoleService: LogService {
    
    let logger = LogSystem()
    private let printParameters: Bool // 开关
    init(printParameters: Bool = true) {
        self.printParameters = printParameters
    }
    
    func identifyUser(userId: String, name: String?, email: String?) {
        let string = """
        Identify User
            userId: \(userId)
            name: \(name ?? "unknown")
            email: \(email ?? "unknown")
        """
        logger.log(level: CustomLogType.info, message: string)
    }

    func addUserProperties(dict: [String: Any]) {
        var string = """
        Log User Properties
        """
        if printParameters {
            let sortedKeys = dict.keys.sorted()
            for key in sortedKeys {
                if let value = dict[key] {
                    string += "\n (key: \(key), value: \(value))"
                }
            }
        }
        logger.log(level: CustomLogType.info, message: string)
    }

    func deleteUserProfile() {
        let string = """
        Delete User Profile
        """
        print(string)
    }

    func trackEvent(event: any LoggableEvent) {
        var string = "\(event.type.emoji) \(event.eventName)"
        if printParameters {
            if let parameters = event.parameters, !parameters.isEmpty {
                let sortedKeys = parameters.keys.sorted()
                for key in sortedKeys {
                    if let value = parameters[key] {
                        string += "\n (key: \(key), value: \(value))"
                    }
                }
            }
        }
        logger.log(level: event.type, message: string)
    }

    func trackScreenEvent(event: any LoggableEvent) {
        trackEvent(event: event)
    }
}

actor LogSystem {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "ConsoleLogger")
    
    func log(level: OSLogType, message: String) {
        logger.log(level: level, "\(message)")
    }
    
    nonisolated func log(level: CustomLogType, message: String) {
        Task {
            await log(level: level.osLogType, message: message)
        }
    }
}

enum CustomLogType {
    /// info
    case info
    /// default type for analytics
    case analytic
    /// issues or errors that should not occur, but will not negatively affect the user experience
    case warning
    /// issues or errors that negatively affect user experience
    case severe // 十分严重的错误
    
    var emoji: String {
        switch self {
        case .info:
            return "👋info: "
        case .analytic:
            return "📊analytic: "
        case .warning:
            return "⚠️warning: "
        case .severe:
            return "🚨severe: "
        }
    }
    
    var osLogType: OSLogType { // 将 系统的 OSLogType 转为自定义的 CustomLogType
        switch self {
        case .info:
            return .info
        case .analytic:
            return .default
        case .warning:
            return .error
        case .severe:
            return .fault
        }
    }
}
