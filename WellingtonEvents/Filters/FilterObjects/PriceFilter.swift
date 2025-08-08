//
//  PriceFilter.swift
//  WellingtonEvents
//
//  Created by Inti Albuquerque on 08/08/2025.
//

import Foundation

struct PriceFilter: BurgerFilterObjectProtocol {
    var burgerFilterId: BurgerFilterIds = .price
    let maxPrice: Double
    
    func execute(burger: BurgerModel, burgers: inout [BurgerModel]) {
        if burger.price > maxPrice {
            burgers.removeAll(where: { $0 == burger })
        }
    }
}

