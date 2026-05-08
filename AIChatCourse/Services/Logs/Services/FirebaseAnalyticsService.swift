//
//  FirebaseAnalyticsService.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/5/5.
//

import FirebaseAnalytics

struct FirebaseAnalyticsService: LogService {
    func identifyUser(userId: String, name: String?, email: String?) {
        Analytics.setUserID(userId)
        if let name {
            Analytics.setUserProperty(name, forName: "account_name")
        }
        if let email {
            Analytics.setUserProperty(email, forName: "account_email")
        }
    }

    func addUserProperties(dict: [String: Any], isHighPriority: Bool) {
        guard isHighPriority else { return }
        for (key, value) in dict {
            // Analytics.setUserProperty(value, forName: key) 只接收 String 类型的valu
            if let string = String.convertToString(value) {
                // Analytics 对 key 和 string 的长度有要求, key最长为 24
                let key = key.clean(maxCharacters: 24)
                let string = string.clean(maxCharacters: 100)
                Analytics.setUserProperty(string, forName: key)
            }
        }
    }

    func deleteUserProfile() {}

    func trackEvent(event: any LoggableEvent) {
        // 当 type 是 info 的时候不track
        guard event.type != .info else { return }
        
        var parameters = event.parameters ?? [:]
        // Fix any values that are bad types
        for (key, value) in parameters {
            // 这里将 Date 类型 转为 string
            if let date = value as? Date, let string = String.convertToString(date) {
                parameters[key] = string
            } else if let array = value as? [Any] { // 将 array 类型转成 string
                if let string = String.convertToString(array) {
                    parameters[key] = string
                } else {
                    parameters[key] = nil
                }
            }
        }

        // Fix key length limits
        for (key, value) in parameters where key.count > 40 {
            parameters.removeValue(forKey: key)
            let newKey = key.clean(maxCharacters: 40)
            parameters[newKey] = value
        }

        // Fix value length limits
        for (key, value) in parameters {
            if let string = value as? String {
                parameters[key] = string.clean(maxCharacters: 100)
            }
        }

        // 注意: Analytics 的 parameters 最多只接收 25 条数据
        parameters.first(upTo: 25)

        // 其他的类型保留: 比如 Bool, Int 等等
        let name = event.eventName.clean(maxCharacters: 40)
        Analytics.logEvent(name, parameters: parameters.isEmpty ? nil : parameters)
    }

    func trackScreenEvent(event: any LoggableEvent) {
        let name = event.eventName.clean(maxCharacters: 40)
        Analytics.logEvent(
            AnalyticsEventScreenView,
            parameters: [AnalyticsParameterScreenName: name]
        )
    }
}

private extension String {
    func clean(maxCharacters: Int) -> String {
        self
            .clipped(maxCharacters: maxCharacters)
            .replaceSpacesWithUnderscores()
    }
}
