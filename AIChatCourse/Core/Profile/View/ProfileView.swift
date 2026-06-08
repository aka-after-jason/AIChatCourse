//
//  ProfileView.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/3/16.
//

import SwiftUI

struct ProfileView: View {
    @State var viewModel: ProfileViewModel
    @Environment(CoreBuilder.self) private var builder
    var body: some View {
        NavigationStack(path: $viewModel.path) {
            List {
                myInfoSection
                myAvatarsSection
            }
            .navigationTitle("Profile")
            .customNavDestiForTabbarModule(path: $viewModel.path)
            .appearAnalyticsViewModifier(name: "ProfileView")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    settingsButton
                }
            }
        }
        .sheet(isPresented: $viewModel.showSettingsView) {
            builder.settingsView()
        }
        .showCustomAlert(alertItem: $viewModel.showAlert)
        .fullScreenCover(
            isPresented: $viewModel.showCreateAvatarView,
            onDismiss: {
                Task {
                    await viewModel.loadData() // avatar 创建完成, 自动刷新
                }
            },
            content: {
                builder.createAvatarView()
            }
        )
        .task {
            await viewModel.loadData()
        }
    }
}

extension ProfileView {
    private var myInfoSection: some View {
        Section {
            ZStack {
                if let color = viewModel.currentUser?.profileColorCalculated {
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
                if viewModel.myAvatars.isEmpty {
                    Group {
                        if viewModel.isLoading {
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
                    ForEach(viewModel.myAvatars, id: \.self) { avatar in
                        CustomListCellView(
                            imageName: avatar.profileImageName,
                            title: avatar.name,
                            subTitle: nil
                        )
                        .anyButton(.highlight, action: {
                            viewModel.onAvatarPressed(avatar: avatar)
                        })
                        .removeListRowFormatting()
                    }
                    .onDelete { indexSet in
                        viewModel.onDeleteAvatar(indexSet: indexSet)
                    }
                }
            },
            header: {
                HStack {
                    Text("My Avatars")
                    Spacer()
                    Button(action: {
                        // show create avatar view
                        viewModel.onNewAvatarButtonPressed()
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
                viewModel.onSettingsButtonPressed()
            }
    }
}

#Preview {
    let builder = CoreBuilder(interactor: CoreInteractor(container: DevPreview.shared.container))
    return builder.profileView()
        .previewEnvironment()
}
