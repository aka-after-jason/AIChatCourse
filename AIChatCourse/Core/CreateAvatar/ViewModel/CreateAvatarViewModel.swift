//
//  CreateAvatarViewModel.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/5/28.
//

import SwiftUI

@Observable
@MainActor
final class CreateAvatarViewModel {
    // 注入 managers
    private let aiManager: AIManager
    private let authManager: AuthManager
    private let avatarManager: AvatarManager
    private let logManager: LogManager
    
    init(container: DependencyContainer) {
        self.aiManager = container.resolve(AIManager.self)!
        self.authManager = container.resolve(AuthManager.self)!
        self.avatarManager = container.resolve(AvatarManager.self)!
        self.logManager = container.resolve(LogManager.self)!
    }

    private(set) var isGenerating: Bool = false
    private(set) var generatedImage: UIImage?
    private(set) var isSvaing: Bool = false

    var characterOption: CharacterOption = .default
    var characterAction: CharacterAction = .default
    var characterLocation: CharacterLocation = .default
    var avatarName: String = ""
    var showAlert: AnyAppAlertItem?

    func onBackButtonPressed(onDismiss: () -> Void) {
        logManager.trackEvent(event: Event.backButtonPressed)
        onDismiss()
    }

    func onGenerateImagePressed() {
        logManager.trackEvent(event: Event.generateImageStart)
        isGenerating = true
        Task {
            do {
                let avatarDescriptionBuilder = AvatarDescriptionBuilder(
                    characterOption: characterOption,
                    characterAction: characterAction,
                    characterLocation: characterLocation
                )
                generatedImage = try await aiManager.generateImage(prompt: avatarDescriptionBuilder.characterDescription)
                logManager.trackEvent(event: Event.generateImageSuccess(avatarDescriptionBuilder: avatarDescriptionBuilder))
            } catch {
                logManager.trackEvent(event: Event.generateImageFail(error: error))
            }
            isGenerating = false
        }
    }

    func onSavePressed(onDismiss: @escaping () -> Void) {
        logManager.trackEvent(event: Event.saveAvatarStart)
        guard let generatedImage else { return }
        isSvaing = true
        Task {
            do {
                try TextValidationHelper.checkIfTextIsValid(text: avatarName, minimumCharacterCount: 3)
                let uid = try authManager.getCurrentUserId()
                let newAvatar = AvatarModel.newAvatar(name: avatarName, option: characterOption, action: characterAction, location: characterLocation, authorId: uid)

                // UPLOAD!
                try await avatarManager.createAvatar(avatar: newAvatar, image: generatedImage)
                logManager.trackEvent(event: Event.saveAvatarSuccess(avatar: newAvatar))
                // dismiss screen
                onDismiss()
            } catch {
                showAlert = AnyAppAlertItem(error: error)
                logManager.trackEvent(event: Event.saveAvatarFail(error: error))
            }
            isSvaing = false
        }
    }
}

extension CreateAvatarViewModel {
    enum Event: LoggableEvent {
        case backButtonPressed

        case generateImageStart
        case generateImageSuccess(avatarDescriptionBuilder: AvatarDescriptionBuilder)
        case generateImageFail(error: Error)

        case saveAvatarStart
        case saveAvatarSuccess(avatar: AvatarModel)
        case saveAvatarFail(error: Error)

        var eventName: String {
            switch self {
            case .backButtonPressed: return "CreateAvatarView_BackButton_Pressed"
            case .generateImageStart: return "CreateAvatarView_GenerateImage_Start"
            case .generateImageSuccess: return "CreateAvatarView_GenerateImage_Success"
            case .generateImageFail: return "CreateAvatarView_GenerateImage_Fail"
            case .saveAvatarStart: return "CreateAvatarView_SaveAvatar_Start"
            case .saveAvatarSuccess: return "CreateAvatarView_SaveAvatar_Success"
            case .saveAvatarFail: return "CreateAvatarView_SaveAvatar_Fail"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .generateImageFail(error: let error), .saveAvatarFail(error: let error):
                return error.eventParameters
            case .generateImageSuccess(avatarDescriptionBuilder: let descBuilder):
                return descBuilder.eventParameters
            case .saveAvatarSuccess(avatar: let avatar):
                return avatar.eventParameters
            default:
                return nil
            }
        }

        var type: CustomLogType {
            switch self {
            case .generateImageFail:
                return .severe
            case .saveAvatarFail:
                return .warning
            default:
                return .analytic
            }
        }
    }
}
