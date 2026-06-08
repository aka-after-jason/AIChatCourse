//
//  ExploreView.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/3/16.
//
import SwiftUI

/// struct ExploreView<DevSettingsView: View, CreateAccountView: View>: View {
struct ExploreView: View {
    // @ViewBuilder var devSettingsView: () -> DevSettingsView
    // @ViewBuilder var createAccountView: () -> CreateAccountView

    @State var viewModel: ExploreViewModel
    @ViewBuilder var devSettingsView: () -> AnyView // 可以使用泛型,也可以使用 AnyView
    @ViewBuilder var createAccountView: () -> AnyView
    @ViewBuilder var chatView: (ChatViewDelegate) -> AnyView
    @ViewBuilder var categoryListView: (CategoryListDelegate) -> AnyView
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
                devSettingsView()
            })
            .sheet(isPresented: $viewModel.showCreateAccountView, content: {
                createAccountView()
                    .presentationDetents([.medium])
            })
            .showModal(showModal: $viewModel.showPushNotificationModal, content: {
                pushNotificationModal
            })
            .customNavDestiForTabbarModule(
                path: $viewModel.path,
                chatView: chatView,
                categoryListView: categoryListView
            )
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

#Preview("Without Builder") {
    let container = DevPreview.shared.container
    container.regiser(AvatarManager.self, manager: AvatarManager(service: MockAvatarService()))
    return ExploreView(
        viewModel: ExploreViewModel(interactor: CoreInteractor(container: container)),
        devSettingsView: {
            Color.red.any()
        },
        createAccountView: {
            Color.green.any()
        },
        chatView: { _ in
            Color.blue.any()
        },
        categoryListView: { _ in
            Color.orange.any()
        }
    )
    .previewEnvironment()
}

#Preview("Has data") {
    let container = DevPreview.shared.container
    container.regiser(AvatarManager.self, manager: AvatarManager(service: MockAvatarService()))
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    return builder.exploreView()
        .previewEnvironment()
}

#Preview("No data") {
    let container = DevPreview.shared.container
    container.regiser(AvatarManager.self, manager: AvatarManager(service: MockAvatarService(avatars: [], delay: 1.0)))
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    return builder.exploreView()
        .previewEnvironment()
}

#Preview("Slow loading") {
    let container = DevPreview.shared.container
    container.regiser(AvatarManager.self, manager: AvatarManager(service: MockAvatarService()))
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    return builder.exploreView()
        .previewEnvironment()
}

#Preview("Has data With CreateAccount") {
    let container = DevPreview.shared.container
    container.regiser(AvatarManager.self, manager: AvatarManager(service: MockAvatarService()))
    container.regiser(AuthManager.self, manager: AuthManager(service: MockAuthService(user: .mock(isAnonymous: true))))
    container.regiser(ABTestManager.self, manager: ABTestManager(service: MockABTestService(createAccountTest: true)))
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    return builder.exploreView()
        .previewEnvironment()
}

#Preview("CategoryRowTest: original") {
    let container = DevPreview.shared.container
    container.regiser(ABTestManager.self, manager: ABTestManager(service: MockABTestService(categoryRowTest: .original)))
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    return builder.exploreView()
        .previewEnvironment()
}

#Preview("CategoryRowTest: top") {
    let container = DevPreview.shared.container
    container.regiser(ABTestManager.self, manager: ABTestManager(service: MockABTestService(categoryRowTest: .top)))
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    return builder.exploreView()
        .previewEnvironment()
}

#Preview("CategoryRowTest: hidden") {
    let container = DevPreview.shared.container
    container.regiser(ABTestManager.self, manager: ABTestManager(service: MockABTestService(categoryRowTest: .hidden)))
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    return builder.exploreView()
        .previewEnvironment()
}
