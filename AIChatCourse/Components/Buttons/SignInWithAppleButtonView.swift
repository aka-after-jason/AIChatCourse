//
//  SignInWithAppleButtonView.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/3/22.
//

import AuthenticationServices
import SwiftUI

public struct SignInWithAppleButtonView: View {
    public let type: ASAuthorizationAppleIDButton.ButtonType
    public let style: ASAuthorizationAppleIDButton.Style
    public let cornerRadius: CGFloat
    
    public init(
        type: ASAuthorizationAppleIDButton.ButtonType = .signIn,
        style: ASAuthorizationAppleIDButton.Style = .black,
        cornerRadius: CGFloat = 10
    ) {
        self.type = type
        self.style = style
        self.cornerRadius = cornerRadius
    }
    
    public var body: some View {
        ZStack {
            // background layer
            Color.black.opacity(0.001)
            
            SignInWithAppleButtonViewRepresentable(type: type, style: style, cornerRadius: cornerRadius)
                .disabled(true)
        }
    }
}

/// 在SwiftUI 中使用 UIKit的方法  实现UIViewRepresentable协议
public struct SignInWithAppleButtonViewRepresentable: UIViewRepresentable {
    let type: ASAuthorizationAppleIDButton.ButtonType
    let style: ASAuthorizationAppleIDButton.Style
    let cornerRadius: CGFloat
    
    public func makeUIView(context: Context) -> some UIView {
        let button = ASAuthorizationAppleIDButton(type: type, style: style)
        button.cornerRadius = cornerRadius
        return button
    }
    
    public func updateUIView(_ uiView: UIViewType, context: Context) {}
    
    public func makeCoordinator() {}
}

#Preview("SignInWithAppleButtonView") {
    ZStack {
        SignInWithAppleButtonView(
            type: .signUp,
            style: .black,
            cornerRadius: 10
        )
        .frame(height: 50)
    }
    .padding(40)
}
