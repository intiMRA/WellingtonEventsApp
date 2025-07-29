//
//  OneOfFilter.swift
//  WellingtonEvents
//
//  Created by ialbuquerque on 16/04/2025.
//

import Foundation

struct OneOfFilter: FilterObjectProtocol {
    let id: FilterIds = .oneOf
    
    func execute(event: EventInfo, events: inout [EventInfo]) {
        if event.dates.count > 1 {
            events.removeAll(where: { $0.id == event.id })
        }
    }
    
    func execute(event: MapEventtModel, events: inout [MapEventtModel]) {
        fatalError("Not implemented")
    }
}
