//
//  DefaultEventsRepository.swift
//  WellingtonEvents
//
//  Created by ialbuquerque on 25/02/2025.
//

import Foundation
import NetworkLayerSPM

enum UrlBuilder: String, NetworkLayerURLBuilder {
    case events = "https://raw.githubusercontent.com/intiMRA/Wellington-Events-Scrapper/refs/heads/main/events.json"
    case festivals = "https://raw.githubusercontent.com/intiMRA/Wellington-Events-Scrapper/refs/heads/main/currentFestivals.json"
    case festivalDetails = "https://raw.githubusercontent.com/intiMRA/Wellington-Events-Scrapper/refs/heads/main/currentFestivalDetails.json"
    case burgers = "https://raw.githubusercontent.com/intiMRA/Wellington-Events-Scrapper/refs/heads/main/burgers.json"
    func url() -> URL? {
        .init(string: rawValue)
    }
}

actor DefaultEventsRepository: EventsRepository {
    
    enum DefaultEventsRepositoryError: Error {
        case failedToFetchResponse
    }
    
    static let calendar = Calendar.current
    
    enum Keys: String {
        case favouriteEvents
        case calendar
        case date
        case eventsResponse
    }
    
    func fetchEvents() async throws -> EventsResponse? {
        if canFetchFromCache() {
            if let cachedResponseData = UserDefaults.standard.data(forKey: Keys.eventsResponse.rawValue) {
                return try JSONDecoder().decode(EventsResponse.self, from: cachedResponseData)
            }
        }
        guard let response: EventsResponse = try? await NetworkLayer.defaultNetworkLayer.request(.init(urlBuilder: UrlBuilder.events, httpMethod: .GET)) else {
            if let cachedResponseData = UserDefaults.standard.data(forKey: Keys.eventsResponse.rawValue) {
                return try JSONDecoder().decode(EventsResponse.self, from: cachedResponseData)
            }
            else {
                throw DefaultEventsRepositoryError.failedToFetchResponse
            }
        }
        UserDefaults.standard.set(try JSONEncoder().encode(response), forKey: Keys.eventsResponse.rawValue)
        UserDefaults.standard.set(Date.now.asString(with: .ddMMYyyy), forKey: Keys.date.rawValue)
        
        return response
    }
    
    func canFetchFromCache() -> Bool {
        guard
            let userDefaultsDateString = UserDefaults.standard.object(forKey: Keys.date.rawValue) as? String,
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
        guard let data = UserDefaults.standard.object(forKey: Keys.calendar.rawValue) as? Data else {
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
        var favourites = retrieveFavorites()
        favourites.append(event)
        try save(favourites: favourites)
    }
    
    func retrieveFavorites() -> [EventInfo] {
        guard let data = UserDefaults.standard.object(forKey: Keys.favouriteEvents.rawValue) as? Data else {
            return []
        }
        let events = (try? JSONDecoder().decode([EventInfo].self, from: data)) ?? []
        return events
    }
    
    func deleteFromFavorites(event: EventInfo) throws {
        var favourites = retrieveFavorites()
        favourites.removeAll(where: { $0.id == event.id })
        try save(favourites: favourites)
    }
    
    func deleteFromFavorites(eventIds: [String]) throws {
        var favourites = retrieveFavorites()
        favourites.removeAll(where: { event in eventIds.contains(where: { event.id == $0 }) })
        try save(favourites: favourites)
    }
    
    func didDeleteFromCalendar(eventIds: [String]) throws {
        var calendar = try retrieveSavedToCalendar()
        calendar.removeAll(where: { event in eventIds.contains(where: { event.id == $0 }) })
        try save(toCalendar: calendar)
    }
    
    private func save(favourites: [EventInfo]) throws {
        UserDefaults.standard.set(try JSONEncoder().encode(favourites), forKey: Keys.favouriteEvents.rawValue)
    }
    
    private func save(toCalendar events: [EventInfo]) throws {
        UserDefaults.standard.set(try JSONEncoder().encode(events), forKey: Keys.calendar.rawValue)
    }
}
