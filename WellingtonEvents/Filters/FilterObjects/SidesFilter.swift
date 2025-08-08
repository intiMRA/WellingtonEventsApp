//
//  SidesFilter.swift
//  WellingtonEvents
//
//  Created by Inti Albuquerque on 08/08/2025.
//

import Foundation

struct SidesFilter: BurgerFilterObjectProtocol {
    let burgerFilterId: BurgerFilterIds = .sidesIncluded
    func execute(burger: BurgerModel, burgers: inout [BurgerModel]) {
        if !burger.sidesIncluded {
            burgers.removeAll { $0 == burger }
        }
    }
}
