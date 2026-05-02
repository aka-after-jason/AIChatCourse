//
//  Collection+EXT.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/5/2.
//

extension Collection {
    func first(upTo value: Int) -> [Element]? {
        guard !isEmpty else {return nil}
        let maxItems = Swift.min(count, value)
        return Array(prefix(maxItems))
    }
    func last(upTo value: Int) -> [Element]? {
        guard !isEmpty else {return nil}
        let maxItems = Swift.min(count, value)
        return Array(suffix(maxItems))
    }
}
