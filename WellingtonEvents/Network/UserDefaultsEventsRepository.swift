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
    
    private func save(favourites: [EventInfo]) {
        do {
            Self.userDefaults.set(try JSONEncoder().encode(favourites), forKey: Keys.favouriteEvents.rawValue)
        }
        catch {
            print(error)
        }
    }
}
