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
    case iso8601 = "yyyy-MM-dd'T'HH:mm:ss'Z'"
    
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
}

extension String {
    func asDate(with format: Formats) -> Date? {
        Formats.formatter(for: format).date(from: self)
    }
}
