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
        self.currentUser = userManager.currentUser
        do {
            let uid = try authManager.getCurrentUserId()
            myAvatars = try await avatarManager.getAvatarsForAuthor(userId: uid)
        } catch {
            print("Failed to fetch user avatars: \(error)")
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
        showSettingsView.toggle()
    }

    private func onNewAvatarButtonPressed() {
        showCreateAvatarView = true
    }

    private func onDeleteAvatar(indexSet: IndexSet) {
        guard let index = indexSet.first else { return }
        let avatar = myAvatars[index]
        Task {
            do {
                try await avatarManager.removeAuthorIdFromAvatar(avatarId: avatar.id)
                myAvatars.remove(at: index)
            } catch {
                showAlert = AnyAppAlertItem(title: "Unable to delete avatar.", subtitle: "Please try again.")
            }
        }
    }
}

#Preview {
    ProfileView()
        .previewEnvironment()
}

// MARK: 事件
extension ProfileView {
    private func onAvatarPressed(avatar: AvatarModel) {
        path.append(.chatView(avatarId: avatar.avatarId))
    }
}
