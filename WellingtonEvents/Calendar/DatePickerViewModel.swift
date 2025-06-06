//
//  DatePickerViewModel.swift
//  WellingtonEvents
//
//  Created by ialbuquerque on 17/03/2025.
//

import Foundation
import DesignLibrary

@MainActor
@Observable
class DatePickerViewModel {
    weak var repository: EventsRepository?
    var selectedDate: Date?
    let event: EventInfo
    let dismiss: (ToastStyle?) -> Void
    var dates: [Date] {
        event.dates
    }
    
    init(selectedDate: Date? = nil, event: EventInfo, repository: EventsRepository, dismiss: @escaping (ToastStyle?) -> Void) {
        self.selectedDate = selectedDate
        self.event = event
        self.dismiss = dismiss
        self.repository = repository
    }
    
    func datesByMonth() -> [DateModel] {
        var monthsDict = [String: [Date]]()
        var monthStrings: [String] = []
        dates.sorted(by: { $0 < $1 }).forEach { date in
            let monthString = date.asString(with: .mmm)
            if var month = monthsDict[monthString] {
                month.append(date)
                monthsDict[monthString] = month
            }
            else {
                monthsDict[monthString] = [date]
                monthStrings.append(monthString)
            }
        }
        
        return monthStrings.compactMap { .init(id: $0, month: $0, dates: monthsDict[$0]) }
    }

    func addToCalendar() {
        guard let repository else {
            dismiss(.error(message: "Failed to add event to calander"))
            return
        }
        Task {
            do {
                try await CalendarManager.saveEventToCalendar(eventInfo: event, date: selectedDate, repository: repository)
                dismiss(.success(message: "Event successfully added to your calendar."))
            }
            catch {
                dismiss(.error(message: error.localizedDescription))
            }
        }
    }
}
