//
//  ExploreView.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/3/16.
//

import SwiftUI

struct ExploreView: View {
    @Environment(AvatarManager.self) private var avatarManager
    @State private var categories: [CharacterOption] = CharacterOption.allCases
    let avatar = AvatarModel.mock
    @State private var featuredAvatars: [AvatarModel] = []
    @State private var popularAvatars: [AvatarModel] = []
    @State private var isLoadingFeatured: Bool = true
    @State private var isLoadingPopular: Bool = true
    @State private var path: [NavigationPathOption] = []
    @State private var showDevSettings: Bool = false
    private var showDevSettingsButton: Bool {
        #if DEV || MOCK
        return true
        #else
        return false
        #endif
    }
    var body: some View {
        NavigationStack(path: $path) {
            List {
                if featuredAvatars.isEmpty && popularAvatars.isEmpty {
                    ZStack {
                        if isLoadingFeatured || isLoadingPopular {
                            loadingIndicator
                        } else {
                            // for edge case 边缘测试
                            errorMessageView
                        }
                    }
                    .removeListRowFormatting()
                }
                if !featuredAvatars.isEmpty {
                    featuredSection
                }
                if !popularAvatars.isEmpty {
                    categorySection
                    popularSection
                }
            }
            .navigationTitle("Explore")
            .toolbar(content: {
                ToolbarItem(placement: .topBarLeading) {
                    if showDevSettingsButton {
                        devSettingsButton
                    }
                }
            })
            .sheet(isPresented: $showDevSettings, content: {
                DevSettingsView()
            })
            .customNavigationDestinationForCoreModule(path: $path)
            .task {
                await loadFeaturedAvatars() // 没有先后顺序
            }
            .task {
                await loadPopularAvatars() // 没有先后顺序
            }
        }
    }
    
    private var devSettingsButton: some View {
        Button(action: {
            onDevSettingsButtonPressed()
        }, label: {
            Text("DEV 🤫")
        })
    }
    
    private func onDevSettingsButtonPressed() {
        showDevSettings = true
    }

    private func loadFeaturedAvatars() async {
        // If already loaded, no need to fetch again
        guard featuredAvatars.isEmpty else { return }
        do {
            featuredAvatars = try await avatarManager.getFeaturedAvatars()
        } catch {
            print("Failed to load Featured avatars: \(error)")
        }
        isLoadingFeatured = false
    }

    private func loadPopularAvatars() async {
        // If already loaded, no need to fetch again
        guard popularAvatars.isEmpty else { return }
        do {
            popularAvatars = try await avatarManager.getPopularAvatars()
        } catch {
            print("Failed to load Popular avatars: \(error)")
        }
        isLoadingPopular = false
    }
}

// MARK: 抽取属性view
extension ExploreView {
    private var loadingIndicator: some View {
        ProgressView()
            .padding(40)
            .frame(maxWidth: .infinity)
    }
    
    private var errorMessageView: some View {
        VStack(alignment: .center, spacing: 8) {
            Text("Error")
                .font(.headline)
            Text("Please check your internet connection and try again.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Button("Try again") {
                onTryAgainPressed()
            }
            .foregroundStyle(.blue)
        }
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.center)
        .padding(40)
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
                            let imageName = popularAvatars.last(where: { $0.characterOption == category })?.profileImageName
                            if let imageName {
                                CategoryCellView(
                                    title: category.plural.capitalized,
                                    imageName: imageName
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

// MARK: 事件

extension ExploreView {
    private func onAvatarPressed(avatar: AvatarModel) {
        path.append(.chatView(avatarId: avatar.avatarId, chat: nil))
    }

    private func onCategoryPressed(category: CharacterOption, imageName: String) {
        path.append(.categoryListView(category: category, imageName: imageName))
    }
    
    private func onTryAgainPressed() {
        isLoadingFeatured = true
        isLoadingPopular = true
        Task {
            await loadFeaturedAvatars() // 没有先后顺序
        }
        Task {
            await loadPopularAvatars() // 没有先后顺序
        }
    }
}

// MARK: Previews

#Preview("Has data") {
    ExploreView()
        .environment(AvatarManager(service: MockAvatarService()))
}

#Preview("No data") {
    ExploreView()
        .environment(AvatarManager(service: MockAvatarService(avatars: [], delay: 1.0)))
}

#Preview("Slow loading") {
    ExploreView()
        .environment(AvatarManager(service: MockAvatarService()))
}
