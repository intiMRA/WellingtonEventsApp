//
//  EventsRepository.swift
//  WellingtonEvents
//
//  Created by ialbuquerque on 25/02/2025.
//

import Foundation

protocol EventsRepository: AnyObject, Actor {
    func fetchEvents() async throws -> EventsResponse?
    func saveToFavorites(event: EventInfo) throws
    func retrieveFavorites() throws -> [EventInfo]
    func deleteFromFavorites(event: EventInfo) throws
    func deleteFromFavorites(eventIds: [String]) throws
    func didSaveToCalendar(event: EventInfo) throws
    func retrieveSavedToCalendar() throws -> [EventInfo]
    func didDeleteFromCalendar(event: EventInfo) throws
    func didDeleteFromCalendar(eventIds: [String]) throws
    func canFetchFromCache() -> Bool
}
