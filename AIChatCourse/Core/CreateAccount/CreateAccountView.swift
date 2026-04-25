//
//  CreateAccountView.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/3/22.
//

import SwiftUI
import AuthenticationServices

struct CreateAccountView: View {
    @Environment(\.authService) private var authService
    @Environment(\.dismiss) private var dismiss
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
    }
}

#Preview {
    CreateAccountView()
}

// MARK: 事件
extension CreateAccountView {
    private func onSignInApplePressed() {
        Task {
            do {
                let (userAuthInfo, isNewUser) = try await authService.signInApple()
                onDidSignIn?(isNewUser)
                print("Did sign in with apple success")
                dismiss()
            } catch {
                print("Failed to sign in with apple: \(error.localizedDescription)")
            }
        }
    }
}
