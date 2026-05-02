//
//  FirebaseAvatarService.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/5/2.
//

import FirebaseFirestore
import SwiftfulFirestore

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
            .order(by: AvatarModel.CodingKeys.clickCount.rawValue, descending: true) // 排序
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
            // 根据创建时间来排序, 最新的放在最上面, 会提示需要创建 index
            .order(by: AvatarModel.CodingKeys.dateCreated.rawValue, descending: true) // sort on server
            .getAllDocuments()
        // .sorted(by: { ($0.dateCreated ?? .distantPast) > ($1.dateCreated ?? .distantPast) }) // sort on device
    }
    
    func incrementAvatarClickCount(avatarId: String) async throws {
        try await collection.document(avatarId).updateData([
            // 通过 FieldValue.increment(Int64(1) 设置clickCount 自动加1
            // 每进入一次 ChatView 页面, clickCount 的值都会加1
            // popularAvatars 就是根据 clickCount 的值来排序的
            AvatarModel.CodingKeys.clickCount.rawValue: FieldValue.increment(Int64(1))
        ])
    }
}
