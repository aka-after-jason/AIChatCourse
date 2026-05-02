//
//  StorageImageUploadService.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/5/2.
//

import Foundation
import FirebaseStorage
import SwiftUI

protocol ImageUploadService {
    func uploadImage(image: UIImage, path: String) async throws -> String
}

struct StorageImageUploadService {
    func uploadImage(image: UIImage, path: String) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.25) else {
            throw CustomError.errorMessage(message: "Failed to get imageData")
        }
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        let ref = makeImageReference(path: path)
        _ = try await ref.putDataAsync(imageData, metadata: metadata)
        let urlString = try await ref.downloadURL().absoluteString
        return urlString
    }
    
    private nonisolated func makeImageReference(path: String) -> StorageReference {
        let name = "\(path).jpg"
        return Storage.storage().reference(withPath: name)
    }
}
