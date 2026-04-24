//
//  CategoryListView.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/4/24.
//

import SwiftUI

struct CategoryListView: View {
    var category: CharacterOption = .alien
    var imageName: String = Constants.randomImageUrl
    @State private var avatars: [AvatarModel] = AvatarModel.mocks
    @Binding var path: [NavigationPathOption] // 这个是从 ExploreView 传过来的
    var body: some View {
        List {
            CategoryCellView(
                title: category.plural.capitalized,
                imageName: imageName,
                font: .largeTitle,
                cornerRadius: 0
            )
            .removeListRowFormatting()

            ForEach(avatars, id: \.self) { avatar in
                CustomListCellView(
                    imageName: avatar.profileImageName,
                    title: avatar.name,
                    subTitle: avatar.characterDescription
                )
                .anyButton(.highlight) {
                    onAvatarPressed(avatar: avatar)
                }
                .removeListRowFormatting()
            }
        }
        .ignoresSafeArea()
        .listStyle(.plain)
        .customNavigationDestinationForCoreModule(path: $path)
    }
}

#Preview {
    CategoryListView(path: .constant([]))
}

// MARK: 事件
extension CategoryListView {
    private func onAvatarPressed(avatar: AvatarModel) {
        path.append(.chatView(avatarId: avatar.avatarId))
    }
}
