//
//  PaywallTestOption.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/5/27.
//
import SwiftUI

enum PaywallTestOption: String, Codable, CaseIterable {
    case storeKit, custom, revenueCat
    
    static var `default`: Self {
        .storeKit
    }
}
