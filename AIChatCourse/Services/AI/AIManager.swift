//
//  AIManager.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/4/26.
//

import SwiftUI

@MainActor
@Observable
final class AIManager {
    private let service: AIService

    init(service: AIService) {
        self.service = service
    }

    func generateImage(prompt: String) async throws -> UIImage {
        try await service.generateImage(prompt: prompt)
    }
    
    func generateText(chats: [AIChatModel]) async throws -> AIChatModel {
        try await service.generateText(chats: chats)
    }
}
