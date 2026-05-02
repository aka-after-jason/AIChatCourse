//
//  CategoryListView.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/4/24.
//

import SwiftUI

struct CategoryListView: View {
    @Environment(AvatarManager.self) private var avatarManager
    var category: CharacterOption = .alien
    var imageName: String = Constants.randomImageUrl
    @State private var avatars: [AvatarModel] = [] // AvatarModel.mocks
    @Binding var path: [NavigationPathOption] // 这个是从 ExploreView 传过来的
    @State private var showAlert: AnyAppAlertItem?
    @State private var isLoading: Bool = true
    var body: some View {
        List {
            CategoryCellView(
                title: category.plural.capitalized,
                imageName: imageName,
                font: .largeTitle,
                cornerRadius: 0
            )
            .removeListRowFormatting()

            if isLoading {
                ProgressView()
                    .padding(40)
                    .frame(maxWidth: .infinity)
                    .listRowSeparator(.hidden)
                    .removeListRowFormatting()
            } else if avatars.isEmpty {
                Text("No avatars found 😂")
                    .frame(maxWidth: .infinity)
                    .padding(40)
                    .foregroundStyle(.secondary)
                    .listRowSeparator(.hidden)
                    .removeListRowFormatting()
            } else {
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
        }
        .ignoresSafeArea()
        .listStyle(.plain)
        .customNavigationDestinationForCoreModule(path: $path)
        .showCustomAlert(alertItem: $showAlert)
        .task {
            await loadAvatars()
        }
    }

    private func loadAvatars() async {
        do {
            avatars = try await avatarManager.getAvatarsForCategory(category: category)
        } catch {
            showAlert = AnyAppAlertItem(error: error)
        }
        isLoading = false
    }
}

// MARK: 事件

extension CategoryListView {
    private func onAvatarPressed(avatar: AvatarModel) {
        path.append(.chatView(avatarId: avatar.avatarId))
    }
}

// MARK: Previews

#Preview("Has data") {
    CategoryListView(path: .constant([]))
        .environment(AvatarManager(service: MockAvatarService()))
}

#Preview("No data") {
    CategoryListView(path: .constant([]))
        .environment(AvatarManager(service: MockAvatarService(avatars: [])))
}

#Preview("Slow loading") {
    CategoryListView(path: .constant([]))
        .environment(AvatarManager(service: MockAvatarService(delay: 2.0)))
}

#Preview("Error loading") {
    CategoryListView(path: .constant([]))
        .environment(AvatarManager(service: MockAvatarService(delay: 2.0, showError: true)))
}
