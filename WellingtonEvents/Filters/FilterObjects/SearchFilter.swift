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
    func execute(event: MapEventtModel, events: inout [MapEventtModel]) { }
    
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
    
    func execute(events: inout [MapEventtModel]) {
        let allEvents = events
        events.removeAll(where: { event in
            !event.events.map { $0.name.lowercased().starts(with: searchString.lowercased()) }.contains(where: { $0 })
        })
        events.append(contentsOf: allEvents.filter({ event in
            event.events.map {
                $0.name.lowercased().contains(searchString.lowercased()) && !events.contains(where: {
                    $0.events.oneOf(elements: event.events)
                })
            }
            .contains(where: { $0 })
        }))
        events.append(contentsOf: allEvents.filter({ event in
            event.events.map {
                $0.venue.lowercased().contains(searchString.lowercased()) && !events.contains(where: {
                    $0.events.oneOf(elements: event.events)
                })
            }
            .contains(where: { $0 })
        }))
    }
}
