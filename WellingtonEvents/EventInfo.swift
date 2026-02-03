//
//  EventInfo.swift
//  WellingtonEvents
//
//  Created by ialbuquerque on 06/01/2025.
//

import Foundation

struct EventsResponse: Codable {
    struct Filters: Codable, Equatable {
        let eventTypes: [String]
        let sources: [String]
    }
    
    let events: [EventInfo]
    let filters: Filters?
    
    enum CodingKeys: CodingKey {
        case events
        case filters
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.events = try container.decode([EventInfo].self, forKey: .events)
        self.filters = try container.decodeIfPresent(Filters.self, forKey: .filters)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.events, forKey: .events)
        try container.encode(self.filters, forKey: .filters)
    }
}

struct Location: Codable, Equatable {
    let lat: Double
    let long: Double
}

struct EventInfo: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let description: String
    let imageUrl: String?
    let venue: String
    var dates: [Date]
    let displayDate: String
    let url: String
    let source: String
    let labels: [String]
    let location: Location?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case imageUrl
        case venue
        case dates
        case displayDate
        case url
        case source
        case labels
        case coordinates
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.description, forKey: .description)
        try container.encodeIfPresent(self.imageUrl, forKey: .imageUrl)
        try container.encode(self.venue, forKey: .venue)
        try container.encodeIfPresent(self.dates.map { $0.asString(with: .yyyyMMddHHmmDashed) }, forKey: .dates)
        try container.encodeIfPresent(self.displayDate, forKey: .displayDate)
        try container.encode(self.url, forKey: .url)
        try container.encode(self.source, forKey: .source)
        try container.encode(self.labels, forKey: .labels)
        try container.encodeIfPresent(self.location, forKey: .coordinates)
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.description = try container.decode(String.self, forKey: .description)
        self.id = try container.decode(String.self, forKey: .id)
        self.imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
        self.venue = try container.decode(String.self, forKey: .venue)
        let dateStrings = try container.decodeIfPresent([String].self, forKey: .dates)
        self.dates =  dateStrings?.compactMap {
            guard let date = $0.asDate(with: .yyyyMMddHHmmDashed) else {
                return nil
            }
            return date > .now ? date : nil
        } ?? []
        var dates: [Date] = []
        for date in self.dates {
            if !dates.contains(date) {
                dates.append(date)
            }
        }
        self.dates = dates
        let displayDate = try container.decode(String.self, forKey: .displayDate)
        
        if self.dates.count == 1, displayDate.contains(" + more") {
            self.displayDate = dates[0].asString(with: .eeeddmmmSpaced)
        }
        else {
            self.displayDate = displayDate
        }
        
        self.url = try container.decode(String.self, forKey: .url)
        self.source = try container.decode(String.self, forKey: .source)
        do {
            self.labels = try container.decode([String].self, forKey: .labels)
        }
        catch {
            self.labels = []
        }
        self.location = try container.decodeIfPresent(Location.self, forKey: .coordinates)
    }
    
    static func == (lhs: EventInfo, rhs: EventInfo) -> Bool {
        return lhs.id == rhs.id
    }
}

extension EventInfo: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
