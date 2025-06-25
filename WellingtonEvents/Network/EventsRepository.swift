//
//  EventsRepository.swift
//  WellingtonEvents
//
//  Created by ialbuquerque on 25/02/2025.
//

import Foundation

protocol EventsRepository: AnyObject, Actor {
    func fetchEvents() async throws -> EventsResponse?
    func saveToFavorites(event: EventInfo)
    func retrieveFavorites() -> [EventInfo]
    func deleteFromFavorites(event: EventInfo)
    func deleteFromFavorites(eventIds: [String])
    func didSaveToCalendar(event: EventInfo)
    func retrieveSavedToCalendar() -> [EventInfo]
    func didDeleteFromCalendar(event: EventInfo)
    func didDeleteFromCalendar(eventIds: [String])
    func canFetchFromCache() -> Bool
}
