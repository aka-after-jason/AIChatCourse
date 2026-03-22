//
//  ProfileView.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/3/16.
//

import SwiftUI

struct ProfileView: View {
    @State private var showSettingsView: Bool = false
    @State private var showCreateAvatarView: Bool = false
    @State private var currentUser: UserModel? = .mock
    @State private var myAvatars: [AvatarModel] = []
    @State private var isLoading: Bool = true
    var body: some View {
        NavigationStack {
            List {
                myInfoSection
                myAvatarsSection
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    settingsButton
                }
            }
        }
        .sheet(isPresented: $showSettingsView) {
            SettingsView()
        }
        .fullScreenCover(isPresented: $showCreateAvatarView) {
            CreateAvatarView()
        }
        .task {
            await loadData()
        }
    }

    private func loadData() async {
        try? await Task.sleep(for: .seconds(2))
        isLoading = false
        myAvatars = AvatarModel.mocks
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
                        .anyButton(.highlight, action: {})
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
        myAvatars.remove(at: index)
    }
}

#Preview {
    ProfileView()
        .environment(AppState())
}
