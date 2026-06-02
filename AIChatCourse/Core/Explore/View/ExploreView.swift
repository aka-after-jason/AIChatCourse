//
//  ExploreView.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/3/16.
//
import SwiftUI

struct ExploreView: View {
    @State var viewModel: ExploreViewModel

    var body: some View {
        NavigationStack(path: $viewModel.path) {
            List {
                if viewModel.featuredAvatars.isEmpty && viewModel.popularAvatars.isEmpty {
                    ZStack {
                        if viewModel.isLoadingFeatured || viewModel.isLoadingPopular {
                            loadingIndicator
                        } else {
                            // for edge case 边缘测试
                            errorMessageView
                        }
                    }
                    .removeListRowFormatting()
                }

                if !viewModel.popularAvatars.isEmpty {
                    if viewModel.categroyRowTest == .top {
                        categorySection
                    }
                }

                if !viewModel.featuredAvatars.isEmpty {
                    featuredSection
                }
                if !viewModel.popularAvatars.isEmpty {
                    if viewModel.categroyRowTest == .original {
                        categorySection
                    }
                    popularSection
                }
            }
            .navigationTitle("Explore")
            .appearAnalyticsViewModifier(name: "ExploreView")
            .toolbar(content: {
                ToolbarItem(placement: .topBarLeading) {
                    if viewModel.showDevSettingsButton {
                        devSettingsButton
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if viewModel.showNotificationButton {
                        pushNotificationButton
                    }
                }
            })
            .sheet(isPresented: $viewModel.showDevSettings, content: {
                DevSettingsView()
            })
            .sheet(isPresented: $viewModel.showCreateAccountView, content: {
                CreateAccountView()
                    .presentationDetents([.medium])
            })
            .showModal(showModal: $viewModel.showPushNotificationModal, content: {
                pushNotificationModal
            })
            .customNavigationDestinationForCoreModule(path: $viewModel.path)
            .task {
                await viewModel.loadFeaturedAvatars() // 没有先后顺序
            }
            .task {
                await viewModel.loadPopularAvatars() // 没有先后顺序
            }
            .task {
                await viewModel.handleShowPushNotificationButton()
            }
            .onFirstAppear {
                viewModel.schedulePushNotifications()
                viewModel.showCreateAccountScreenIfNeeded()
            }
            .onOpenURL { url in
                viewModel.handleDeepLink(url: url)
            }
        }
    }

    private var devSettingsButton: some View {
        Button(action: {
            viewModel.onDevSettingsButtonPressed()
        }, label: {
            Text("DEV 🤫")
        })
    }

    private var pushNotificationButton: some View {
        Image(systemName: "bell.fill")
            .font(.headline)
            .padding(4)
            .tappableBackground()
            .foregroundStyle(.accent)
            .anyButton {
                viewModel.onPushNotificationButtonPressed()
            }
    }

    private var pushNotificationModal: some View {
        CustomModalView(
            title: "Enable push notifications?",
            subtitle: "We'll send you reminders and updates!",
            primaryButtonTitle: "Enable",
            primaryButtonAction: {
                viewModel.onEnablePushNotificationPressed()
            },
            secondaryButtonTitle: "Cancel",
            secondaryButtonAction: {
                viewModel.onCancelPushNotificationPressed()
            }
        )
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
                viewModel.onTryAgainPressed()
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
                CarouselView(items: viewModel.featuredAvatars) { avatar in
                    HeroCellView(
                        title: avatar.name,
                        subTitle: avatar.characterDescription,
                        imageName: avatar.profileImageName
                    )
                    .anyButton {
                        viewModel.onAvatarPressed(avatar: avatar)
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
                        ForEach(viewModel.categories, id: \.self) { category in
                            let imageName = viewModel.popularAvatars.last(where: { $0.characterOption == category })?.profileImageName
                            if let imageName {
                                CategoryCellView(
                                    title: category.plural.capitalized,
                                    imageName: imageName
                                )
                                .anyButton {
                                    viewModel.onCategoryPressed(category: category, imageName: imageName)
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
            ForEach(viewModel.popularAvatars, id: \.self) { avatar in
                CustomListCellView(
                    imageName: avatar.profileImageName,
                    title: avatar.name,
                    subTitle: avatar.characterDescription
                )
                .anyButton(.highlight, action: {
                    viewModel.onAvatarPressed(avatar: avatar)
                })
                .removeListRowFormatting()
            }
        } header: {
            Text("Popular")
        }
    }
}

// MARK: Previews

#Preview("Has data") {
    let container = DevPreview.shared.container
    container.regiser(AvatarManager.self, manager: AvatarManager(service: MockAvatarService()))
    return ExploreView(viewModel: ExploreViewModel(interactor: CoreInteractor(container: container)))
        .previewEnvironment()
}

#Preview("No data") {
    let container = DevPreview.shared.container
    container.regiser(AvatarManager.self, manager: AvatarManager(service: MockAvatarService(avatars: [], delay: 1.0)))
    return ExploreView(viewModel: ExploreViewModel(interactor: CoreInteractor(container: container)))
        .previewEnvironment()
}

#Preview("Slow loading") {
    let container = DevPreview.shared.container
    container.regiser(AvatarManager.self, manager: AvatarManager(service: MockAvatarService()))
    return ExploreView(viewModel: ExploreViewModel(interactor: CoreInteractor(container: container)))
        .previewEnvironment()
}

#Preview("Has data With CreateAccount") {
    let container = DevPreview.shared.container
    container.regiser(AvatarManager.self, manager: AvatarManager(service: MockAvatarService()))
    container.regiser(AuthManager.self, manager: AuthManager(service: MockAuthService(user: .mock(isAnonymous: true))))
    container.regiser(ABTestManager.self, manager: ABTestManager(service: MockABTestService(createAccountTest: true)))
    return ExploreView(viewModel: ExploreViewModel(interactor: CoreInteractor(container: container)))
        .previewEnvironment()
}

#Preview("CategoryRowTest: original") {
    let container = DevPreview.shared.container
    container.regiser(ABTestManager.self, manager: ABTestManager(service: MockABTestService(categoryRowTest: .original)))
    return ExploreView(viewModel: ExploreViewModel(interactor: CoreInteractor(container: container)))
        .previewEnvironment()
}

#Preview("CategoryRowTest: top") {
    let container = DevPreview.shared.container
    container.regiser(ABTestManager.self, manager: ABTestManager(service: MockABTestService(categoryRowTest: .top)))
    return ExploreView(viewModel: ExploreViewModel(interactor: CoreInteractor(container: container)))
        .previewEnvironment()
}

#Preview("CategoryRowTest: hidden") {
    let container = DevPreview.shared.container
    container.regiser(ABTestManager.self, manager: ABTestManager(service: MockABTestService(categoryRowTest: .hidden)))
    return ExploreView(viewModel: ExploreViewModel(interactor: CoreInteractor(container: container)))
        .previewEnvironment()
}
