//
//  TextValidationHelper.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/4/23.
//

import Foundation

struct TextValidationHelper {
    
    static func checkIfTextIsValid(text: String, minimumCharacterCount: Int = 4) throws {
        // text length
        guard text.count >= minimumCharacterCount else {
            throw TextValidationError.notEnoughCharacters(min: minimumCharacterCount)
        }
        
        // badwords
        let badwords: [String] = [
            "shit", "ass", "bitch"
        ]
        if badwords.contains(text.lowercased()) {
            throw TextValidationError.hasBadwords
        }
    }
    
    enum TextValidationError: LocalizedError {
        case notEnoughCharacters(min: Int)
        case hasBadwords
        
        var errorDescription: String? {
            switch self {
            case .notEnoughCharacters(min: let min):
                return "Please add at least \(min) characters."
            case .hasBadwords:
                return "Bad word detected. Please rephrase your message."
            }
        }
    }
}
