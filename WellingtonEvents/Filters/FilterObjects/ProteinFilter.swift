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
    
    func matches(_ burger: BurgerModel) -> Bool {
        proteins.contains(where: { burger.mainProtein.contains($0) })
    }
}
