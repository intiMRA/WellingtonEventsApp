//
//  EventTypesFilter.swift
//  WellingtonEvents
//
//  Created by ialbuquerque on 16/04/2025.
//

import Foundation

struct EventTypesFilter: FilterObjectProtocol {
    let id: FilterIds = .eventType
    let labels: [String]
    
    func matches(_ event: EventInfo) -> Bool {
        labels.oneOf(elements: event.labels)
    }
}
