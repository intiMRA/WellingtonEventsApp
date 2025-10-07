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
    
    static let calendar = Calendar.current
    
    let fetchUrl: FestivalUrlBuilder
    let festivalId: String
    var festivalEventsResponse: String {
        "\(festivalId)Response"
    }
    
    var festivalDate: String {
        "\(festivalId)Date"
    }
    
    var felstivalCalendar: String {
        "\(festivalId)Calendar"
    }
    
    var favouriteFestivalEvents: String {
        "\(festivalId)FavoriteEvents"
    }
    
    init(fetchUrl: FestivalUrlBuilder, festivalId: String) {
        self.fetchUrl = fetchUrl
        self.festivalId = festivalId
    }
    
    func fetchEvents() async throws -> EventsResponse? {
        if canFetchFromCache() {
            if let cachedResponseData = UserDefaults.standard.data(forKey: festivalEventsResponse) {
                return try JSONDecoder().decode(EventsResponse.self, from: cachedResponseData)
            }
        }
        guard let response: EventsResponse = try? await NetworkLayer.defaultNetworkLayer.request(.init(urlBuilder: fetchUrl, httpMethod: .GET)) else {
            if let cachedResponseData = UserDefaults.standard.data(forKey: festivalEventsResponse) {
                return try JSONDecoder().decode(EventsResponse.self, from: cachedResponseData)
            }
            else {
                throw DefaultEventsRepositoryError.failedToFetchResponse
            }
        }
        UserDefaults.standard.set(try JSONEncoder().encode(response), forKey: festivalEventsResponse)
        UserDefaults.standard.set(Date.now.asString(with: .ddMMYyyy), forKey: festivalDate)
        
        return response
    }
    
    func canFetchFromCache() -> Bool {
        guard
            let userDefaultsDateString = UserDefaults.standard.object(forKey: festivalDate) as? String,
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
        guard let data = UserDefaults.standard.object(forKey: felstivalCalendar) as? Data else {
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
        guard let data = UserDefaults.standard.object(forKey: favouriteFestivalEvents) as? Data else {
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
        UserDefaults.standard.set(try JSONEncoder().encode(favourites), forKey: favouriteFestivalEvents)
    }
    
    private func save(toCalendar events: [EventInfo]) throws {
        UserDefaults.standard.set(try JSONEncoder().encode(events), forKey: felstivalCalendar)
    }
}


