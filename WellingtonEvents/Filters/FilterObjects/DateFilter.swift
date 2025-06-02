//
//  DateFilter.swift
//  WellingtonEvents
//
//  Created by ialbuquerque on 16/04/2025.
//

import Foundation

struct DateFilter: FilterObjectProtocol {
    let id: FilterIds = .date
    
    var startDate: Date
    var endDate: Date
    
    init(startDate: Date, endDate: Date) {
        self.startDate = startDate
        self.endDate = endDate
    }
    
    func execute(event: EventInfo, events: inout [EventInfo]) {
        let withInRange = event.dates.oneSatisfies(condition: { date in
            let greaterThenCondition = startDate.checkConditionIgnoringTime(
                other: date
            ) {
                $0 <= $1
            }

            let lessThenCondition = endDate.checkConditionIgnoringTime(
                other: date
            ) {
                $0 >= $1
            }

            return greaterThenCondition && lessThenCondition
        })
        if !withInRange {
            events.removeAll(where: { $0.id == event.id})
        }
    }
}

extension Date: @retroactive Identifiable {
    private static var calendar: Calendar {
        .init(identifier: .gregorian)
    }
    public var id: String {
        self.asString(with: .yyyyMMddHHmmDashed)
    }

    func checkConditionIgnoringTime(
        other: Date,
        condition: (Date, Date) -> Bool
    ) -> Bool {
        let selfDate = Self.calendar.date(
            bySettingHour: 0,
            minute: 0,
            second: 0,
            of: self
        )
        let otherDate = Self.calendar.date(
            bySettingHour: 0,
            minute: 0,
            second: 0,
            of: other
        )

        guard let selfDate, let otherDate else {
            return false
        }

        return condition(selfDate, otherDate)
    }
}
