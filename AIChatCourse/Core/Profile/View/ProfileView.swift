//
//  ProfileView.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/3/16.
//

import SwiftUI

struct ProfileView: View {
    @State var presenter: ProfilePresenter
    var body: some View {
        List {
            myInfoSection
            myAvatarsSection
        }
        .navigationTitle("Profile")
        .appearAnalyticsViewModifier(name: "ProfileView")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                settingsButton
            }
        }
        .task {
            await presenter.loadData()
        }
    }
}

extension ProfileView {
    private var myInfoSection: some View {
        Section {
            ZStack {
                if let color = presenter.currentUser?.profileColorCalculated {
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
                if presenter.myAvatars.isEmpty {
                    Group {
                        if presenter.isLoading {
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
                    ForEach(presenter.myAvatars, id: \.self) { avatar in
                        CustomListCellView(
                            imageName: avatar.profileImageName,
                            title: avatar.name,
                            subTitle: nil
                        )
                        .anyButton(.highlight, action: {
                            presenter.onAvatarPressed(avatar: avatar)
                        })
                        .removeListRowFormatting()
                    }
                    .onDelete { indexSet in
                        presenter.onDeleteAvatar(indexSet: indexSet)
                    }
                }
            },
            header: {
                HStack {
                    Text("My Avatars")
                    Spacer()
                    Button(action: {
                        // show create avatar view
                        presenter.onNewAvatarButtonPressed()
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
                presenter.onSettingsButtonPressed()
            }
    }
}

#Preview {
    let builder = CoreBuilder(interactor: CoreInteractor(container: DevPreview.shared.container))
    return RouterView { router in
        builder.profileView(router: router)
            .previewEnvironment()
    }
}
