//
//  ProfileViewModel.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/5/28.
//
import SwiftUI

// MARK: MVVM With Protocols

@MainActor
@Observable
final class ProfilePresenter {
    private let interactor: ProfileInteractor
    private let router: ProfileRouter
    init(interactor: ProfileInteractor, router: ProfileRouter) {
        self.interactor = interactor
        self.router = router
    }

    private(set) var currentUser: UserModel?
    private(set) var myAvatars: [AvatarModel] = []
    private(set) var isLoading: Bool = true

    func loadData() async {
        currentUser = interactor.currentUser
        interactor.trackEvent(event: Event.loadAvatarStart)
        do {
            let uid = try interactor.getCurrentUserId()
            myAvatars = try await interactor.getAvatarsForAuthor(userId: uid)
            interactor.trackEvent(event: Event.loadAvatarSuccess(count: myAvatars.count))
        } catch {
            interactor.trackEvent(event: Event.loadAvatarFial(error: error))
        }
        isLoading = false
    }

    func onSettingsButtonPressed() {
        interactor.trackEvent(event: Event.settingPressed)
        router.showSettingsView()
    }

    func onNewAvatarButtonPressed() {
        interactor.trackEvent(event: Event.newAvatarPressed)
        router.showCreateAvatarView(onDisappear: {
            Task {
                await self.loadData()
            }
        })
    }

    func onDeleteAvatar(indexSet: IndexSet) {
        guard let index = indexSet.first else { return }
        let avatar = myAvatars[index]
        interactor.trackEvent(event: Event.deleteAvatarStart(avatar: avatar))
        Task {
            do {
                try await interactor.removeAuthorIdFromAvatar(avatarId: avatar.id)
                myAvatars.remove(at: index)
                interactor.trackEvent(event: Event.deleteAvatarSuccess(avatar: avatar))
            } catch {
                interactor.trackEvent(event: Event.deleteAvatarFail(error: error))
                router.showAlert(title: "Unable to delete avatar.", subtitle: "Please try again.")
            }
        }
    }

    func onAvatarPressed(avatar: AvatarModel) {
        interactor.trackEvent(event: Event.avatarPressed(avatar: avatar))
        let delegate = ChatViewDelegate(chat: nil, avatarId: avatar.avatarId)
        router.showChatView(delegate: delegate)
    }
}

extension ProfilePresenter {
    enum Event: LoggableEvent {
        case loadAvatarStart
        case loadAvatarSuccess(count: Int)
        case loadAvatarFial(error: Error)
        case settingPressed
        case newAvatarPressed
        case avatarPressed(avatar: AvatarModel)
        case deleteAvatarStart(avatar: AvatarModel)
        case deleteAvatarSuccess(avatar: AvatarModel)
        case deleteAvatarFail(error: Error)
        var eventName: String {
            switch self {
            case .loadAvatarStart: return "ProfileView_LoadAvatar_Start"
            case .loadAvatarSuccess: return "ProfileView_LoadAvatar_Success"
            case .loadAvatarFial: return "ProfileView_LoadAvatar_Fail"
            case .settingPressed: return "ProfileView_Setting_Pressed"
            case .newAvatarPressed: return "ProfileView_NewAvatar_Pressed"
            case .avatarPressed: return "ProfileView_Avatar_Pressed"
            case .deleteAvatarStart: return "ProfileView_DeleteAvatar_Start"
            case .deleteAvatarSuccess: return "ProfileView_DeleteAvatar_Success"
            case .deleteAvatarFail: return "ProfileView_DeleteAvatar_Fail"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .deleteAvatarFail(error: let error), .loadAvatarFial(error: let error):
                return error.eventParameters
            case .deleteAvatarStart(avatar: let avatar),
                 .deleteAvatarSuccess(avatar: let avatar),
                 .avatarPressed(avatar: let avatar):
                return avatar.eventParameters
            case .loadAvatarSuccess(count: let count):
                return ["avatars_count": count]
            default:
                return nil
            }
        }

        var type: CustomLogType {
            switch self {
            case .loadAvatarFial, .deleteAvatarFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
}
