//
//  CategoryListViewModel.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/5/31.
//
import SwiftUI

protocol CategoryListViewModelInteractor {
    func trackEvent(event: LoggableEvent)
    func getAvatarsForCategory(category: CharacterOption) async throws -> [AvatarModel]
}

extension CoreInteractor: CategoryListViewModelInteractor {}

@MainActor
@Observable
final class CategoryListViewModel {
    
    private let interactor: CategoryListViewModelInteractor
    init(interactor: CategoryListViewModelInteractor) {
        self.interactor = interactor
    }
    
    private(set) var avatars: [AvatarModel] = [] // AvatarModel.mocks
    var showAlert: AnyAppAlertItem?
    private(set) var isLoading: Bool = true

    func loadAvatars(category: CharacterOption) async {
        interactor.trackEvent(event: Event.loadAvatarsStart)
        do {
            avatars = try await interactor.getAvatarsForCategory(category: category)
            interactor.trackEvent(event: Event.loadAvatarsSuccess)
        } catch {
            showAlert = AnyAppAlertItem(error: error)
            interactor.trackEvent(event: Event.loadAvatarsFail(error: error))
        }
        isLoading = false
    }

    func onAvatarPressed(avatar: AvatarModel, path: Binding<[NavigationPathOption]>) {
        path.wrappedValue.append(.chatView(avatarId: avatar.avatarId, chat: nil))
        interactor.trackEvent(event: Event.avatarPressed(avatar: avatar))
    }
}

extension CategoryListViewModel {
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
