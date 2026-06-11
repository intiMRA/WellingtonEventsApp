//
//  EventTypesFilter.swift
//  WellingtonEvents
//
//  Created by ialbuquerque on 16/04/2025.
//

import Foundation

struct EventTypesFilter: FilterObjectProtocol {
    let id: FilterIds = .eventType
    let eventTypes: [String]
    
    func matches(_ event: EventInfo) -> Bool {
        eventTypes.contains(where: { $0 == event.eventType })
    }
}
