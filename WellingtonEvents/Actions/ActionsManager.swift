//
//  ActionsManager.swift
//  WellingtonEvents
//
//  Created by Inti Albuquerque on 22/07/2025.
//

import Foundation
@MainActor
class ActionsManager: ObservableObject {
    @Published var favourites: [EventInfo] = []
    @Published  var eventsInCalendar: [EventInfo] = []
    private var repository: EventsRepository = DefaultEventsRepository()
    
    func isEventFavourited(id: String) -> Bool {
        favourites.contains(where: { id == $0.id })
    }
    
    func isEventInCalendar(id: String) -> Bool {
        eventsInCalendar.contains(where: { id == $0.id })
    }
    
    @discardableResult
    func saveToFavorites(event: EventInfo, errorHandler: (String?, String) -> Void) async -> Bool {
        do {
            try await repository.saveToFavorites(event: event)
            favourites.append(event)
            return true
        }
        catch {
            errorHandler(AlertMessages.addFavoritesFail.title, AlertMessages.addFavoritesFail.message)
            return false
        }
    }
    
    @discardableResult
    func deleteFromFavorites(event: EventInfo, errorHandler: (String?, String) -> Void) async -> Bool  {
        do {
            try await repository.deleteFromFavorites(event: event)
            favourites.removeAll(where: { event.id == $0.id })
            return true
        }
        catch {
            errorHandler(AlertMessages.deleteFavoritesFail.title, AlertMessages.deleteFavoritesFail.message)
            return false
        }
    }
    
    func addToCalendar(event: EventInfo, date: Date?, errorHandler: (String?, String) -> Void) async -> Bool {
        do {
            try await CalendarManager.saveEventToCalendar(eventInfo: event, date: date, repository: repository)
            try await refreshCalendarEvents()
            return true
        }
        catch {
            if error as NSError == CalendarManager.accessDeniedError {
                errorHandler(AlertMessages.calenderDeneid.title, AlertMessages.calenderDeneid.message)
            }
            else {
                errorHandler(AlertMessages.addCalendarFail.title, AlertMessages.addCalendarFail.message)
            }
            return false
        }
    }
    
    func deleteFromCalendar(event: EventInfo, errorHandler: (String?, String) -> Void) async -> Bool {
        do {
            try await CalendarManager.removeFromCalendar(event: event, repository: repository)
            try await refreshCalendarEvents()
            return true
        }
        catch {
            if error as NSError == CalendarManager.accessDeniedError {
                errorHandler(AlertMessages.calenderDeneid.title, AlertMessages.calenderDeneid.message)
            }
            else {
                errorHandler(AlertMessages.deleteCalendarFail.title, AlertMessages.deleteCalendarFail.message)
            }
            return false
        }
    }
    
    func refreshCalendarEvents() async throws {
        eventsInCalendar = try await repository.retrieveSavedToCalendar()
    }
    
    func setUp(events: [EventInfo]) async {
        let favourites: [EventInfo] = (try? await repository.retrieveFavorites()) ?? []
        let eventsInCalendar: [EventInfo] = (try? await repository.retrieveSavedToCalendar()) ?? []
        guard !events.isEmpty else {
            return
        }
        try? await repository.deleteFromFavorites(eventIds: favourites.compactMap { event in
            if !events.contains(where: { $0.id == event.id }) {
                return event.id
            }
            return nil
        })
        
        try? await repository.didDeleteFromCalendar(eventIds: eventsInCalendar.compactMap { event in
            if !events.contains(where: { $0.id == event.id }) {
                return event.id
            }
            return nil
        })
        self.eventsInCalendar = eventsInCalendar
        self.favourites = favourites
    }
    
    func didDeleteFromCalendar(event: EventInfo) async {
        eventsInCalendar.removeAll { $0 == event }
    }
}
