//
//  EventsViewModel.swift
//  WellingtonEvents
//
//  Created by ialbuquerque on 06/01/2025.
//

import Foundation
import NetworkLayerSPM

struct urlBuilder: NetworkLayerURLBuilder {
    func url() -> URL? {
        .init(string: "https://raw.githubusercontent.com/intiMRA/Wellington-Events-Scrapper/refs/heads/main/evens.json")
    }
}

@Observable
class EventsViewModel {
    var events: [EventInfo] = []
    
    func fetchEvents() async {
        
        events = (try? await NetworkLayer.defaultNetworkLayer.request(.init(urlBuilder: urlBuilder(), httpMethod: .GET))) ?? [.init(name: "no events", imageUrl: "", venue: "", date: "", url: "")]
    }
}
