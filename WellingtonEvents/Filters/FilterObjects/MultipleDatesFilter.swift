//
//  MultipleDatesFilter.swift
//  WellingtonEvents
//
//  Created by ialbuquerque on 16/04/2025.
//

import Foundation

struct MultipleDatesFilter: FilterObjectProtocol {
    
    let id: FilterIds = .multipleDates
    
    func matches(_ event: EventInfo) -> Bool {
        event.dates.count > 1
    }
}
