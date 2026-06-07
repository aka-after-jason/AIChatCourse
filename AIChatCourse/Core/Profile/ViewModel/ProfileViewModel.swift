//
//  ProfileViewModel.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/5/28.
//
import SwiftUI

// MARK: MVVM With Protocols

// 目的:
// 1. 不需要导入manager中所有的方法, 用到什么方法,在 protocol 里面添加
// 2. 方便单元测试

@MainActor
protocol ProfileViewModelInteractor {
    var currentUser: UserModel? { get }

    func getCurrentUserId() throws -> String
    func getAvatarsForAuthor(userId: String) async throws -> [AvatarModel]
    func removeAuthorIdFromAvatar(avatarId: String) async throws
    func trackEvent(event: LoggableEvent)
}

/// 这里使用 CoreInteractor
extension CoreInteractor: ProfileViewModelInteractor {}

// 也可以单独设置 ProductProfileViewModelInteractor
/*
 @MainActor
 struct ProductProfileViewModelInteractor: ProfileViewModelInteractor {

     // 注入 managers
     let userManager: UserManager
     let avatarManager: AvatarManager
     let authManager: AuthManager
     let logManager: LogManager

     init(container: DependencyContainer) {
         self.userManager = container.resolve(UserManager.self)!
         self.avatarManager = container.resolve(AvatarManager.self)!
         self.authManager = container.resolve(AuthManager.self)!
         self.logManager = container.resolve(LogManager.self)!
     }

     var currentUser: UserModel? {
         userManager.currentUser
     }

     func getCurrentUserId() throws -> String {
         try authManager.getCurrentUserId()
     }

     func getAvatarsForAuthor(userId: String) async throws -> [AvatarModel] {
         try await avatarManager.getAvatarsForAuthor(userId: userId)
     }

     func removeAuthorIdFromAvatar(avatarId: String) async throws {
         try await avatarManager.removeAuthorIdFromAvatar(avatarId: avatarId)
     }

     func trackEvent(event: any LoggableEvent) {
         logManager.trackEvent(event: event)
     }
 }
  */

@MainActor
@Observable
final class ProfileViewModel {
    /*
     private let interactor: ProfileViewModelInteractor
     init(interactor: ProfileViewModelInteractor) {
         self.interactor = interactor
     }
      */
    private let interactor: ProfileViewModelInteractor
    init(interactor: ProfileViewModelInteractor) {
        self.interactor = interactor
    }

    private(set) var currentUser: UserModel?
    private(set) var myAvatars: [AvatarModel] = []
    private(set) var isLoading: Bool = true

    var showAlert: AnyAppAlertItem?
    var showCreateAvatarView: Bool = false
    var showSettingsView: Bool = false
    var path: [NavTabbarPathOption] = []

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
        showSettingsView.toggle()
    }

    func onNewAvatarButtonPressed() {
        interactor.trackEvent(event: Event.newAvatarPressed)
        showCreateAvatarView = true
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
                showAlert = AnyAppAlertItem(title: "Unable to delete avatar.", subtitle: "Please try again.")
                interactor.trackEvent(event: Event.deleteAvatarFail(error: error))
            }
        }
    }

    func onAvatarPressed(avatar: AvatarModel) {
        interactor.trackEvent(event: Event.avatarPressed(avatar: avatar))
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
