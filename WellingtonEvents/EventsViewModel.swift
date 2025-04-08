//
//  EventsViewModel.swift
//  WellingtonEvents
//
//  Created by ialbuquerque on 06/01/2025.
//

import Foundation
import NetworkLayerSPM
import CasePaths
import Combine
import SwiftUI
import DesignLibrary

@CasePathable
enum Destination {
    case calendar(event: EventInfo)
    case filters(for: FilterValues)
    case alert(ToastStyle)
}

struct urlBuilder: NetworkLayerURLBuilder {
    func url() -> URL? {
        .init(string: "https://raw.githubusercontent.com/intiMRA/Wellington-Events-Scrapper/refs/heads/main/events.json")
    }
}

struct DateModel: Equatable, Identifiable {
    let id: String
    let month: String
    var dates: [Date]
    
    init?(id: String, month: String, dates: [Date]?) {
        guard let dates else {
            return nil
        }
        self.id = id
        self.month = month
        self.dates = dates
    }
}

@MainActor
class EventsViewModel: ObservableObject {
    
    @Published var favourites: [EventInfo] = []
    private let repository: EventsRepository = UserDefaultsEventsRepository()
    
    var allEvents: [EventInfo]
    @Published var events: [EventInfo]
    @Published var selectedDate: Date
    @Published var isLoading: Bool = true
    
    @Published var searchText = ""
    @Published var noDateIsExpanded: Bool = true
    @Published var favoritesFilterOn: Bool = false
    
    var filters: Filters?
    @Published var selectedFilters: [Filter] = []
    
    @Published var route: Destination?
    var cancellables = Set<AnyCancellable>()
    
    func setup() async {
        await fetchEvents()
        self.favourites = repository.retrieveFavorites()
        guard !allEvents.isEmpty else {
            return
        }
        repository.deleteFromFavorites(eventIds: favourites.compactMap { event in
            if !allEvents.contains(where: { $0.id == event.id }) {
                return event.id
            }
            return nil
        })
    }
    
    init(
        favourites: [EventInfo] = [],
        allEvents: [EventInfo] = [],
        events: [EventInfo] = [],
        selectedDate: Date = .now) {
            self.favourites = favourites
            self.allEvents = allEvents
            self.events = events
            self.selectedDate = selectedDate
            self.noDateIsExpanded = noDateIsExpanded
            $searchText
                .dropFirst()
                .debounce(for: .seconds(0.1), scheduler: DispatchQueue.main)
                .sink { [weak self] value in
                    self?.filterEvents(containing: value)
                }
                .store(in: &cancellables)
        }
    
    func fetchEvents() async {
        selectedFilters = []
        isLoading = true
        defer {
            isLoading = false
        }
        do {
            let response: EventsResponse? = (try await NetworkLayer.defaultNetworkLayer.request(.init(urlBuilder: urlBuilder(), httpMethod: .GET)))
            events = response?.events.sorted(by: {
                guard let date1 = $0.dates.first, let date2 = $1.dates.first else {
                    return true
                }
                
                if date1 == date2 {
                    return $0.name < $1.name
                }
                
                return date1 < date2
            }) ?? []
            
            filters = response?.filters
            
            allEvents = events
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    func filterEvents(containing string: String) {
        guard !string.isEmpty else {
            events = allEvents
            return
        }
        
        var events = allEvents.filter({ $0.name.lowercased().starts(with: string.lowercased())})
        events.append(contentsOf: allEvents.filter({ event in event.name.lowercased().contains(string.lowercased()) && !events.contains(where: { $0.id == event.id }) }))
        
        events.append(contentsOf: allEvents.filter({ event in event.source.lowercased().contains(string.lowercased()) && !events.contains(where: { $0.id == event.id }) }))
        self.events = events
    }
    
    func isEventFavourited(id: String) -> Bool {
        favourites.contains(where: { id == $0.id })
    }
    
    func saveToFavorites(event: EventInfo) {
        repository.saveToFavorites(event: event)
        favourites.append(event)
    }
    
    func deleteFromFavorites(event: EventInfo) {
        repository.deleteFromFavorites(event: event)
        favourites.removeAll(where: { event.id == $0.id })
    }
    
    func saveToCalendar(event: EventInfo) {
        if event.dates.count > 1 {
            route = .calendar(event: event)
        }
        else {
            addToCalendar(event: event, date: event.dates.first)
        }
    }
    
    private func addToCalendar(event: EventInfo, date: Date?) {
        Task {
            do {
                try await CalendarManager.saveEventToCalendar(eventInfo: event, date: selectedDate)
                route = .alert(.success(message: "Event successfully added to your calendar."))
            }
            catch {
                route = .alert(.error(message: error.localizedDescription))
            }
        }
    }
    
    func didTapOnEvent(with id: String) {
        guard let event = allEvents.first(where: { $0.id == id }) else {
            return
        }
        
        if let url = URL(string: event.url), UIApplication.shared.canOpenURL(url) {
            print(event.url)
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            print("Cannot open URL")
        }
    }
    
    func expandFilter(for items: [String], filterType: Filters.FilterType) {
        guard !items.isEmpty else {
            return
        }
        route = .filters(for: .init(items: items, filterType: filterType))
    }
    
    func clearFilters(for source: Filters.FilterType) {
        switch source {
        case .eventTypes:
            selectedFilters.removeAll(where: { filters?.eventTypes.contains($0.filter) == true })
        case .sources:
            selectedFilters.removeAll(where: { filters?.sources.contains($0.filter) == true })
        }
        applyFilters(filters: selectedFilters)
    }
    
    func applyFilters(filters: [Filter]) {
        guard !filters.isEmpty || favoritesFilterOn else {
            events = allEvents
            selectedFilters = []
            return
        }
        
        var newEvents: [EventInfo] = []
        for event in allEvents {
            if favoritesFilterOn {
                if favourites.contains(where: { $0.id == event.id }) {
                    newEvents.append(event)
                }
            }
            
            for filter in filters {
                if newEvents.contains(where: { event.id == $0.id }) {
                    continue
                }
                
                switch filter.filterType {
                case .eventTypes:
                    if event.eventType == filter.filter {
                        newEvents.append(event)
                    }
                case .sources:
                    if event.source == filter.filter {
                        newEvents.append(event)
                    }
                }
            }
        }
        self.selectedFilters = filters
        self.events = newEvents
    }
    
    func selectedFilterSource() -> [Filters.FilterType] {
        var selectedSources: [Filters.FilterType] = []
        if filters?.sources.oneOf(elements: selectedFilters.map { $0.filter} ) == true {
            selectedSources.append(.sources)
        }
        
        if filters?.eventTypes.oneOf(elements: selectedFilters.map { $0.filter} ) == true {
            selectedSources.append(.eventTypes)
        }
        
        return selectedSources
    }
    
    func resetRoute() {
        route = nil
    }
    
    func dissmissCalendar(_ style: ToastStyle?) {
        withAnimation {
            guard let style else {
                resetRoute()
                return
            }
            route = .alert(style)
        }
    }
}
