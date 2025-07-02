//
//  CalendarManager.swift
//  WellingtonEvents
//
//  Created by ialbuquerque on 25/02/2025.
//

import Foundation
@preconcurrency import EventKit

class CalendarManager {
    
    static let eventStore : EKEventStore = EKEventStore()
    
    static func saveEventToCalendar(eventInfo: EventInfo, date: Date?, repository: EventsRepository) async throws {
        guard (try await eventStore.requestFullAccessToEvents()) == true else {
            return
        }
        
        guard let date else {
            return
        }
        
        
        let event:EKEvent = EKEvent(eventStore: eventStore)
        
        event.title = eventInfo.name
        event.startDate = date
        event.endDate = date
        event.notes = eventInfo.venue
        event.calendar = eventStore.defaultCalendarForNewEvents
        event.isAllDay = date.displayAsAllDay
        try eventStore.save(event, span: .thisEvent, commit: true)
        await repository.didSaveToCalendar(event: eventInfo)
    }
    
    static func removeFromCalendar(event: EventInfo, repository: EventsRepository) async throws {
        guard (try await eventStore.requestFullAccessToEvents()) == true,
              let endDate = event.dates.last?.addingDay(),
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
        await repository.didDeleteFromCalendar(event: event)
    }
}
