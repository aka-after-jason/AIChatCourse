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
                .removeListRowFormatting()
            }
        }
        .ignoresSafeArea()
        .listStyle(.plain)
    }
}

#Preview {
    CategoryListView()
}
