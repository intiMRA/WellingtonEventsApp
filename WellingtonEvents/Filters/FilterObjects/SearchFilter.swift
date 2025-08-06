//
//  SearchFilter.swift
//  WellingtonEvents
//
//  Created by ialbuquerque on 31/05/2025.
//

struct SearchFilter: FilterObjectProtocol {
    
    let id: FilterIds = .search
    let searchString: String
    
    func execute(event: EventInfo, events: inout [EventInfo]) { }
    
    func execute(events: inout [EventInfo]) {
        let allEvents = events
        events.removeAll(where: { !$0.name.lowercased().starts(with: searchString.lowercased()) })
        events.append(contentsOf: allEvents.filter({
            event in event.name.lowercased().contains(searchString.lowercased()) && !events.contains(where: {
                $0.id == event.id
            })
        }))
        
        events.append(contentsOf: allEvents.filter({
            event in event.venue.lowercased().contains(searchString.lowercased()) && !events.contains(where: {
                $0.id == event.id
            })
        }))
    }
}
