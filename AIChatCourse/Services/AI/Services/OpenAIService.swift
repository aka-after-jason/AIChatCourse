//
//  OpenAIService.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/4/26.
//
import SwiftUI
import OpenAI // Swift 操作 OpenAI 的 api

struct OpenAIService: AIService {
    var openAI: OpenAI {
        OpenAI(apiToken: Keys.openAI)
    }

    /// 调用 OpenAI api 生成图片
    func generateImage(prompt: String) async throws -> UIImage {
        let query = ImagesQuery(
            prompt: prompt, // 提示词
            model: .gpt_image_1,
            n: 1, // 1张图片
            quality: .low,
            size: ._1024 // 图片大小
        )
        
        let result = try await openAI.images(query: query)
        guard let b64Json = result.data.first?.b64Json,
              let data = Data(base64Encoded: b64Json),
              let uiImage = UIImage(data: data)
        else {
            throw OpenAIError.invalidResponse("没有拿到 b64Json，可能是模型/SDK版本/账单额度问题")
        }
        return uiImage
    }

    enum OpenAIError: LocalizedError {
        case invalidResponse(String)

        var errorDescription: String? {
            switch self {
            case .invalidResponse(let message):
                return message
            }
        }
    }
}
