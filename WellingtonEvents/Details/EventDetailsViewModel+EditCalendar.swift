//
//  EventDetailsViewModel+EditCalendar.swift
//  WellingtonEvents
//
//  Created by Inti Albuquerque on 29/07/2025.
//

import Foundation
import DesignLibrary
extension EventDetailsViewModel {
    func presentEditCalendar() async {
        do {
            guard let ekEvent = try await CalendarManager.retrieveEvent(event: event) else {
                return
            }
            route = .editEvent(eventInfo: event, ekEvent: ekEvent)
        }
        catch {
            route = .alert(.error(title: AlertMessages.editCalendarFailed.title, message: AlertMessages.editCalendarFailed.message))
        }
    }
}
