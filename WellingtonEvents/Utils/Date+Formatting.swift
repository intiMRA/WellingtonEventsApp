//
//  Date+Formatting.swift
//  WellingtonEvents
//
//  Created by ialbuquerque on 25/02/2025.
//

import Foundation

enum Formats: String {
    
    case ddMMYyyy = "dd-MM-yyyy"
    case ddMMMYyyySpaced = "dd MMM yyyy"
    case mmm = "MMM"
    case dd
    case yyyyMMddHHmmDashed = "yyyy-MM-dd-HH:mm"
    case ddMMMMSpaced = "dd MMMM"
    case eeeddmmmSpaced = "EEE dd MMM"
    case eeeddmmmSpacedHMMA = "EEE dd MMM h:mm a"
    case hhmm = "h:mm a"
    
    static func formatter(for format: Self) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = format.rawValue
        return formatter
    }
}

extension Date {
    var displayAsAllDay: Bool {
        let components = Self.calendar.dateComponents([.hour, .minute], from: self)
        return components.hour == 1 && components.minute == 1
    }
    
    var happeningSoon: Bool {
        let component = Self.calendar.dateComponents([.day, .hour, .minute], from: .now, to: self)
        return !happeningNow && component.day ?? 0 < 1 && component.hour ?? 0 <= 1 && component.minute ?? 0 <= 30
    }
    
    var happeningNow: Bool {
        let component = Self.calendar.dateComponents([.day, .hour, .minute], from: .now, to: self)
        return component.day ?? 0 < 1 && component.hour ?? 0 <= 1 && component.minute ?? 0 <= 10
    }
    
    init?(from string: String, with format: Formats) {
        guard let date = Formats.formatter(for: format).date(from: string) else {
            return nil
        }
        self = date
    }
    
    func asString(with format: Formats) -> String {
        Formats.formatter(for: format).string(from: self)
    }
    
    static func tomorrow() -> Date {
        let now = Date()
        
        guard
            let today = calendar.date(from: calendar.dateComponents([.day, .month, .year], from: now)),
            let tomorrow = calendar.date(byAdding: DateComponents(day: 1), to: today)
        else {
            fatalError("failed to generate months range")
        }
        return tomorrow
    }
    
    static func monthRange() -> (Date, Date) {
        let now = Date()
        
        guard
            let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)),
            let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)
        else {
            fatalError("failed to generate months range")
        }
        return (now, endOfMonth)
    }
    
    static func nextMonthRange() -> (Date, Date) {
        let now = Date()
        
        let thisMonth = calendar.component(.month, from: now)
        let nextMonth = thisMonth == 12 ? 1 : thisMonth + 1
        var currentYear = calendar.component(.year, from: now)
        currentYear = nextMonth == 1 ? currentYear + 1 : currentYear
        
        guard let startOfMonth = calendar.date(from: .init(year: currentYear, month: nextMonth, day: 1)),
              let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)  else {
            fatalError("failed to generate next months range")
        }
        return (startOfMonth, endOfMonth)
    }
    
    static func weekRange() -> (Date, Date) {
        let now = Date()
        
        guard
            let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)),
            let endOfWeek = calendar.date(byAdding: DateComponents(day: 7), to: startOfWeek)
        else {
            fatalError("failed to generate week range")
        }
        return (now, endOfWeek)
    }
    
    static func nextWeekRange() -> (Date, Date) {
        let now = Date()
        
        guard
            let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)),
            let startOfNextWeek = calendar.date(byAdding: .day, value: 8, to: startOfWeek),
            let endOfNextWeek = calendar.date(byAdding: DateComponents(day: 6), to: startOfNextWeek)
        else {
            fatalError("failed to generate week range")
        }
        return (startOfNextWeek, endOfNextWeek)
    }
    
    static func weekEndRange() -> (Date, Date) {
        let now = Date.now
        let today = calendar.component(.weekday, from: now)
        var startOfWeekend: Date?
        
        if today <= 6 {
            startOfWeekend = calendar.date(byAdding: DateComponents(day: 7 - today), to: now)
        }
        else {
            startOfWeekend = now
        }
        
        guard
            let startOfWeekend,
            let endOfWeekend = calendar.date(byAdding: DateComponents(day: 1), to: startOfWeekend)
        else {
            fatalError("failed to generate week end range")
        }
        
        return (startOfWeekend, endOfWeekend)
    }
    
    func addingDay() -> Date? {
        let currentDate = Date.calendar.date(from: Date.calendar.dateComponents([.day, .month, .year, .hour], from: self))
        return Date.calendar.date(byAdding: DateComponents(day: 1), to: currentDate!)
    }
    
    func isToday() -> Bool {
        let now = Date()
        
        let nowComponents = Self.calendar.dateComponents([.day, .month, .year], from: now)
        let selfComponents = Self.calendar.dateComponents([.day, .month, .year], from: self)
        
        return nowComponents.day == selfComponents.day
        && nowComponents.month == selfComponents.month
        && nowComponents.year == selfComponents.year
    }
}

extension String {
    func asDate(with format: Formats) -> Date? {
        Formats.formatter(for: format).date(from: self)
    }
}

extension Collection where Element == Date {
    var firstValidDate: Date? {
        self.first(where: { Date.now <= $0 })
    }
}
