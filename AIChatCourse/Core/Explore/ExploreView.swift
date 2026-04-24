//
//  ExploreView.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/3/16.
//

import SwiftUI

struct ExploreView: View {
    // mock data
    let avatar = AvatarModel.mock
    @State private var featuredAvatars: [AvatarModel] = AvatarModel.mocks
    @State private var categories: [CharacterOption] = CharacterOption.allCases
    @State private var popularAvatars: [AvatarModel] = AvatarModel.mocks
    @State private var path: [NavigationPathOption] = []
    var body: some View {
        NavigationStack(path: $path) {
            List {
                featuredSection
                categorySection
                popularSection
            }
            .navigationTitle("Explore")
            .customNavigationDestinationForCoreModule(path: $path)
        }
    }

    private var featuredSection: some View {
        Section {
            ZStack {
                CarouselView(items: featuredAvatars) { avatar in
                    HeroCellView(
                        title: avatar.name,
                        subTitle: avatar.characterDescription,
                        imageName: avatar.profileImageName
                    )
                    .anyButton {
                        onAvatarPressed(avatar: avatar)
                    }
                }
            }
            .removeListRowFormatting()
        } header: {
            Text("Featured")
        }
    }

    private var categorySection: some View {
        Section {
            ZStack {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(categories, id: \.self) { category in
                            let imageName = popularAvatars.first(where: { $0.characterOption == category })?.profileImageName
                            if let imageName {
                                CategoryCellView(
                                    title: category.plural.capitalized,
                                    imageName: Constants.randomImageUrl
                                )
                                .anyButton {
                                    onCategoryPressed(category: category, imageName: imageName)
                                }
                            }
                        }
                    }
                }
                .scrollIndicators(.hidden)
                .frame(height: 140)
                .scrollTargetLayout()
                .scrollTargetBehavior(.viewAligned)
            }
        } header: {
            Text("Categories")
        }
    }

    private var popularSection: some View {
        Section {
            ForEach(popularAvatars, id: \.self) { avatar in
                CustomListCellView(
                    imageName: avatar.profileImageName,
                    title: avatar.name,
                    subTitle: avatar.characterDescription
                )
                .anyButton(.highlight, action: {
                    onAvatarPressed(avatar: avatar)
                })
                .removeListRowFormatting()
            }
        } header: {
            Text("Popular")
        }
    }
}

#Preview {
    ExploreView()
}

// MARK: 事件

extension ExploreView {
    private func onAvatarPressed(avatar: AvatarModel) {
        path.append(.chatView(avatarId: avatar.avatarId))
    }

    private func onCategoryPressed(category: CharacterOption, imageName: String) {
        path.append(.categoryListView(category: category, imageName: imageName))
    }
}
