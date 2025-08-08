//
//  FavouritesFilter.swift
//  WellingtonEvents
//
//  Created by ialbuquerque on 16/04/2025.
//

import Foundation

struct FavouritesFilter: FilterObjectProtocol, BurgerFilterObjectProtocol {
    var burgerFilterId: BurgerFilterIds = .favorited
    
    let id: FilterIds = .favorited
    let favourites: [any Identifiable]
    
    func execute(event: EventInfo, events: inout [EventInfo]) {
        if !favourites.contains(where: { ($0.id as? String) ?? "" == event.id }) {
            events.removeAll(where: { $0.id == event.id })
        }
    }
    
    func execute(burger: BurgerModel, burgers: inout [BurgerModel]) {
        if !favourites.contains(where: { ($0.id as? String) ?? "" == burger.id }) {
            burgers.removeAll(where: { $0.id == burger.id })
        }
    }
}
