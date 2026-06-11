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
    
    func matches(_ burger: BurgerModel) -> Bool {
        burger.price <= maxPrice
    }
}

