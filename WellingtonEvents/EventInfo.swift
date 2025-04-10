//
//  EventInfo.swift
//  WellingtonEvents
//
//  Created by ialbuquerque on 06/01/2025.
//

import Foundation

struct EventsResponse: Codable {
    let events: [EventInfo]
    let filters: Filters
    
    enum CodingKeys: CodingKey {
        case events
        case filters
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.events = try container.decode([EventInfo].self, forKey: .events)
        self.filters = try container.decode(Filters.self, forKey: .filters)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.events, forKey: .events)
        try container.encode(self.filters, forKey: .filters)
    }
}

struct Filters: Codable {
    let eventTypes: [String]
    let sources: [String]
    
    enum FilterType: String, Equatable {
        case eventTypes, sources, dates
    }
}

struct EventInfo: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let imageUrl: String?
    let venue: String
    var dates: [Date]
    let displayDate: String?
    let url: String
    let source: String
    let eventType: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case imageUrl
        case venue
        case dates
        case displayDate
        case url
        case source
        case eventType
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.name, forKey: .name)
        try container.encodeIfPresent(self.imageUrl, forKey: .imageUrl)
        try container.encode(self.venue, forKey: .venue)
        try container.encodeIfPresent(self.dates.map { $0.asString(with: .ddMMYyyy) }, forKey: .dates)
        try container.encodeIfPresent(self.displayDate, forKey: .displayDate)
        try container.encode(self.url, forKey: .url)
        try container.encode(self.source, forKey: .source)
        try container.encode(self.eventType, forKey: .eventType)
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.id = try container.decode(String.self, forKey: .id)
        self.imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
        self.venue = try container.decode(String.self, forKey: .venue)
        let dateStrings = try container.decodeIfPresent([String].self, forKey: .dates)
        self.dates =  dateStrings?.compactMap { $0.asDate(with: .ddMMYyyy) } ?? []
        self.dates = Array(Set(self.dates))
        self.displayDate = try container.decodeIfPresent(String.self, forKey: .displayDate)
        self.url = try container.decode(String.self, forKey: .url)
        self.source = try container.decode(String.self, forKey: .source)
        do {
            self.eventType = try container.decode(String.self, forKey: .eventType)
        }
        catch {
            self.eventType = "Other"
        }
    }
}
