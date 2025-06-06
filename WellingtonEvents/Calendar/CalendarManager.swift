//
//  CalendarManager.swift
//  WellingtonEvents
//
//  Created by ialbuquerque on 25/02/2025.
//

import Foundation
import EventKit

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
        
        try eventStore.save(event, span: .thisEvent, commit: true)
        repository.didSaveToCalendar(event: eventInfo)
    }
    
    static func removeFromCalendar(event: EventInfo, repository: EventsRepository) async throws {
        guard (try await eventStore.requestFullAccessToEvents()) == true,
              let startDate = event.dates.first,
              let endDate = event.dates.last,
              let calendar = eventStore.defaultCalendarForNewEvents
        else {
            return
        }
        
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: [calendar])
        let existingEvents = eventStore.events(matching: predicate)
        if let eventToDelete = existingEvents.first(where: { $0.title == event.name }) {
            try? eventStore.remove(eventToDelete, span: .thisEvent)
        }
        repository.didDeleteFromCalendar(event: event)
    }
}
