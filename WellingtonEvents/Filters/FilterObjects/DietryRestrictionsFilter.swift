//
//  DietryRestrictionsFilter.swift
//  WellingtonEvents
//
//  Created by Inti Albuquerque on 08/08/2025.
//

import Foundation

struct DietryRestrictionsFilter: BurgerFilterObjectProtocol {
    var burgerFilterId: BurgerFilterIds = .dietryRestrictions
    let dietryRestrictions: [String]
    
    func execute(burger: BurgerModel, burgers: inout [BurgerModel]) {
        if !dietryRestrictions.oneOf(elements: burger.dietaryRequirements.map { $0.rawValue }) {
            burgers.removeAll(where: { $0 == burger })
        }
    }
}
