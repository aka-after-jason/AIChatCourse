//
//  GlobalRouter.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/6/11.
//
import SwiftUI

@MainActor
protocol GlobalRouter {
    var router: Router { get }
}

// MARK: 公共的方法
// 为 GlobalRouter 协议提供默认实现
// 凡是遵循 GlobalRouter 协议的结构体或者类都可以直接使用
extension GlobalRouter {
    func showAlert(type: CustomRouting.AlertType, title: String, subtitle: String?, buttons: (() -> AnyView)?) {
        router.showAlert(type: type, title: title, subtitle: subtitle, buttons: buttons)
    }

    func showAlert(title: String, subtitle: String?) {
        router.showAlert(type: .alert, title: title, subtitle: subtitle, buttons: nil)
    }

    func showAlert(error: Error) {
        router.showAlert(type: .alert, title: "Error", subtitle: error.localizedDescription, buttons: nil)
    }

    func dismissScreen() {
        router.dismissScreen()
    }

    func dismissAlert() {
        router.dismissAlert()
    }

    func dismissModal() {
        router.dismissModal()
    }
}
