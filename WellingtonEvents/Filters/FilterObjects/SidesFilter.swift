//
//  SidesFilter.swift
//  WellingtonEvents
//
//  Created by Inti Albuquerque on 08/08/2025.
//

import Foundation

struct SidesFilter: BurgerFilterObjectProtocol {
    let burgerFilterId: BurgerFilterIds = .sidesIncluded
    func matches(_ burger: BurgerModel) -> Bool {
        burger.sidesIncluded
    }
}
