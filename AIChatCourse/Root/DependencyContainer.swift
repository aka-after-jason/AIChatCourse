//
//  DependencyContainer.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/6/8.
//
import SwiftUI

/// 存储所有的 manager
@MainActor
@Observable
class DependencyContainer {
    private var managers: [String: Any] = [:]

    /// 注册 manager
    func regiser<T>(_ type: T.Type, manager: T) {
        let key = "\(type)"
        managers[key] = manager
    }

    func register<T>(_ type: T.Type, manager: () -> T) {
        let key = "\(type)"
        managers[key] = manager()
    }

    /// 获取 manager
    func resolve<T>(_ type: T.Type) -> T? {
        let key = "\(type)"
        return managers[key] as? T
    }
}
