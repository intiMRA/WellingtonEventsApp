//
//  DefaultEventsRepository.swift
//  WellingtonEvents
//
//  Created by ialbuquerque on 25/02/2025.
//

import Foundation
import NetworkLayerSPM

private struct urlBuilder: NetworkLayerURLBuilder {
    func url() -> URL? {
        .init(string: "https://raw.githubusercontent.com/intiMRA/Wellington-Events-Scrapper/refs/heads/main/events.json")
    }
}

actor DefaultEventsRepository: EventsRepository {
    
    enum DefaultEventsRepositoryError: Error {
        case failedToFetchResponse
    }
    
    static let userDefaults = UserDefaults.standard
    static let calendar = Calendar.current
    
    enum Keys: String {
        case favouriteEvents
        case calendar
        case date
        case eventsResponse
    }
    
    func fetchEvents() async throws -> EventsResponse? {
        if canFetchFromCache() {
            if let cachedResponseData = Self.userDefaults.data(forKey: Keys.eventsResponse.rawValue) {
                return try JSONDecoder().decode(EventsResponse.self, from: cachedResponseData)
            }
        }
        guard let response: EventsResponse? = try await NetworkLayer.defaultNetworkLayer.request(.init(urlBuilder: urlBuilder(), httpMethod: .GET)) else {
            throw DefaultEventsRepositoryError.failedToFetchResponse
        }
        
        Self.userDefaults.set(try JSONEncoder().encode(response), forKey: Keys.eventsResponse.rawValue)
        Self.userDefaults.set(Date.now.asString(with: .ddMMYyyy), forKey: Keys.date.rawValue)
        
        return response
    }
    
    func canFetchFromCache() -> Bool {
        guard
            let userDefaultsDateString = Self.userDefaults.object(forKey: Keys.date.rawValue) as? String,
            let userDefaultsDate = userDefaultsDateString.asDate(with: .ddMMYyyy)
        else {
            return false
        }
        return Self.calendar.isDate(.now, inSameDayAs: userDefaultsDate)
    }
    
    func didSaveToCalendar(event: EventInfo) throws {
        var calendar = try retrieveSavedToCalendar()
        calendar.append(event)
        try save(toCalendar: calendar)
    }
    
    func retrieveSavedToCalendar() throws -> [EventInfo] {
        guard let data = Self.userDefaults.object(forKey: Keys.calendar.rawValue) as? Data else {
            return []
        }
        let events = try JSONDecoder().decode([EventInfo].self, from: data)
        return events
    }
    
    func didDeleteFromCalendar(event: EventInfo) throws {
        var calendar = try retrieveSavedToCalendar()
        calendar.removeAll(where: { $0.id == event.id })
        try save(toCalendar: calendar)
    }
    
    func saveToFavorites(event: EventInfo) throws {
        var favourites = try retrieveFavorites()
        favourites.append(event)
        try save(favourites: favourites)
    }
    
    func retrieveFavorites() throws -> [EventInfo] {
        guard let data = Self.userDefaults.object(forKey: Keys.favouriteEvents.rawValue) as? Data else {
            return []
        }
        let events = try JSONDecoder().decode([EventInfo].self, from: data)
        return events
    }
    
    func deleteFromFavorites(event: EventInfo) throws {
        var favourites = try retrieveFavorites()
        favourites.removeAll(where: { $0.id == event.id })
        try save(favourites: favourites)
    }
    
    func deleteFromFavorites(eventIds: [String]) throws {
        var favourites = try retrieveFavorites()
        favourites.removeAll(where: { event in eventIds.contains(where: { event.id == $0 }) })
        try save(favourites: favourites)
    }
    
    func didDeleteFromCalendar(eventIds: [String]) throws {
        var calendar = try retrieveSavedToCalendar()
        calendar.removeAll(where: { event in eventIds.contains(where: { event.id == $0 }) })
        try save(toCalendar: calendar)
    }
    
    private func save(favourites: [EventInfo]) throws {
        Self.userDefaults.set(try JSONEncoder().encode(favourites), forKey: Keys.favouriteEvents.rawValue)
    }
    
    private func save(toCalendar events: [EventInfo]) throws {
        Self.userDefaults.set(try JSONEncoder().encode(events), forKey: Keys.calendar.rawValue)
    }
}
