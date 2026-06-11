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
    
    func matches(_ burger: BurgerModel) -> Bool {
        dietryRestrictions.oneOf(elements: burger.dietaryRequirements.map { $0.rawValue })
    }
}
