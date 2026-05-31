//
//  CategoryListViewModel.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/5/31.
//
import SwiftUI

@MainActor
@Observable
final class CategoryListViewModel {
    private let avatarManager: AvatarManager
    private let logManager: LogManager
    init(container: DependencyContainer) {
        self.avatarManager = container.resolve(AvatarManager.self)!
        self.logManager = container.resolve(LogManager.self)!
    }

    private(set) var avatars: [AvatarModel] = [] // AvatarModel.mocks
    var showAlert: AnyAppAlertItem?
    private(set) var isLoading: Bool = true

    func loadAvatars(category: CharacterOption) async {
        logManager.trackEvent(event: Event.loadAvatarsStart)
        do {
            avatars = try await avatarManager.getAvatarsForCategory(category: category)
            logManager.trackEvent(event: Event.loadAvatarsSuccess)
        } catch {
            showAlert = AnyAppAlertItem(error: error)
            logManager.trackEvent(event: Event.loadAvatarsFail(error: error))
        }
        isLoading = false
    }

    func onAvatarPressed(avatar: AvatarModel, path: Binding<[NavigationPathOption]>) {
        path.wrappedValue.append(.chatView(avatarId: avatar.avatarId, chat: nil))
        logManager.trackEvent(event: Event.avatarPressed(avatar: avatar))
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
