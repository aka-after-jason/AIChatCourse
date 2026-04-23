//
//  AlertItem.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/4/23.
//

import SwiftUI
import Foundation

struct AnyAppAlertItem {
    let title: String
    let subtitle: String?
    var buttons: () -> AnyView // 不能是 some view

    /// 初始化方式1
    init(
        title: String,
        subtitle: String? = nil,
        buttons: (() -> AnyView)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.buttons = buttons ?? {
            AnyView(Button("Ok") {}) // 不传buttons, 默认给一个Button
        }
    }

    /// 初始化方式2
    init(error: Error) {
        self.init(title: "Error", subtitle: error.localizedDescription, buttons: nil)
    }
}

enum AlertType {
    case alert, confirmationDialog
}

extension View {
    @ViewBuilder
    func showCustomAlert(type: AlertType = .alert, alertItem: Binding<AnyAppAlertItem?>) -> some View {
        switch type {
        case .alert:
            alert(alertItem.wrappedValue?.title ?? "", isPresented: Binding(ifNotNil: alertItem)) {
                alertItem.wrappedValue?.buttons()
            } message: {
                if let subtitle = alertItem.wrappedValue?.subtitle {
                    Text(subtitle)
                }
            }
        case .confirmationDialog:
            confirmationDialog("", isPresented: Binding(ifNotNil: alertItem)) {
                alertItem.wrappedValue?.buttons()
            } message: {
                if let subtitle = alertItem.wrappedValue?.subtitle {
                    Text(subtitle)
                }
            }
        }
    }
}
