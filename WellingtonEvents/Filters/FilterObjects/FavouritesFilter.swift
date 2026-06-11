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
    
    private func matchesFilterable(_ item: some Filterable) -> Bool {
        favourites.contains(where: { ($0.id as? String) ?? "" == item.id })
    }

    func matches(_ event: EventInfo) -> Bool { matchesFilterable(event) }
    func matches(_ burger: BurgerModel) -> Bool { matchesFilterable(burger) }
}
