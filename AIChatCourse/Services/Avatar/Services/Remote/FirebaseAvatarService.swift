//
//  FirebaseAvatarService.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/5/2.
//

import SwiftfulFirestore
import FirebaseFirestore

struct FirebaseAvatarService: RemoteAvatarService {
    var collection: CollectionReference {
        Firestore.firestore().collection(Constants.avatarCollectionName)
    }
    
    func createAvatar(avatar: AvatarModel, image: UIImage) async throws {
        // upload the image
        let path = "\(Constants.storageAvatarsFolderName)\(avatar.avatarId)"
        let imageUrl = try await StorageImageUploadService().uploadImage(image: image, path: path)
        
        // update the avatar profileImageName
        var avatar = avatar
        avatar.updateProfileImage(imageName: imageUrl)
        
        // upload the avatar
        try collection.document(avatar.avatarId).setData(from: avatar, merge: true)
    }
    
    func getAvatar(id: String) async throws -> AvatarModel {
        try await collection.getDocument(id: id)
    }
    
    func getFeaturedAvatars() async throws -> [AvatarModel] {
        try await collection
            .limit(to: 50)
            .getAllDocuments() // from SwiftfulFirestore
            .shuffled()
            .first(upTo: 5) ?? []
    }
    
    func getPopularAvatars() async throws -> [AvatarModel] {
        try await collection
            .limit(to: 200)
            .getAllDocuments()
    }
    
    func getAvatarsForCategory(category: CharacterOption) async throws -> [AvatarModel] {
        try await collection
            .whereField(AvatarModel.CodingKeys.characterOption.rawValue, isEqualTo: category.rawValue)
            .limit(to: 200)
            .getAllDocuments()
    }
    
    func getAvatarsForAuthor(userId: String) async throws -> [AvatarModel] {
        try await collection
            .whereField(AvatarModel.CodingKeys.authorId.rawValue, isEqualTo: userId)
            .getAllDocuments()
    }
}
