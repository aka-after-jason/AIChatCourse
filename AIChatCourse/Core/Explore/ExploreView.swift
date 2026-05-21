//
//  ExploreView.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/3/16.
//

import SwiftUI

struct ExploreView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(ABTestManager.self) private var abtestManager
    @Environment(PushManager.self) private var pushManager
    @Environment(AvatarManager.self) private var avatarManager
    @Environment(LogManager.self) private var logManager
    @State private var categories: [CharacterOption] = CharacterOption.allCases
    let avatar = AvatarModel.mock
    @State private var featuredAvatars: [AvatarModel] = []
    @State private var popularAvatars: [AvatarModel] = []
    @State private var isLoadingFeatured: Bool = true
    @State private var isLoadingPopular: Bool = true
    @State private var path: [NavigationPathOption] = []
    @State private var showDevSettings: Bool = false
    @State private var showNotificationButton: Bool = false
    @State private var showPushNotificationModal: Bool = false
    @State private var showCreateAccountView: Bool = false
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
                
                if !popularAvatars.isEmpty {
                    if abtestManager.activeABTestModel.categroyRowTest == .top {
                        categorySection
                    }
                }
                
                if !featuredAvatars.isEmpty {
                    featuredSection
                }
                if !popularAvatars.isEmpty {
                    if abtestManager.activeABTestModel.categroyRowTest == .original {
                        categorySection
                    }
                    popularSection
                }
            }
            .navigationTitle("Explore")
            .appearAnalyticsViewModifier(name: "ExploreView")
            .toolbar(content: {
                ToolbarItem(placement: .topBarLeading) {
                    if showDevSettingsButton {
                        devSettingsButton
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if showNotificationButton {
                        pushNotificationButton
                    }
                }
            })
            .sheet(isPresented: $showDevSettings, content: {
                DevSettingsView()
            })
            .sheet(isPresented: $showCreateAccountView, content: {
                CreateAccountView()
                    .presentationDetents([.medium])
            })
            .showModal(showModal: $showPushNotificationModal, content: {
                pushNotificationModal
            })
            .customNavigationDestinationForCoreModule(path: $path)
            .task {
                await loadFeaturedAvatars() // 没有先后顺序
            }
            .task {
                await loadPopularAvatars() // 没有先后顺序
            }
            .task {
                await handleShowPushNotificationButton()
            }
            .onFirstAppear {
                schedulePushNotifications()
                showCreateAccountScreenIfNeeded()
            }
            .onOpenURL { url in
                handleDeepLink(url: url)
            }
        }
    }

    private func showCreateAccountScreenIfNeeded() {
        Task {
            try? await Task.sleep(for: .seconds(2))

            // If the user doesn't already have an account (Anonymous)
            // If the user is in our ABTest
            guard authManager.authUser?.isAnonymous == true && abtestManager.activeABTestModel.createAccountTest == true else {
                return
            }
            showCreateAccountView = true
        }
    }

    /**
     deeplink
     1. 创建 deeplink:
        在 info.plist 里面 创建一个 URL Types, URL Scheme 填写为: aiChat
     2. 测试 deeplink:
        在 Calendar 里面创建一个event, URL填写为: aiChat://?category=alien
     */
    private func handleDeepLink(url: URL) {
        logManager.trackEvent(event: Event.deeplinkStart)
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems
        else {
            logManager.trackEvent(event: Event.deeplinkNoQueryItems)
            return
        }

        for queryItem in queryItems {
            // 解析 queryItem
            if queryItem.name == "category", let value = queryItem.value, let category = CharacterOption(rawValue: value) {
                let imageName = popularAvatars.first(where: { $0.characterOption == category })?.profileImageName ?? Constants.randomImageUrl
                path.append(.categoryListView(category: category, imageName: imageName))
                logManager.trackEvent(event: Event.deeplinkCategory(category: category))
                return
            }
        }
        logManager.trackEvent(event: Event.deeplinkUnknown)
    }

    private func schedulePushNotifications() {
        pushManager.schedulePushNotificationsForTheNextWeek()
    }

    private func handleShowPushNotificationButton() async {
        showNotificationButton = await pushManager.canRequestAuthorization()
    }

    private var pushNotificationModal: some View {
        CustomModalView(
            title: "Enable push notifications?",
            subtitle: "We'll send you reminders and updates!",
            primaryButtonTitle: "Enable",
            primaryButtonAction: {
                onEnablePushNotificationPressed()
            },
            secondaryButtonTitle: "Cancel",
            secondaryButtonAction: {
                onCancelPushNotificationPressed()
            }
        )
    }

    private func onPushNotificationButtonPressed() {
        showPushNotificationModal = true
        logManager.trackEvent(event: Event.pushNotificationStart)
    }

    private func onEnablePushNotificationPressed() {
        showPushNotificationModal = false
        Task {
            let isAuthorized = try await pushManager.requestAuthorization()
            logManager.trackEvent(event: Event.pushNotificationEnable(isAuthorized: isAuthorized))
            await handleShowPushNotificationButton()
        }
    }

    private func onCancelPushNotificationPressed() {
        showPushNotificationModal = false
        logManager.trackEvent(event: Event.pushNotificationCancel)
    }

    private var devSettingsButton: some View {
        Button(action: {
            onDevSettingsButtonPressed()
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
                onPushNotificationButtonPressed()
            }
    }

    private func onDevSettingsButtonPressed() {
        showDevSettings = true
        logManager.trackEvent(event: Event.devSettingsPressed)
    }

    private func loadFeaturedAvatars() async {
        // If already loaded, no need to fetch again
        guard featuredAvatars.isEmpty else { return }
        logManager.trackEvent(event: Event.loadFeaturedAvatarsStart)
        do {
            featuredAvatars = try await avatarManager.getFeaturedAvatars()
            logManager.trackEvent(event: Event.loadFeaturedAvatarsSuccess(count: featuredAvatars.count))
        } catch {
            logManager.trackEvent(event: Event.loadFeaturedAvatarsFail(error: error))
        }
        isLoadingFeatured = false
    }

    private func loadPopularAvatars() async {
        // If already loaded, no need to fetch again
        guard popularAvatars.isEmpty else { return }
        logManager.trackEvent(event: Event.loadPopularAvatarsStart)
        do {
            popularAvatars = try await avatarManager.getPopularAvatars()
            logManager.trackEvent(event: Event.loadPopularAvatarsSuccess(count: popularAvatars.count))
        } catch {
            logManager.trackEvent(event: Event.loadPopularAvatarsFail(error: error))
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
        logManager.trackEvent(event: Event.avatarPressed(avatar: avatar))
        path.append(.chatView(avatarId: avatar.avatarId, chat: nil))
    }

    private func onCategoryPressed(category: CharacterOption, imageName: String) {
        logManager.trackEvent(event: Event.categoryPressed(category: category))
        path.append(.categoryListView(category: category, imageName: imageName))
    }

    private func onTryAgainPressed() {
        logManager.trackEvent(event: Event.tryAgainPressed)
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

extension ExploreView {
    enum Event: LoggableEvent {
        case devSettingsPressed
        case tryAgainPressed
        case avatarPressed(avatar: AvatarModel)
        case categoryPressed(category: CharacterOption)
        case loadFeaturedAvatarsStart
        case loadFeaturedAvatarsSuccess(count: Int)
        case loadFeaturedAvatarsFail(error: Error)
        case loadPopularAvatarsStart
        case loadPopularAvatarsSuccess(count: Int)
        case loadPopularAvatarsFail(error: Error)
        case pushNotificationStart
        case pushNotificationEnable(isAuthorized: Bool)
        case pushNotificationCancel
        case deeplinkStart
        case deeplinkNoQueryItems
        case deeplinkCategory(category: CharacterOption)
        case deeplinkUnknown

        var eventName: String {
            switch self {
            case .devSettingsPressed: return "ExploreView_DevSettings_Pressed"
            case .tryAgainPressed: return "ExploreView_TryAgain_Pressed"
            case .avatarPressed: return "ExploreView_Avatar_Pressed"
            case .categoryPressed: return "ExploreView_Category_Pressed"
            case .loadFeaturedAvatarsStart: return "ExploreView_LoadFeaturedAvatar_Start"
            case .loadFeaturedAvatarsSuccess: return "ExploreView_LoadFeaturedAvatar_Success"
            case .loadFeaturedAvatarsFail: return "ExploreView_LoadFeaturedAvatar_Fail"
            case .loadPopularAvatarsStart: return "ExploreView_LoadPopularAvatar_Start"
            case .loadPopularAvatarsSuccess: return "ExploreView_LoadPopularAvatar_Success"
            case .loadPopularAvatarsFail: return "ExploreView_LoadPopularAvatar_Fail"
            case .pushNotificationStart: return "ExploreView_PushNotification_Start"
            case .pushNotificationEnable: return "ExploreView_PushNotification_Enable"
            case .pushNotificationCancel: return "ExploreView_PushNotification_Cancel"
            case .deeplinkStart: return "ExploreView_DeepLink_Start"
            case .deeplinkNoQueryItems: return "ExploreView_DeepLink_No_Query_Items"
            case .deeplinkCategory: return "ExploreView_DeepLink_Category"
            case .deeplinkUnknown: return "ExploreView_DeepLink_Unknown"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .avatarPressed(avatar: let avatar):
                return avatar.eventParameters
            case .categoryPressed(category: let category):
                return ["category": category.rawValue]
            case .loadFeaturedAvatarsFail(error: let error), .loadPopularAvatarsFail(error: let error):
                return error.eventParameters
            case .loadFeaturedAvatarsSuccess(count: let count), .loadPopularAvatarsSuccess(count: let count):
                return ["avatar_count": count]
            case .pushNotificationEnable(isAuthorized: let isAuthorized):
                return ["is_authorized": isAuthorized]
            case .deeplinkCategory(category: let category):
                return ["category": category.rawValue]
            default:
                return nil
            }
        }

        var type: CustomLogType {
            switch self {
            case .loadFeaturedAvatarsFail, .loadPopularAvatarsFail, .deeplinkUnknown:
                return .severe
            default:
                return .analytic
            }
        }
    }
}

// MARK: Previews

#Preview("Has data") {
    ExploreView()
        .environment(AvatarManager(service: MockAvatarService()))
        .previewEnvironment()
}

#Preview("No data") {
    ExploreView()
        .environment(AvatarManager(service: MockAvatarService(avatars: [], delay: 1.0)))
        .previewEnvironment()
}

#Preview("Slow loading") {
    ExploreView()
        .environment(AvatarManager(service: MockAvatarService()))
        .previewEnvironment()
}

#Preview("Has data With CreateAccount") {
    ExploreView()
        .environment(AvatarManager(service: MockAvatarService()))
        .environment(AuthManager(service: MockAuthService(user: .mock(isAnonymous: true))))
        .environment(ABTestManager(service: MockABTestService(createAccountTest: true)))
        .previewEnvironment()
}

#Preview("CategoryRowTest: original") {
    ExploreView()
        .environment(ABTestManager(service: MockABTestService(categoryRowTest: .original)))
        .previewEnvironment()
}

#Preview("CategoryRowTest: top") {
    ExploreView()
        .environment(ABTestManager(service: MockABTestService(categoryRowTest: .top)))
        .previewEnvironment()
}

#Preview("CategoryRowTest: hidden") {
    ExploreView()
        .environment(ABTestManager(service: MockABTestService(categoryRowTest: .hidden)))
        .previewEnvironment()
}
