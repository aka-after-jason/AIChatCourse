//
//  Date+EXT.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/3/21.
//

import Foundation

extension Date {
    func addingTimeInterval(days: Int = 0, hours: Int = 0, minutes: Int = 0) -> Date {
        let dayInterval = TimeInterval(days * 24 * 60 * 60)
        let hoursInterval = TimeInterval(hours * 60 * 60)
        let minutesInterval = TimeInterval(minutes * 60)
        return self.addingTimeInterval(dayInterval + hoursInterval + minutesInterval)
    }
}
