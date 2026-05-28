//
//  ExploreViewModel.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/5/28.
//
import SwiftUI

@MainActor
@Observable
final class ExploreViewModel {
    
    private let authManager: AuthManager
    private let abtestManager: ABTestManager
    private let pushManager: PushManager
    private let avatarManager: AvatarManager
    private let logManager: LogManager

    init(container: DependencyContainer) {
        self.authManager = container.resolve(AuthManager.self)!
        self.abtestManager = container.resolve(ABTestManager.self)!
        self.pushManager = container.resolve(PushManager.self)!
        self.avatarManager = container.resolve(AvatarManager.self)!
        self.logManager = container.resolve(LogManager.self)!
    }

    private(set) var categories: [CharacterOption] = CharacterOption.allCases
    private(set) var featuredAvatars: [AvatarModel] = []
    private(set) var popularAvatars: [AvatarModel] = []
    private(set) var isLoadingFeatured: Bool = true
    private(set) var isLoadingPopular: Bool = true

    var path: [NavigationPathOption] = []
    var showDevSettings: Bool = false
    var showNotificationButton: Bool = false
    var showPushNotificationModal: Bool = false
    var showCreateAccountView: Bool = false
    
    var categroyRowTest: CategoryRowTestOption {
        abtestManager.activeABTestModel.categroyRowTest
    }
    
    var showDevSettingsButton: Bool {
        #if DEV || MOCK
        return true
        #else
        return false
        #endif
    }

    func showCreateAccountScreenIfNeeded() {
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
    func handleDeepLink(url: URL) {
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

    func schedulePushNotifications() {
        pushManager.schedulePushNotificationsForTheNextWeek()
    }

    func handleShowPushNotificationButton() async {
        showNotificationButton = await pushManager.canRequestAuthorization()
    }

    func onPushNotificationButtonPressed() {
        showPushNotificationModal = true
        logManager.trackEvent(event: Event.pushNotificationStart)
    }

    func onEnablePushNotificationPressed() {
        showPushNotificationModal = false
        Task {
            let isAuthorized = try await pushManager.requestAuthorization()
            logManager.trackEvent(event: Event.pushNotificationEnable(isAuthorized: isAuthorized))
            await handleShowPushNotificationButton()
        }
    }

    func onCancelPushNotificationPressed() {
        showPushNotificationModal = false
        logManager.trackEvent(event: Event.pushNotificationCancel)
    }

    func onDevSettingsButtonPressed() {
        showDevSettings = true
        logManager.trackEvent(event: Event.devSettingsPressed)
    }

    func loadFeaturedAvatars() async {
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

    func loadPopularAvatars() async {
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

    func onAvatarPressed(avatar: AvatarModel) {
        logManager.trackEvent(event: Event.avatarPressed(avatar: avatar))
        path.append(.chatView(avatarId: avatar.avatarId, chat: nil))
    }

    func onCategoryPressed(category: CharacterOption, imageName: String) {
        logManager.trackEvent(event: Event.categoryPressed(category: category))
        path.append(.categoryListView(category: category, imageName: imageName))
    }

    func onTryAgainPressed() {
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

extension ExploreViewModel {
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
