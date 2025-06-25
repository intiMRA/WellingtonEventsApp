//
//  DateFilter.swift
//  WellingtonEvents
//
//  Created by ialbuquerque on 16/04/2025.
//

import Foundation
import SwiftUI

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

enum QuickDateType: String, CaseIterable {
    case today
    case tomorrow
    case thisWeek
    case thisWeekend
    case nextWeek
    case thisMonth
    case nextMonth
    
    var name: String {
        switch self {
        case .thisMonth:
            return String(localized: "This month")
        case .thisWeek:
            return String(localized: "This week")
        case .thisWeekend:
            return String(localized: "This weekend")
        case .today:
            return String(localized: "Today")
        case .nextMonth:
            return String(localized: "Next month")
        case .nextWeek:
            return String(localized: "Next week")
        case .tomorrow:
            return String(localized: "Tomorrow")
        }
    }
    
    @MainActor
    static var lazyGrid: [GridItem] = {
        [
            GridItem(.flexible(minimum: 50, maximum: .infinity), alignment: .leading),
            GridItem(.flexible(minimum: 50, maximum: .infinity), alignment: .trailing)
        ]
    }()
    
}

struct QuickDateFilter: FilterObjectProtocol {
    let id: FilterIds = .quickDate
    
    var quickDateType: QuickDateType
    
    init(quickDateType: QuickDateType) {
        self.quickDateType = quickDateType
    }
    
    func execute(event: EventInfo, events: inout [EventInfo]) {
        let dates = Self.getDateRange(for: quickDateType)
        let startDate = dates.startDate
        let endDate = dates.endDate
        
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
    
    static func getDateRange(for type: QuickDateType) -> (startDate: Date, endDate: Date) {
        switch type {
        case .thisMonth:
            return Date.monthRange()
        case .thisWeek:
            return Date.weekRange()
        case .thisWeekend:
            return Date.weekEndRange()
        case .today:
            return (.now, .now)
        case .nextMonth:
            return Date.nextMonthRange()
        case .nextWeek:
            return Date.nextWeekRange()
        case .tomorrow:
            let tomorrow = Date.tomorrow()
            return (tomorrow, tomorrow)
        }
    }
}


extension Date: @retroactive Identifiable {
    static var calendar: Calendar {
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
