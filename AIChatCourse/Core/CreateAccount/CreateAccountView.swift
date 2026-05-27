//
//  CreateAccountView.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/3/22.
//

import AuthenticationServices
import SwiftUI

struct CreateAccountView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    @Environment(\.dismiss) private var dismiss
    @Environment(LogManager.self) private var logManager
    @Environment(PurchaseManager.self) private var purchaseManager
    var title: String = "Create Account?"
    var subtitle: String = "Don't lose your data! Connect to an SSO provider to save your account."
    var onDidSignIn: ((_ isNewUser: Bool) -> Void)?
    var body: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 10) {
                Text(title)
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                
                Text(subtitle)
                    .font(.body)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            SignInWithAppleButtonView(
                type: .signIn,
                style: .black,
                cornerRadius: 10
            )
            .frame(height: 50)
            .anyButton(.press, action: {
                onSignInApplePressed()
            })
            
            Spacer()
        }
        .padding(16)
        .padding(.top, 40)
        .appearAnalyticsViewModifier(name: "CreateAccountView")
    }
}

#Preview {
    CreateAccountView()
}

// MARK: 事件

extension CreateAccountView {
    private func onSignInApplePressed() {
        logManager.trackEvent(event: Event.appleAuthStart)
        Task {
            do {
                let (userAuthInfo, isNewUser) = try await authManager.signInApple()
                logManager.trackEvent(event: Event.appleAuthSuccess(user: userAuthInfo, isNewUser: isNewUser))
                try await userManager.login(auth: userAuthInfo, isNewUser: isNewUser)
                try await purchaseManager.logIn(
                    userId: userAuthInfo.uid,
                    attributes: PurchaseProfileAttributes(
                        email: userAuthInfo.email,
                        firebaseAppInstanceID: FirebaseAnalyticsService.appInstanceID,
                        mixpanelDistinctID: MixpanelService.distinctId
                    )
                )
                logManager.trackEvent(event: Event.appleAuthLoginSuccess(user: userAuthInfo, isNewUser: isNewUser))
                onDidSignIn?(isNewUser)
                dismiss()
            } catch {
                logManager.trackEvent(event: Event.appleAuthFail(error: error))
            }
        }
    }
}

extension CreateAccountView {
    enum Event: LoggableEvent {
        case appleAuthStart
        case appleAuthSuccess(user: UserAuthInfoModel, isNewUser: Bool)
        case appleAuthFail(error: Error)
        case appleAuthLoginSuccess(user: UserAuthInfoModel, isNewUser: Bool)
        
        var eventName: String {
            switch self {
            case .appleAuthStart: return "CreateAccountView_AppleAuth_Start"
            case .appleAuthSuccess: return "CreateAccountView_AppleAuth_Success"
            case .appleAuthFail: return "CreateAccountView_AppleAuth_Fail"
            case .appleAuthLoginSuccess: return "CreateAccountView_AppleAuth_LoginSuccess"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .appleAuthSuccess(user: let user, isNewUser: let isNewUser), .appleAuthLoginSuccess(user: let user, isNewUser: let isNewUser):
                var dict = user.eventParams
                dict["is_new_user"] = isNewUser
                return dict
            case .appleAuthFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: CustomLogType {
            switch self {
            case .appleAuthFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
}
