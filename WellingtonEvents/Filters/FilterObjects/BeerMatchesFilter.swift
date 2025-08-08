//
//  BeerMatchesFilter.swift
//  WellingtonEvents
//
//  Created by Inti Albuquerque on 08/08/2025.
//

import Foundation

struct BeerMatchesFilter: BurgerFilterObjectProtocol {
    var burgerFilterId: BurgerFilterIds = .beerMatches
    let beerMatches: [String]
    func execute(burger: BurgerModel, burgers: inout [BurgerModel]) {
        if !beerMatches.contains(where: { $0 == burger.beerMatch }) {
            burgers.removeAll(where: { $0 == burger })
        }
    }
}
