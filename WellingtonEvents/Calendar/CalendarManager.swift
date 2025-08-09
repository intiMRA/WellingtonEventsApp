//
//  CalendarManager.swift
//  WellingtonEvents
//
//  Created by ialbuquerque on 25/02/2025.
//

import Foundation
@preconcurrency import EventKit

class CalendarManager {
    static let accessDeniedError : NSError = NSError(domain: "CalendarAccessDenied", code: 1, userInfo: nil)
    static let eventStore : EKEventStore = EKEventStore()
    
    static func saveEventToCalendar(eventInfo: EventInfo, date: Date?, repository: EventsRepository) async throws {
        guard (try await eventStore.requestFullAccessToEvents()) == true else {
            throw Self.accessDeniedError
        }
        
        guard let date else {
            return
        }
        
        
        let event:EKEvent = EKEvent(eventStore: eventStore)
        
        event.title = eventInfo.name
        event.notes = eventInfo.description
        event.startDate = date
        event.endDate = date.addingHours()
        event.location = eventInfo.venue
        event.calendar = eventStore.defaultCalendarForNewEvents
        event.isAllDay = date.displayAsAllDay
        event.url = URL(string: eventInfo.url)
        try eventStore.save(event, span: .thisEvent, commit: true)
        try await repository.didSaveToCalendar(event: eventInfo)
    }
    
    static func removeFromCalendar(event: EventInfo, repository: EventsRepository) async throws {
        guard (try await eventStore.requestFullAccessToEvents()) == true else {
            throw Self.accessDeniedError
        }
        
        guard let endDate = event.dates.last?.addingDay(),
              let calendar = eventStore.defaultCalendarForNewEvents
        else {
            return
        }
        let startDate = Date.now
        
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: [calendar])
        let existingEvents = eventStore.events(matching: predicate)
        let eventsToDelete = existingEvents.filter { $0.title == event.name }
        if !eventsToDelete.isEmpty {
            for event in eventsToDelete {
                try eventStore.remove(event, span: .futureEvents)
            }
        }
        try await repository.didDeleteFromCalendar(event: event)
    }
    
    static func retrieveEvent(event: EventInfo) async throws -> EKEvent? {
        guard (try await eventStore.requestFullAccessToEvents()) == true else {
            throw Self.accessDeniedError
        }
        
        guard let endDate = event.dates.last?.addingDay(),
              let calendar = eventStore.defaultCalendarForNewEvents
        else {
            return nil
        }
        let startDate = Date.now
        
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: [calendar])
        let existingEvents = eventStore.events(matching: predicate)
        let events = existingEvents.filter { $0.title == event.name }
        
        return events.first ?? existingEvents.filter { $0.notes == event.description }.first
    }
    
    static func retrieveBurger(burger: BurgerModel) async throws -> EKEvent? {
        guard (try await eventStore.requestFullAccessToEvents()) == true else {
            throw Self.accessDeniedError
        }
        
        guard let endDate = Date.now.addingMonths(months: 2),
              let calendar = eventStore.defaultCalendarForNewEvents
        else {
            return nil
        }
        let startDate = Date.now
        
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: [calendar])
        let existingEvents = eventStore.events(matching: predicate)
        let events = existingEvents.filter { $0.title == burger.name }
        
        return events.first ?? existingEvents.filter { $0.notes == burger.description }.first
    }
}

extension EKEvent: @unchecked @retroactive Sendable { }
