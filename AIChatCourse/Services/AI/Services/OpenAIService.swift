//
//  OpenAIService.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/4/26.
//
import OpenAI // Swift 操作 OpenAI 的 api
import SwiftUI

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
            throw CustomError.errorMessage(message: "没有拿到 b64Json，可能是模型/SDK版本/账单额度问题")
        }
        return uiImage
    }

    /// 调用 OpenAI api 生成chat
    func generateText(chats: [AIChatModel]) async throws -> AIChatModel {
        let messages = chats.compactMap { $0.toOpenAIModel() }
        let query = ChatQuery(messages: messages, model: .gpt4_o)
        let result = try await openAI.chats(query: query)
        guard let chat = result.choices.first?.message,
              let model = AIChatModel(chat: chat)
        else {
            throw CustomError.errorMessage(message: "Failed to generate text from OpenAI")
        }
        return model
    }
}

struct AIChatModel: Codable {
    let role: AIChatRole
    let message: String

    init(role: AIChatRole, message: String) {
        self.role = role
        self.message = message
    }

    init?(chat: ChatResult.Choice.Message) {
        self.role = AIChatRole(role: chat.role)
        guard let string = chat.content?.description else { return nil }
        self.message = string
    }

    func toOpenAIModel() -> ChatQuery.ChatCompletionMessageParam? {
        ChatQuery.ChatCompletionMessageParam(
            role: role.openAIRole,
            content: message
        )
    }
}

enum AIChatRole: String, Codable {
    case system, user, assistant, tool, developer

    init(role: String) {
        switch role {
        case "system":
            self = .system
        case "user":
            self = .user
        case "assistant":
            self = .assistant
        case "tool":
            self = .tool
        case "developer":
            self = .developer
        default:
            self = .developer
        }
    }

    var openAIRole: ChatQuery.ChatCompletionMessageParam.Role {
        switch self {
        case .system:
            return .system
        case .user:
            return .user
        case .assistant:
            return .assistant
        case .tool:
            return .tool
        case .developer:
            return .developer
        }
    }
}
