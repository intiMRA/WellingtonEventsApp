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
    
    func execute(event: EventInfo, events: inout [EventInfo]) {
        for l in event.labels {
            print(l)
        }
        if !eventTypes.contains(where: { event.labels.contains($0) }) {
            events.removeAll { $0.id == event.id }
        }
    }
}
