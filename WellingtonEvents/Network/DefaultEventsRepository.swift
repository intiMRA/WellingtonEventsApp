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
    
    func didSaveToCalendar(event: EventInfo) {
        var calendar = retrieveSavedToCalendar()
        calendar.append(event)
        save(toCalendar: calendar)
    }
    
    func retrieveSavedToCalendar() -> [EventInfo] {
        guard let data = Self.userDefaults.object(forKey: Keys.calendar.rawValue) as? Data else {
            return []
        }
        do {
            let events = try JSONDecoder().decode([EventInfo].self, from: data)
            return events
        }
        catch {
            print(error)
            return []
        }
    }
    
    func didDeleteFromCalendar(event: EventInfo) {
        var calendar = retrieveSavedToCalendar()
        calendar.removeAll(where: { $0.id == event.id })
        save(toCalendar: calendar)
    }
    
    func saveToFavorites(event: EventInfo) {
        var favourites = retrieveFavorites()
        favourites.append(event)
        save(favourites: favourites)
    }
    
    func retrieveFavorites() -> [EventInfo] {
        guard let data = Self.userDefaults.object(forKey: Keys.favouriteEvents.rawValue) as? Data else {
            return []
        }
        do {
            let events = try JSONDecoder().decode([EventInfo].self, from: data)
            return events
        }
        catch {
            print(error)
            return []
        }
    }
    
    func deleteFromFavorites(event: EventInfo) {
        var favourites = retrieveFavorites()
        favourites.removeAll(where: { $0.id == event.id })
        save(favourites: favourites)
    }
    
    func deleteFromFavorites(eventIds: [String]) {
        var favourites = retrieveFavorites()
        favourites.removeAll(where: { event in eventIds.contains(where: { event.id == $0 }) })
        save(favourites: favourites)
    }
    
    func didDeleteFromCalendar(eventIds: [String]) {
        var calendar = retrieveSavedToCalendar()
        calendar.removeAll(where: { event in eventIds.contains(where: { event.id == $0 }) })
        save(toCalendar: calendar)
    }
    
    private func save(favourites: [EventInfo]) {
        do {
            Self.userDefaults.set(try JSONEncoder().encode(favourites), forKey: Keys.favouriteEvents.rawValue)
        }
        catch {
            print(error)
        }
    }
    
    private func save(toCalendar events: [EventInfo]) {
        do {
            Self.userDefaults.set(try JSONEncoder().encode(events), forKey: Keys.calendar.rawValue)
        }
        catch {
            print(error)
        }
    }
}
