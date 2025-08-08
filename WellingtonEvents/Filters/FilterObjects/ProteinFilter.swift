//
//  ProteinFilter.swift
//  WellingtonEvents
//
//  Created by Inti Albuquerque on 08/08/2025.
//

import Foundation

struct ProteinFilter: BurgerFilterObjectProtocol {
    var burgerFilterId: BurgerFilterIds = .protein
    let proteins: [String]
    
    func execute(burger: BurgerModel, burgers: inout [BurgerModel]) {
        if !proteins.contains(where: { $0 == burger.mainProtein }) {
            burgers.removeAll(where: { $0 == burger })
        }
    }
}
