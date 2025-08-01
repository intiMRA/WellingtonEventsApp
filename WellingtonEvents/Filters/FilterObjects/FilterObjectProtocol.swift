//
//  FilterObjectProtocol.swift
//  WellingtonEvents
//
//  Created by ialbuquerque on 16/04/2025.
//

import Foundation

protocol FilterObjectProtocol {
    var id: FilterIds { get }
    
    func execute(event: EventInfo, events: inout [EventInfo])
    func execute(event: MapEventtModel, events: inout [MapEventtModel])
}
