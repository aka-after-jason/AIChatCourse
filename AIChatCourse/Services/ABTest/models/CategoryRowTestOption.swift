//
//  CategoryRowTestOption.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/5/27.
//

import SwiftUI

enum CategoryRowTestOption: String, Codable, CaseIterable {
    case original, top, hidden

    static var `default`: Self {
        .original
    }
}
