//
//  Builder.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/6/11.
//
import SwiftUI

@MainActor
protocol Builder {
    func build() -> AnyView
}
