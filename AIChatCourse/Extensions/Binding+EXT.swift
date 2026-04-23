//
//  Binding+EXT.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/4/23.
//

import SwiftUI
import Foundation

extension Binding where Value == Bool {
    init<T>(ifNotNil value: Binding<T?>) {
        self.init {
            value.wrappedValue != nil
        } set: { newValue in
            if !newValue {
                value.wrappedValue = nil
            }
        }
    }
}
