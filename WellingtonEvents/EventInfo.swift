//
//  EventInfo.swift
//  WellingtonEvents
//
//  Created by ialbuquerque on 06/01/2025.
//

import Foundation

struct EventInfo: Codable {
    let name: String
    let imageUrl: String?
    let venue: String
    let date: String?
    let url: String
}
