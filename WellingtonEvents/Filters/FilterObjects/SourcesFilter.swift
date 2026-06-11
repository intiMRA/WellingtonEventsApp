//
//  SourcesFilter.swift
//  WellingtonEvents
//
//  Created by ialbuquerque on 16/04/2025.
//

import Foundation

struct SourcesFilter: FilterObjectProtocol {
    let id: FilterIds = .source
    let sources: [String]
    
    func matches(_ event: EventInfo) -> Bool {
        sources.contains(where: { $0 == event.source })
    }
}
