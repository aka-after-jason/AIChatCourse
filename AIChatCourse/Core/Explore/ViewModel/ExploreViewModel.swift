//
//  ExploreViewModel.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/5/28.
//
import SwiftUI

protocol ExploreViewModelInteractor {
    var categoryRowTest: CategoryRowTestOption { get }
    var authUser: UserAuthInfoModel? { get }
    var createAccountTest: Bool { get }
    func canRequestAuthorization() async -> Bool
    func requestAuthorization() async throws -> Bool
    func schedulePushNotificationsForTheNextWeek()
    func getFeaturedAvatars() async throws -> [AvatarModel]
    func getPopularAvatars() async throws -> [AvatarModel]
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: ExploreViewModelInteractor {}

protocol ExploreViewModelRouter {
    func showCategoryListView(delegate: CategoryListDelegate)
    func showChatView(delegate: ChatViewDelegate)
    func showCreateAccountView(delegate: CreateAccountDelegate, onDisappear: @escaping () -> Void)
    func showPushNotificationModal(onEnablePressed: @escaping () -> Void, onCancelPressed: @escaping () -> Void)
    func showDevSettingsView()
    func dismissModal()
}

extension CoreRouter: ExploreViewModelRouter {}

@MainActor
@Observable
final class ExploreViewModel {
    private let interactor: ExploreViewModelInteractor
    private let router: ExploreViewModelRouter

    init(interactor: ExploreViewModelInteractor, router: ExploreViewModelRouter) {
        self.interactor = interactor
        self.router = router
    }

    private(set) var categories: [CharacterOption] = CharacterOption.allCases
    private(set) var featuredAvatars: [AvatarModel] = []
    private(set) var popularAvatars: [AvatarModel] = []
    private(set) var isLoadingFeatured: Bool = true
    private(set) var isLoadingPopular: Bool = true
    var showNotificationButton: Bool = false

    var categroyRowTest: CategoryRowTestOption {
        interactor.categoryRowTest
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
            guard interactor.authUser?.isAnonymous == true && interactor.createAccountTest == true else {
                return
            }
            router.showCreateAccountView(delegate: CreateAccountDelegate(), onDisappear: {})
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
        interactor.trackEvent(event: Event.deeplinkStart)
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems
        else {
            interactor.trackEvent(event: Event.deeplinkNoQueryItems)
            return
        }

        for queryItem in queryItems {
            // 解析 queryItem
            if queryItem.name == "category", let value = queryItem.value, let category = CharacterOption(rawValue: value) {
                let imageName = popularAvatars.first(where: { $0.characterOption == category })?.profileImageName ?? Constants.randomImageUrl
                let delegate = CategoryListDelegate(
                    category: category,
                    imageName: imageName
                )
                router.showCategoryListView(delegate: delegate)
                interactor.trackEvent(event: Event.deeplinkCategory(category: category))
                return
            }
        }
        interactor.trackEvent(event: Event.deeplinkUnknown)
    }

    func schedulePushNotifications() {
        interactor.schedulePushNotificationsForTheNextWeek()
    }

    func handleShowPushNotificationButton() async {
        showNotificationButton = await interactor.canRequestAuthorization()
    }

    func onPushNotificationButtonPressed() {
        interactor.trackEvent(event: Event.pushNotificationStart)
        router.showPushNotificationModal(
            onEnablePressed: {
                self.onEnablePushNotificationPressed()
            },
            onCancelPressed: {
                self.onCancelPushNotificationPressed()
            }
        )
    }

    func onEnablePushNotificationPressed() {
        router.dismissModal()
        Task {
            let isAuthorized = try await interactor.requestAuthorization()
            interactor.trackEvent(event: Event.pushNotificationEnable(isAuthorized: isAuthorized))
            await handleShowPushNotificationButton()
        }
    }

    func onCancelPushNotificationPressed() {
        interactor.trackEvent(event: Event.pushNotificationCancel)
        router.dismissModal()
    }

    func onDevSettingsButtonPressed() {
        interactor.trackEvent(event: Event.devSettingsPressed)
        router.showDevSettingsView()
    }

    func loadFeaturedAvatars() async {
        // If already loaded, no need to fetch again
        guard featuredAvatars.isEmpty else { return }
        interactor.trackEvent(event: Event.loadFeaturedAvatarsStart)
        do {
            featuredAvatars = try await interactor.getFeaturedAvatars()
            interactor.trackEvent(event: Event.loadFeaturedAvatarsSuccess(count: featuredAvatars.count))
        } catch {
            interactor.trackEvent(event: Event.loadFeaturedAvatarsFail(error: error))
        }
        isLoadingFeatured = false
    }

    func loadPopularAvatars() async {
        // If already loaded, no need to fetch again
        guard popularAvatars.isEmpty else { return }
        interactor.trackEvent(event: Event.loadPopularAvatarsStart)
        do {
            popularAvatars = try await interactor.getPopularAvatars()
            interactor.trackEvent(event: Event.loadPopularAvatarsSuccess(count: popularAvatars.count))
        } catch {
            interactor.trackEvent(event: Event.loadPopularAvatarsFail(error: error))
        }
        isLoadingPopular = false
    }

    func onAvatarPressed(avatar: AvatarModel) {
        interactor.trackEvent(event: Event.avatarPressed(avatar: avatar))
        let delegate = ChatViewDelegate(chat: nil, avatarId: avatar.avatarId)
        router.showChatView(delegate: delegate)
    }

    func onCategoryPressed(category: CharacterOption, imageName: String) {
        interactor.trackEvent(event: Event.categoryPressed(category: category))
        let delegate = CategoryListDelegate(
            category: category,
            imageName: imageName
        )
        router.showCategoryListView(delegate: delegate)
    }

    func onTryAgainPressed() {
        interactor.trackEvent(event: Event.tryAgainPressed)
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
