//
//  CategoryListView.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/4/24.
//

import SwiftUI

struct CategoryListView: View {
    @Environment(AvatarManager.self) private var avatarManager
    @Environment(LogManager.self) private var logManager
    var category: CharacterOption = .alien
    var imageName: String = Constants.randomImageUrl
    @State private var avatars: [AvatarModel] = [] // AvatarModel.mocks
    @Binding var path: [NavigationPathOption] // 这个是从 ExploreView 传过来的
    @State private var showAlert: AnyAppAlertItem?
    @State private var isLoading: Bool = true
    var body: some View {
        List {
            CategoryCellView(
                title: category.plural.capitalized,
                imageName: imageName,
                font: .largeTitle,
                cornerRadius: 0
            )
            .removeListRowFormatting()

            if isLoading {
                ProgressView()
                    .padding(40)
                    .frame(maxWidth: .infinity)
                    .listRowSeparator(.hidden)
                    .removeListRowFormatting()
            } else if avatars.isEmpty {
                Text("No avatars found 😂")
                    .frame(maxWidth: .infinity)
                    .padding(40)
                    .foregroundStyle(.secondary)
                    .listRowSeparator(.hidden)
                    .removeListRowFormatting()
            } else {
                ForEach(avatars, id: \.self) { avatar in
                    CustomListCellView(
                        imageName: avatar.profileImageName,
                        title: avatar.name,
                        subTitle: avatar.characterDescription
                    )
                    .anyButton(.highlight) {
                        onAvatarPressed(avatar: avatar)
                    }
                    .removeListRowFormatting()
                }
            }
        }
        .appearAnalyticsViewModifier(name: "CategoryListView")
        .ignoresSafeArea()
        .listStyle(.plain)
        .customNavigationDestinationForCoreModule(path: $path)
        .showCustomAlert(alertItem: $showAlert)
        .task {
            await loadAvatars()
        }
    }

    private func loadAvatars() async {
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
}

// MARK: 事件

extension CategoryListView {
    private func onAvatarPressed(avatar: AvatarModel) {
        path.append(.chatView(avatarId: avatar.avatarId, chat: nil))
        logManager.trackEvent(event: Event.avatarPressed(avatar: avatar))
    }
}

extension CategoryListView {
    enum Event: LoggableEvent {
        case loadAvatarsStart
        case loadAvatarsSuccess
        case loadAvatarsFail(error: Error)
        case avatarPressed(avatar: AvatarModel)
        var eventName: String {
            switch self {
            case .loadAvatarsStart:     return "CategoryListView_LoadAvatars_Start"
            case .loadAvatarsSuccess:   return "CategoryListView_LoadAvatars_Success"
            case .loadAvatarsFail:      return "CategoryListView_LoadAvatars_Fail"
            case .avatarPressed:        return "CategoryListView_Avatar_Pressed"
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

// MARK: Previews

#Preview("Has data") {
    CategoryListView(path: .constant([]))
        .environment(AvatarManager(service: MockAvatarService()))
        .previewEnvironment()
}

#Preview("No data") {
    CategoryListView(path: .constant([]))
        .environment(AvatarManager(service: MockAvatarService(avatars: [])))
        .previewEnvironment()
}

#Preview("Slow loading") {
    CategoryListView(path: .constant([]))
        .environment(AvatarManager(service: MockAvatarService(delay: 2.0)))
        .previewEnvironment()
}

#Preview("Error loading") {
    CategoryListView(path: .constant([]))
        .environment(AvatarManager(service: MockAvatarService(delay: 2.0, showError: true)))
        .previewEnvironment()
}
