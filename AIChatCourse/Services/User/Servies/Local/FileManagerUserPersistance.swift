//
//  FileManagerUserPersistance.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/4/26.
//

import Foundation

struct FileManagerUserPersistance: LocalUserPersistance {
    func getCurrentUser() -> UserModel? {
        try? FileManager.getDocument(key: Constants.userDocumentKey)
    }
    
    func saveCurrentUser(user: UserModel?) throws {
        try FileManager.saveDocument(key: Constants.userDocumentKey, value: user)
    }
}
