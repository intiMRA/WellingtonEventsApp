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
        if !eventTypes.contains(where: { $0 == event.eventType }) {
            events.removeAll { $0.id == event.id }
        }
    }
    
    func execute(event: MapEventtModel, events: inout [MapEventtModel]) {
        if !eventTypes.contains(where: { $0 == event.events.first?.eventType }) {
            events.removeAll { $0.events.oneOf(elements: event.events) }
        }
    }
}
