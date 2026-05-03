//
//  MockAIService.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/4/26.
//

import SwiftUI

struct MockAIService: AIService {
    func generateImage(prompt: String) async throws -> UIImage {
        try await Task.sleep(for: .seconds(3))
        return UIImage(systemName: "star.fill")!
    }
    
    func generateText(chats: [AIChatModel]) async throws -> AIChatModel {
        try await Task.sleep(for: .seconds(1))
        return AIChatModel(role: .assistant, message: "This is returned text from AI.")
    }
}
