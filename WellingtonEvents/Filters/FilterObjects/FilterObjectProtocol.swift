//
//  FilterObjectProtocol.swift
//  WellingtonEvents
//
//  Created by ialbuquerque on 16/04/2025.
//

import Foundation

protocol FilterObjectProtocol {
    var id: FilterIds { get }

    func matches(_ event: EventInfo) -> Bool
}

protocol BurgerFilterObjectProtocol {
    var burgerFilterId: BurgerFilterIds { get }

    func matches(_ burger: BurgerModel) -> Bool
}
