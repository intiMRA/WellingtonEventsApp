//
//  SourcesFilter.swift
//  WellingtonEvents
//
//  Created by ialbuquerque on 16/04/2025.
//

import Foundation

struct SourcesFilter: FilterObjectProtocol {
    let id: FilterIds = .source
    let sources: [String]
    
    func execute(event: EventInfo, events: inout [EventInfo]) {
        if !sources.contains(where: { $0 == event.source }) {
            events.removeAll { $0.id == event.id }
        }
    }
}
