//
//  CreateAccountView.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/3/22.
//

import AuthenticationServices
import SwiftUI

struct CreateAccountDelegate {
    var title: String = "Create Account?"
    var subtitle: String = "Don't lose your data! Connect to an SSO provider to save your account."
    var onDidSignIn: ((_ isNewUser: Bool) -> Void)?
}

struct CreateAccountView: View {
    @State var viewModel: CreateAccountViewModel
    var delegate: CreateAccountDelegate = .init()
    var body: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 10) {
                Text(delegate.title)
                    .font(.largeTitle)
                    .fontWeight(.semibold)

                Text(delegate.subtitle)
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
                viewModel.onSignInApplePressed(delegate: delegate)
            })

            Spacer()
        }
        .padding(16)
        .padding(.top, 40)
        .appearAnalyticsViewModifier(name: "CreateAccountView")
    }
}

#Preview {
    let builder = CoreBuilder(interactor: CoreInteractor(container: DevPreview.shared.container))
    return RouterView { router in
        builder.createAccountView(router: router)
    }
    .previewEnvironment()
}
