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
    
    static func saveEventToCalendar(eventInfo: EventInfo, date: Date?) async {
        guard (try? await eventStore.requestFullAccessToEvents()) == true else {
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
        do {
            try eventStore.save(event, span: .thisEvent, commit: true)
        } catch let error as NSError {
            print("failed to save event with error : \(error)")
        }
    }
}
