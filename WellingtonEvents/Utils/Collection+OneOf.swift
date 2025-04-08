//
//  Collection+OneOf.swift
//  WellingtonEvents
//
//  Created by ialbuquerque on 17/03/2025.
//

import Foundation

extension Collection where Element: Equatable {
    func oneOf(elements: [Self.Element]) -> Bool {
        for e in self {
            if elements.contains(where: { $0 == e }) {
                return true
            }
        }
        return false
    }
}
