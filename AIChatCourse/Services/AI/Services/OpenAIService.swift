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
            model: .gpt4, // 模型
            n: 1, // 1张图片
            quality: .hd, // 高清
            responseFormat: .b64_json, // 返回 b64_json 格式数据
            size: ._512, // 图片大小
            style: .natural,
            user: nil
        )
        let result = try await openAI.images(query: query)
        guard let b64Json = result.data.first?.b64Json,
              let data = Data(base64Encoded: b64Json),
              let uiImage = UIImage(data: data)
        else {
            throw OpenAIError.invalidResponse
        }
        return uiImage
    }

    enum OpenAIError: LocalizedError {
        case invalidResponse
    }
}
