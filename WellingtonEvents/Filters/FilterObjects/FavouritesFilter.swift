//
//  FavouritesFilter.swift
//  WellingtonEvents
//
//  Created by ialbuquerque on 16/04/2025.
//

import Foundation

struct FavouritesFilter: FilterObjectProtocol {
    let id: FilterIds = .favorited
    let favourites: [EventInfo]
    
    func execute(event: EventInfo, events: inout [EventInfo]) {
        if !favourites.contains(where: { $0.id == event.id }) {
            events.removeAll(where: { $0.id == event.id })
        }
    }
    
    func execute(event: MapEventtModel, events: inout [MapEventtModel]) {
        guard let event =  event.events.first else {
            fatalError("pass only one event for this filter")
        }
        if !favourites.contains(where: { $0.id == event.id }) {
            events.removeAll(where: { $0.events.oneOf(elements: [event]) })
        }
    }
}
