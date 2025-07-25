//
//  AlertMessages.swift
//  WellingtonEvents
//
//  Created by Inti Albuquerque on 25/07/2025.
//

import Foundation

struct AlertMessages {
    let title: String
    let message: String
    // calendar
    static let deleteCalendarFail = AlertMessages(title: String(localized: "Managing Calendar"), message: String(localized: "Sorry the event could not be deleted from your calendar."))
    static let addCalendarFail = AlertMessages(title: String(localized: "Managing Calendar"), message: String(localized: "Sorry the event could not be added to your calendar."))
    static let calenderDeneid = AlertMessages(title: String(localized: "Managing Calendar"), message: String(localized: "Sorry the event could not be added to your calendar. Please allow access to your calendar in your settings."))
    
    static let addCalendarSuccess = AlertMessages(title: String(localized: "Managing Calendar"), message: String(localized: "Event succesfully added to your calendar. Some events may be displayed as a whole day. Please check the event page for more details."))
    static let deleteCalendarSuccess = AlertMessages(title: String(localized: "Managing Calendar"), message: String(localized: "Event succesfully removed from your calendar."))
    
    // Favourites
    static let deleteFavoritesFail = AlertMessages(title: String(localized: "Managing Favourites"), message: String(localized: "Sorry the event could not be removed from favourites."))
    static let addFavoritesFail = AlertMessages(title: String(localized: "Managing Favourites"), message: String(localized: "Sorry the event could not be added to favourites."))
    
}
