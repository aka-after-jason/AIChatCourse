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
}
