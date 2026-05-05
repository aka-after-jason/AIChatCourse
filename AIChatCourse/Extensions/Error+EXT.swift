//
//  Error+EXT.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/5/6.
//

import Foundation

extension Error {
    var eventParameters: [String: Any] {
        ["error_description": localizedDescription]
    }
}
