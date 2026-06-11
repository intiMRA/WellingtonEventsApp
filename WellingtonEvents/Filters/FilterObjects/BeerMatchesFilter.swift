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
    func matches(_ burger: BurgerModel) -> Bool {
        beerMatches.contains(where: { $0 == burger.beerMatch })
    }
}
