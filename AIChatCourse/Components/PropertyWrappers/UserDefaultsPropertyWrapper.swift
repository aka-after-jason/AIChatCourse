//
//  UserDefaultsPropertyWrapper.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/5/20.
//

import SwiftUI

protocol UserDefaultsCompatible {}
extension Bool: UserDefaultsCompatible {}
extension Float: UserDefaultsCompatible {}
extension Double: UserDefaultsCompatible {}
extension String: UserDefaultsCompatible {}
extension Int: UserDefaultsCompatible {}
extension URL: UserDefaultsCompatible {}

/// 带泛型的 @propertyWrapper
@propertyWrapper
struct UserDefault<T: UserDefaultsCompatible> {
    private let key: String
    private let startingValue: T

    init(key: String, startingValue: T) {
        self.key = key
        self.startingValue = startingValue
    }

    /// 必须实现 wrappedValue 属性
    var wrappedValue: T {
        get {
            if let savedValue = UserDefaults.standard.value(forKey: key) as? T {
                return savedValue
            } else {
                UserDefaults.standard.set(startingValue, forKey: key)
                return startingValue
            }
        }

        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}

/// 适用 枚举类型的 @propertyWrapper
@propertyWrapper
struct UserDefaultEnum<T: RawRepresentable> where T.RawValue == String {
    private let key: String
    private let startingValue: T

    init(key: String, startingValue: T) {
        self.key = key
        self.startingValue = startingValue
    }

    var wrappedValue: T {
        get {
            if let savedString = UserDefaults.standard.string(forKey: key), let savedValue = T(rawValue: savedString) {
                return savedValue
            } else {
                UserDefaults.standard.set(startingValue.rawValue, forKey: key)
                return startingValue
            }
        }

        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: key)
        }
    }
}
