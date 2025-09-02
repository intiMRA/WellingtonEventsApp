//
//  FestivalEventsRepository.swift
//  WellingtonEvents
//
//  Created by Inti Albuquerque on 01/09/2025.
//

import Foundation
import NetworkLayerSPM

enum FestivalUrlBuilder: NetworkLayerURLBuilder {
    case cutom(String)
    func url() -> URL? {
        switch self {
        case .cutom(let url):
            return .init(string: url)
        }
    }
}

actor FestivalEventsRepository: EventsRepository {
    
    enum DefaultEventsRepositoryError: Error {
        case failedToFetchResponse
    }
    
    static let userDefaults = UserDefaults.standard
    static let calendar = Calendar.current
    
    enum Keys: String {
        case favouriteFestivalEvents
        case felstivalCalendar
        case festivalDate
        case festivalEventsResponse
    }
    
    let fetchUrl: FestivalUrlBuilder
    
    init(fetchUrl: FestivalUrlBuilder) {
        self.fetchUrl = fetchUrl
    }
    
    func fetchEvents() async throws -> EventsResponse? {
        if canFetchFromCache() {
            if let cachedResponseData = Self.userDefaults.data(forKey: Keys.festivalEventsResponse.rawValue) {
                return try JSONDecoder().decode(EventsResponse.self, from: cachedResponseData)
            }
        }
        guard let response: EventsResponse = try? await NetworkLayer.defaultNetworkLayer.request(.init(urlBuilder: fetchUrl, httpMethod: .GET)) else {
            if let cachedResponseData = Self.userDefaults.data(forKey: Keys.festivalEventsResponse.rawValue) {
                return try JSONDecoder().decode(EventsResponse.self, from: cachedResponseData)
            }
            else {
                throw DefaultEventsRepositoryError.failedToFetchResponse
            }
        }
        Self.userDefaults.set(try JSONEncoder().encode(response), forKey: Keys.festivalEventsResponse.rawValue)
        Self.userDefaults.set(Date.now.asString(with: .ddMMYyyy), forKey: Keys.festivalDate.rawValue)
        
        return response
    }
    
    func canFetchFromCache() -> Bool {
        guard
            let userDefaultsDateString = Self.userDefaults.object(forKey: Keys.festivalDate.rawValue) as? String,
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
        guard let data = Self.userDefaults.object(forKey: Keys.felstivalCalendar.rawValue) as? Data else {
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
        guard let data = Self.userDefaults.object(forKey: Keys.favouriteFestivalEvents.rawValue) as? Data else {
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
        Self.userDefaults.set(try JSONEncoder().encode(favourites), forKey: Keys.favouriteFestivalEvents.rawValue)
    }
    
    private func save(toCalendar events: [EventInfo]) throws {
        Self.userDefaults.set(try JSONEncoder().encode(events), forKey: Keys.felstivalCalendar.rawValue)
    }
}


