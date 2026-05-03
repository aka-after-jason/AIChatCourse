//
//  Array+EXT.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/5/4.
//

import Foundation

extension Array {
    /// 通过 keypath 来排序
    /// Element 表示model
    /// T 表示某一个字段, 这个字段要遵循 Comparable 协议
    func sortedByKeyPath<T: Comparable>(keyPath: KeyPath<Element, T>, ascending: Bool = true) -> [Element] {
        sorted { item1, item2 in
            let value1 = item1[keyPath: keyPath]
            let value2 = item2[keyPath: keyPath]
            return ascending ? (value1 < value2) : (value1 > value2)
        }
    }

    /// in place
    mutating func sortByKeyPath<T: Comparable>(keyPath: KeyPath<Element, T>, ascending: Bool = true) {
        sort { item1, item2 in
            let value1 = item1[keyPath: keyPath]
            let value2 = item2[keyPath: keyPath]
            return ascending ? (value1 < value2) : (value1 > value2)
        }
    }
}
