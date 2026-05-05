//
//  Dictionary+EXT.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/5/4.
//

import Foundation

extension Dictionary where Key == String, Value == Any {
    var asAlphabeticalArray: [(key: String, value: Any)] {
        self.map { (key: $0, value: $1) }.sortedByKeyPath(keyPath: \.key)
    }
}

extension Dictionary where Key == String {
    mutating func first(upTo maxItems: Int) {
        var count = 0
        for (key, _) in self {
            if count >= maxItems {
                removeValue(forKey: key)
            } else {
                count += 1
            }
        }
    }
}
