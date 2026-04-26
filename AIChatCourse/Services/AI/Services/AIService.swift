//
//  AIService.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/4/26.
//
import SwiftUI

protocol AIService {
    func generateImage(prompt: String) async throws -> UIImage
}
