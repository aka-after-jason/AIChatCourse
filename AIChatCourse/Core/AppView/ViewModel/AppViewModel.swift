//
//  AppViewModel.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/6/7.
//
import SwiftUI
import FirebaseFunctions

protocol AppViewModelInteractor {
    var authUser: UserAuthInfoModel? { get }
    var showTabBar: Bool { get }
    func trackEvent(event: LoggableEvent)
    func trackEvent(eventName: String, parameters: [String: Any]?, type: CustomLogType)
    func login(user: UserAuthInfoModel, isNewUser: Bool) async throws
    func signInAnonymously() async throws -> (user: UserAuthInfoModel, isNewUser: Bool)
}

extension RootInteractor: AppViewModelInteractor {}

@MainActor
@Observable
final class AppViewModel {
    private let interactor: AppViewModelInteractor
    init(interactor: AppViewModelInteractor) {
        self.interactor = interactor
    }

    var authUser: UserAuthInfoModel? {
        interactor.authUser
    }
    
    var showTabBar: Bool {
        interactor.showTabBar
    }

    /// Test
    /// 读取 firebase cloud functions
    func getDataFromMyNewEndpoint() async {
        interactor.trackEvent(eventName: "HelloDev:: Start", parameters: nil, type: .analytic)
        do {
            let result = try await Functions.functions().httpsCallable("helloDeveloper").call()
            let string = result.data as? String
            interactor.trackEvent(eventName: "HelloDev:: \(string ?? "nostring")", parameters: nil, type: .analytic)
        } catch {
            interactor.trackEvent(eventName: "HelloDev:: Error: \(error.localizedDescription)", parameters: nil, type: .analytic)
        }
    }

    func checkUserStatus() async {
        if let user = interactor.authUser {
            // user is authenticated
            interactor.trackEvent(event: Event.existingAuthStart)
            do {
                try await interactor.login(user: user, isNewUser: false)
            } catch {
                interactor.trackEvent(event: Event.existingAuthFail(error: error))
                try? await Task.sleep(for: .seconds(3))
                await checkUserStatus()
            }
        } else {
            // user is not authenticated
            interactor.trackEvent(event: Event.anonymousAuthStart)
            do {
                let (user, isNewUser) = try await interactor.signInAnonymously()
                try await interactor.login(user: user, isNewUser: isNewUser)
                JPushManager.shared.setAlias(user.uid)
                JPushManager.shared.setTags(["ios", "user"])
                interactor.trackEvent(event: Event.anonymousAuthSuccess)
            } catch {
                interactor.trackEvent(event: Event.anonymousAuthFail(error: error))
                try? await Task.sleep(for: .seconds(3))
                await checkUserStatus()
            }
        }
    }

    /// 苹果审核需要, 没有则不会通过
    func showATTPromptIfNeeded() async {
        #if !DEBUG
        let status = await AppTrackingTransparencyHelper.requestTrackingAuthorization()
        interactor.trackEvent(event: Event.attStatus(dict: status.eventParameters))
        #endif
    }
}

extension AppViewModel {
    enum Event: LoggableEvent {
        case existingAuthStart
        case existingAuthFail(error: Error)
        case anonymousAuthStart
        case anonymousAuthSuccess
        case anonymousAuthFail(error: Error)
        case attStatus(dict: [String: Any])
        var eventName: String {
            switch self {
            case .existingAuthStart: return "AppView_ExistingAuth_Start"
            case .existingAuthFail: return "AppView_ExistingAuth_Fail"
            case .anonymousAuthStart: return "AppView_AnonymousAuth_Start"
            case .anonymousAuthSuccess: return "AppView_AnonymousAuth_Success"
            case .anonymousAuthFail: return "AppView_AnonymousAuth_Fail"
            case .attStatus: return "AppView_ATTStatus"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .existingAuthFail(error: let error), .anonymousAuthFail(error: let error):
                return error.eventParameters
            case .attStatus(dict: let dict):
                return dict
            default:
                return nil
            }
        }

        var type: CustomLogType {
            switch self {
            case .existingAuthFail, .anonymousAuthFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
}
