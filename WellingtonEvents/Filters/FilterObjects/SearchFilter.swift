//
//  SearchFilter.swift
//  WellingtonEvents
//
//  Created by ialbuquerque on 31/05/2025.
//

struct SearchFilter: FilterObjectProtocol, BurgerFilterObjectProtocol {
    let burgerFilterId: BurgerFilterIds = .search
    let id: FilterIds = .search
    let searchString: String
    
    func execute(event: EventInfo, events: inout [EventInfo]) { }
    func execute(burger: BurgerModel, burgers: inout [BurgerModel]) { }
    
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
    
    func execute(burgers: inout [BurgerModel]) {
        let allBurgers = burgers
        burgers.removeAll(where: { !$0.name.lowercased().starts(with: searchString.lowercased()) })
        burgers.append(contentsOf: allBurgers.filter({
            burger in burger.name.lowercased().contains(searchString.lowercased()) && !burgers.contains(where: {
                $0.id == burger.id
            })
        }))
        
        burgers.append(contentsOf: allBurgers.filter({
            burger in burger.venue.lowercased().contains(searchString.lowercased()) && !burgers.contains(where: {
                $0.id == burger.id
            })
        }))
    }
}
