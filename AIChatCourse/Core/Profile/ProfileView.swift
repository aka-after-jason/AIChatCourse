//
//  ProfileView.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/3/16.
//

import SwiftUI

struct ProfileView: View {
    @Environment(UserManager.self) private var userManager
    @Environment(AvatarManager.self) private var avatarManager
    @Environment(AuthManager.self) private var authManager
    @Environment(LogManager.self) private var logManager
    @State private var showSettingsView: Bool = false
    @State private var showCreateAvatarView: Bool = false
    @State private var currentUser: UserModel?
    @State private var myAvatars: [AvatarModel] = []
    @State private var isLoading: Bool = true
    @State private var showAlert: AnyAppAlertItem?
    @State private var path: [NavigationPathOption] = []
    var body: some View {
        NavigationStack(path: $path) {
            List {
                myInfoSection
                myAvatarsSection
            }
            .navigationTitle("Profile")
            .customNavigationDestinationForCoreModule(path: $path)
            .appearAnalyticsViewModifier(name: "ProfileView")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    settingsButton
                }
            }
        }
        .sheet(isPresented: $showSettingsView) {
            SettingsView()
        }
        .showCustomAlert(alertItem: $showAlert)
        .fullScreenCover(isPresented: $showCreateAvatarView, onDismiss: {
            Task {
                await loadData() // avatar 创建完成, 自动刷新
            }
        }, content: {
            CreateAvatarView()
        })
        .task {
            await loadData()
        }
    }

    private func loadData() async {
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

    private var myInfoSection: some View {
        Section {
            ZStack {
                if let color = currentUser?.profileColorCalculated {
                    Circle()
                        .fill(color)
                }
            }
            .frame(width: 100, height: 100)
            .frame(maxWidth: .infinity)
            .removeListRowFormatting()
        }
    }

    private var myAvatarsSection: some View {
        Section(
            content: {
                if myAvatars.isEmpty {
                    Group {
                        if isLoading {
                            ProgressView()
                        } else {
                            Text("Click + to create an avatar")
                        }
                    }
                    .padding(50)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .removeListRowFormatting()
                } else {
                    ForEach(myAvatars, id: \.self) { avatar in
                        CustomListCellView(
                            imageName: avatar.profileImageName,
                            title: avatar.name,
                            subTitle: nil
                        )
                        .anyButton(.highlight, action: {
                            onAvatarPressed(avatar: avatar)
                        })
                        .removeListRowFormatting()
                    }
                    .onDelete { indexSet in
                        onDeleteAvatar(indexSet: indexSet)
                    }
                }
            },
            header: {
                HStack {
                    Text("My Avatars")
                    Spacer()
                    Button(action: {
                        // show create avatar view
                        onNewAvatarButtonPressed()
                    }, label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title)
                    })
                }
            }
        )
    }

    private var settingsButton: some View {
        Image(systemName: "gear")
            .font(.headline)
            .foregroundStyle(.accent)
            .anyButton {
                onSettingsButtonPressed()
            }
    }

    private func onSettingsButtonPressed() {
        logManager.trackEvent(event: Event.settingPressed)
        showSettingsView.toggle()
    }

    private func onNewAvatarButtonPressed() {
        logManager.trackEvent(event: Event.newAvatarPressed)
        showCreateAvatarView = true
    }

    private func onDeleteAvatar(indexSet: IndexSet) {
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
}

// MARK: 事件

extension ProfileView {
    private func onAvatarPressed(avatar: AvatarModel) {
        logManager.trackEvent(event: Event.avatarPressed(avatar: avatar))
        path.append(.chatView(avatarId: avatar.avatarId, chat: nil))
    }
}

extension ProfileView {
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

#Preview {
    ProfileView()
        .previewEnvironment()
}
