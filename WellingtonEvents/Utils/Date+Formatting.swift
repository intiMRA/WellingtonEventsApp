//
//  Date+Formatting.swift
//  WellingtonEvents
//
//  Created by ialbuquerque on 25/02/2025.
//

import Foundation

enum Formats: String {
    
    case ddMMYyyy = "dd-MM-yyyy"
    case mmm = "MMM"
    case dd
    case yyyyMMddHHmmDashed = "yyyy-MM-dd-HH:mm"
    case ddMMMMSpaced = "dd MMMM"
    
    static func formatter(for format: Self) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = format.rawValue
        return formatter
    }
}

extension Date {
    func asString(with format: Formats) -> String {
        Formats.formatter(for: format).string(from: self)
    }
    
    init?(from string: String, with format: Formats) {
        guard let date = Formats.formatter(for: format).date(from: string) else {
            return nil
        }
        self = date
    }
    
    static func monthRange() -> (Date, Date) {
        let now = Date()
        
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) else {
            fatalError("failed to generate months range")
        }
        
        guard let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) else {
            fatalError("failed to generate months range")
        }
        return (now, endOfMonth)
    }
    
    static func weekRange() -> (Date, Date) {
        let now = Date()
        
        guard let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))else {
            fatalError("failed to generate week range")
        }
        
        guard let endOfWeek = calendar.date(byAdding: DateComponents(day: 6), to: startOfWeek) else {
            fatalError("failed to generate week range")
        }
        return (now, endOfWeek)
    }
    
    static func weekEndRange() -> (Date, Date) {
        let now = Date.now
        let today = calendar.component(.weekday, from: now)
        var startOfWeekend: Date?

        if today <= 6 { // If today is Saturday
            startOfWeekend = calendar.date(byAdding: DateComponents(day: 6 - today), to: now)
        } else { // If today is Sunday
            startOfWeekend = calendar.date(byAdding: DateComponents(day: 6 - today + 7), to: now)
        }
        
        guard let startOfWeekend else {
            fatalError("failed to generate week end range")
        }
        
        guard let endOfWeekend = calendar.date(byAdding: DateComponents(day: 1), to: startOfWeekend) else {
            fatalError("failed to generate week end range")
        }
        return (startOfWeekend, endOfWeekend)
    }
}

extension String {
    func asDate(with format: Formats) -> Date? {
        Formats.formatter(for: format).date(from: self)
    }
}
