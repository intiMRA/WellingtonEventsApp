//
//  EventsRepository.swift
//  WellingtonEvents
//
//  Created by ialbuquerque on 25/02/2025.
//

import Foundation

protocol EventsRepository {
    func saveToFavorites(event: EventInfo)
    func retrieveFavorites() -> [EventInfo]
    func deleteFromFavorites(event: EventInfo)
    func deleteFromFavorites(events: [EventInfo])
}
