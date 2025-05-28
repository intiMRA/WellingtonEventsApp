//
//  MultipleDatesFilter.swift
//  WellingtonEvents
//
//  Created by ialbuquerque on 16/04/2025.
//

import Foundation

struct MultipleDatesFilter: FilterObjectProtocol {
    let id: FilterIds = .multipleDates
    
    func execute(event: EventInfo, events: inout [EventInfo]) {
        if event.dates.count <= 1 {
            events.removeAll(where: { $0.id == event.id })
        }
    }
}
