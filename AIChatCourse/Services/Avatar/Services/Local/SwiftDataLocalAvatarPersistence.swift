//
//  SwiftDataLocalAvatarPersistence.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/5/2.
//

import SwiftUI
import SwiftData

@MainActor
struct SwiftDataLocalAvatarPersistence: LocalAvatarPersistence {
    private let container: ModelContainer
    private var mainContext: ModelContext {
        container.mainContext
    }
    init() {
        // swiftlint:disable:next force_try
        self.container = try! ModelContainer(for: AvatarEntity.self)
    }
    
    /// 添加 avatar
    func addRecentAvatar(avatar: AvatarModel) throws {
        let entity = AvatarEntity(from: avatar)
        mainContext.insert(entity)
        try mainContext.save()
    }
    
    /// 获取保存到 SwiftData 所有的 avatars, 按添加时间排序
    func getRecentAvatars() throws -> [AvatarModel] {
        let descriptor = FetchDescriptor<AvatarEntity>(
            sortBy: [SortDescriptor(\.dateAdded, order: .reverse)]
        )
        let entities = try mainContext.fetch(descriptor)
        return entities.map({ $0.toModel() })
    }
}
