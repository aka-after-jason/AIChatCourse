//
//  CustomError.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/5/2.
//

import Foundation

enum CustomError: Error, LocalizedError {
    case errorMessage(message: String)
}
