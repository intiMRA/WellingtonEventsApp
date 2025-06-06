//
//  UserDefaultsEventsRepository.swift
//  WellingtonEvents
//
//  Created by ialbuquerque on 25/02/2025.
//

import Foundation
class UserDefaultsEventsRepository: EventsRepository {

    static let userDefaults = UserDefaults.standard
    enum Keys: String {
        case favouriteEvents
        case calendar
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
