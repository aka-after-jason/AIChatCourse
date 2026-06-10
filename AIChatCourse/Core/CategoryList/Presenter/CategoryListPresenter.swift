//
//  CategoryListPresenter.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/5/31.
//
import SwiftUI

@MainActor
@Observable
final class CategoryListPresenter {
    
    private let interactor: CategoryListInteractor
    private let router: CategoryListRouter
    init(interactor: CategoryListInteractor, router: CategoryListRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    private(set) var avatars: [AvatarModel] = [] // AvatarModel.mocks
    private(set) var isLoading: Bool = true

    func loadAvatars(category: CharacterOption) async {
        interactor.trackEvent(event: Event.loadAvatarsStart)
        do {
            avatars = try await interactor.getAvatarsForCategory(category: category)
            interactor.trackEvent(event: Event.loadAvatarsSuccess)
        } catch {
            interactor.trackEvent(event: Event.loadAvatarsFail(error: error))
            router.showAlert(error: error)
        }
        isLoading = false
    }

    func onAvatarPressed(avatar: AvatarModel) {
        interactor.trackEvent(event: Event.avatarPressed(avatar: avatar))
        let delegate = ChatViewDelegate(chat: nil, avatarId: avatar.avatarId)
        router.showChatView(delegate: delegate)
    }
}

extension CategoryListPresenter {
    enum Event: LoggableEvent {
        case loadAvatarsStart
        case loadAvatarsSuccess
        case loadAvatarsFail(error: Error)
        case avatarPressed(avatar: AvatarModel)
        var eventName: String {
            switch self {
            case .loadAvatarsStart: return "CategoryListView_LoadAvatars_Start"
            case .loadAvatarsSuccess: return "CategoryListView_LoadAvatars_Success"
            case .loadAvatarsFail: return "CategoryListView_LoadAvatars_Fail"
            case .avatarPressed: return "CategoryListView_Avatar_Pressed"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .loadAvatarsFail(error: let error):
                return error.eventParameters
            case .avatarPressed(avatar: let avatar):
                return avatar.eventParameters
            default:
                return nil
            }
        }

        var type: CustomLogType {
            switch self {
            case .loadAvatarsFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
}
