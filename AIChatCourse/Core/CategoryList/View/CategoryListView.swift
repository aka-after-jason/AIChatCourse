//
//  CategoryListView.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/4/24.
//

import SwiftUI

struct CategoryListView: View {
    @State var viewModel: CategoryListViewModel

    // 下面这几个属性保留在 view 里面, 没有放在 viewModel 中
    @Binding var path: [NavigationPathOption] // 这个是从 ExploreView 传过来的
    var category: CharacterOption = .alien
    var imageName: String = Constants.randomImageUrl

    var body: some View {
        List {
            CategoryCellView(
                title: category.plural.capitalized,
                imageName: imageName,
                font: .largeTitle,
                cornerRadius: 0
            )
            .removeListRowFormatting()

            if viewModel.isLoading {
                ProgressView()
                    .padding(40)
                    .frame(maxWidth: .infinity)
                    .listRowSeparator(.hidden)
                    .removeListRowFormatting()
            } else if viewModel.avatars.isEmpty {
                Text("No avatars found 😂")
                    .frame(maxWidth: .infinity)
                    .padding(40)
                    .foregroundStyle(.secondary)
                    .listRowSeparator(.hidden)
                    .removeListRowFormatting()
            } else {
                ForEach(viewModel.avatars, id: \.self) { avatar in
                    CustomListCellView(
                        imageName: avatar.profileImageName,
                        title: avatar.name,
                        subTitle: avatar.characterDescription
                    )
                    .anyButton(.highlight) {
                        viewModel.onAvatarPressed(avatar: avatar, path: $path)
                    }
                    .removeListRowFormatting()
                }
            }
        }
        .appearAnalyticsViewModifier(name: "CategoryListView")
        .ignoresSafeArea()
        .listStyle(.plain)
        .customNavigationDestinationForCoreModule(path: $path)
        .showCustomAlert(alertItem: $viewModel.showAlert)
        .task {
            await viewModel.loadAvatars(category: category)
        }
    }
}

// MARK: Previews

#Preview("Has data") {
    let container = DevPreview.shared.container
    container.regiser(AvatarManager.self, manager: AvatarManager(service: MockAvatarService()))
    return CategoryListView(viewModel: CategoryListViewModel(container: container), path: .constant([]))
        .previewEnvironment()
}

#Preview("No data") {
    let container = DevPreview.shared.container
    container.regiser(AvatarManager.self, manager: AvatarManager(service: MockAvatarService(avatars: [])))
    return CategoryListView(viewModel: CategoryListViewModel(container: container), path: .constant([]))
        .previewEnvironment()
}

#Preview("Slow loading") {
    let container = DevPreview.shared.container
    container.regiser(AvatarManager.self, manager: AvatarManager(service: MockAvatarService(delay: 2.0)))
    return CategoryListView(viewModel: CategoryListViewModel(container: container), path: .constant([]))
        .previewEnvironment()
}

#Preview("Error loading") {
    let container = DevPreview.shared.container
    container.regiser(AvatarManager.self, manager: AvatarManager(service: MockAvatarService(delay: 2.0, showError: true)))
    return CategoryListView(viewModel: CategoryListViewModel(container: container), path: .constant([]))
        .previewEnvironment()
}
