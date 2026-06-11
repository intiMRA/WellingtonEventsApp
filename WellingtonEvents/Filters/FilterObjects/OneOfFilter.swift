//
//  OneOfFilter.swift
//  WellingtonEvents
//
//  Created by ialbuquerque on 16/04/2025.
//

import Foundation

struct OneOfFilter: FilterObjectProtocol {
    let id: FilterIds = .oneOf
    
    func matches(_ event: EventInfo) -> Bool {
        event.dates.count <= 1
    }
}
