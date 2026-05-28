//
//  ProfileViewModel.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/5/28.
//
import SwiftUI

@MainActor
@Observable
final class ProfileViewModel {
    // 注入 managers
    let userManager: UserManager
    let avatarManager: AvatarManager
    let authManager: AuthManager
    let logManager: LogManager
    let aiManager: AIManager // CreateAvatarView 页面需要
    init(userManager: UserManager, avatarManager: AvatarManager, authManager: AuthManager, logManager: LogManager, aiManager: AIManager) {
        self.userManager = userManager
        self.avatarManager = avatarManager
        self.authManager = authManager
        self.logManager = logManager
        self.aiManager = aiManager
    }

    private(set) var currentUser: UserModel?
    private(set) var myAvatars: [AvatarModel] = []
    private(set) var isLoading: Bool = true

    var showAlert: AnyAppAlertItem?
    var showCreateAvatarView: Bool = false
    var showSettingsView: Bool = false
    var path: [NavigationPathOption] = []

    func loadData() async {
        currentUser = userManager.currentUser
        logManager.trackEvent(event: Event.loadAvatarStart)
        do {
            let uid = try authManager.getCurrentUserId()
            myAvatars = try await avatarManager.getAvatarsForAuthor(userId: uid)
            logManager.trackEvent(event: Event.loadAvatarSuccess(count: myAvatars.count))
        } catch {
            logManager.trackEvent(event: Event.loadAvatarFial(error: error))
        }
        isLoading = false
    }

    func onSettingsButtonPressed() {
        logManager.trackEvent(event: Event.settingPressed)
        showSettingsView.toggle()
    }

    func onNewAvatarButtonPressed() {
        logManager.trackEvent(event: Event.newAvatarPressed)
        showCreateAvatarView = true
    }

    func onDeleteAvatar(indexSet: IndexSet) {
        guard let index = indexSet.first else { return }
        let avatar = myAvatars[index]
        logManager.trackEvent(event: Event.deleteAvatarStart(avatar: avatar))
        Task {
            do {
                try await avatarManager.removeAuthorIdFromAvatar(avatarId: avatar.id)
                myAvatars.remove(at: index)
                logManager.trackEvent(event: Event.deleteAvatarSuccess(avatar: avatar))
            } catch {
                showAlert = AnyAppAlertItem(title: "Unable to delete avatar.", subtitle: "Please try again.")
                logManager.trackEvent(event: Event.deleteAvatarFail(error: error))
            }
        }
    }

    func onAvatarPressed(avatar: AvatarModel) {
        logManager.trackEvent(event: Event.avatarPressed(avatar: avatar))
        path.append(.chatView(avatarId: avatar.avatarId, chat: nil))
    }
}

extension ProfileViewModel {
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
