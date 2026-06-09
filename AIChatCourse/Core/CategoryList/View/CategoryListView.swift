//
//  CategoryListView.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/4/24.
//

import SwiftUI

/// CategoryListView页面需要的参数
struct CategoryListDelegate {
    // 下面这几个属性保留在 view 里面, 没有放在 viewModel 中
    var category: CharacterOption = .alien
    var imageName: String = Constants.randomImageUrl
}

struct CategoryListView: View {
    @State var viewModel: CategoryListViewModel
    let delegate: CategoryListDelegate
    var body: some View {
        List {
            CategoryCellView(
                title: delegate.category.plural.capitalized,
                imageName: delegate.imageName,
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
                        viewModel.onAvatarPressed(avatar: avatar)
                    }
                    .removeListRowFormatting()
                }
            }
        }
        .appearAnalyticsViewModifier(name: "CategoryListView")
        .ignoresSafeArea()
        .listStyle(.plain)
        .task {
            await viewModel.loadAvatars(category: delegate.category)
        }
    }
}

// MARK: Previews

#Preview("Has data") {
    let container = DevPreview.shared.container
    container.regiser(AvatarManager.self, manager: AvatarManager(service: MockAvatarService()))
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = CategoryListDelegate()
    return RouterView { router in
        builder.categoryListView(router: router, delegate: delegate)
            .previewEnvironment()
    }
}

#Preview("No data") {
    let container = DevPreview.shared.container
    container.regiser(AvatarManager.self, manager: AvatarManager(service: MockAvatarService(avatars: [])))
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = CategoryListDelegate()
    return RouterView { router in
        builder.categoryListView(router: router, delegate: delegate)
            .previewEnvironment()
    }
}

#Preview("Slow loading") {
    let container = DevPreview.shared.container
    container.regiser(AvatarManager.self, manager: AvatarManager(service: MockAvatarService(delay: 2.0)))
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = CategoryListDelegate()
    return RouterView { router in
        builder.categoryListView(router: router, delegate: delegate)
            .previewEnvironment()
    }
}

#Preview("Error loading") {
    let container = DevPreview.shared.container
    container.regiser(AvatarManager.self, manager: AvatarManager(service: MockAvatarService(delay: 2.0, showError: true)))
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = CategoryListDelegate()
    return RouterView { router in
        builder.categoryListView(router: router, delegate: delegate)
            .previewEnvironment()
    }
}
