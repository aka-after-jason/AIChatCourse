//
//  CreateAvatarViewModel.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/5/28.
//

import SwiftUI

@MainActor
protocol CreateAvatarViewModelInteractor {
    func trackEvent(event: LoggableEvent)
    func generateImage(prompt: String) async throws -> UIImage
    func getCurrentUserId() throws -> String
    func createAvatar(avatar: AvatarModel, image: UIImage) async throws
}
extension CoreInteractor: CreateAvatarViewModelInteractor {}

@MainActor
protocol CreateAvatarViewModelRouter {
    func dismissScreen()
    func showAlert(error: Error)
}
extension CoreRouter: CreateAvatarViewModelRouter {}

@Observable
@MainActor
final class CreateAvatarViewModel {
    
    private let interactor: CreateAvatarViewModelInteractor
    private let router: CreateAvatarViewModelRouter
    init (interactor: CreateAvatarViewModelInteractor, router: CreateAvatarViewModelRouter) {
        self.interactor = interactor
        self.router = router
    }

    private(set) var isGenerating: Bool = false
    private(set) var generatedImage: UIImage?
    private(set) var isSvaing: Bool = false

    var characterOption: CharacterOption = .default
    var characterAction: CharacterAction = .default
    var characterLocation: CharacterLocation = .default
    var avatarName: String = ""

    func onBackButtonPressed() {
        interactor.trackEvent(event: Event.backButtonPressed)
        router.dismissScreen()
    }

    func onGenerateImagePressed() {
        interactor.trackEvent(event: Event.generateImageStart)
        isGenerating = true
        Task {
            do {
                let avatarDescriptionBuilder = AvatarDescriptionBuilder(
                    characterOption: characterOption,
                    characterAction: characterAction,
                    characterLocation: characterLocation
                )
                generatedImage = try await interactor.generateImage(prompt: avatarDescriptionBuilder.characterDescription)
                interactor.trackEvent(event: Event.generateImageSuccess(avatarDescriptionBuilder: avatarDescriptionBuilder))
            } catch {
                interactor.trackEvent(event: Event.generateImageFail(error: error))
            }
            isGenerating = false
        }
    }

    func onSavePressed() {
        interactor.trackEvent(event: Event.saveAvatarStart)
        guard let generatedImage else { return }
        isSvaing = true
        Task {
            do {
                try TextValidationHelper.checkIfTextIsValid(text: avatarName, minimumCharacterCount: 3)
                let uid = try interactor.getCurrentUserId()
                let newAvatar = AvatarModel.newAvatar(name: avatarName, option: characterOption, action: characterAction, location: characterLocation, authorId: uid)

                // UPLOAD!
                try await interactor.createAvatar(avatar: newAvatar, image: generatedImage)
                interactor.trackEvent(event: Event.saveAvatarSuccess(avatar: newAvatar))
                // dismiss screen
                router.dismissScreen()
            } catch {
                router.showAlert(error: error)
                interactor.trackEvent(event: Event.saveAvatarFail(error: error))
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
