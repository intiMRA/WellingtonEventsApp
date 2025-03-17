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

@CasePathable
enum Destination {
    struct FilterValue: Equatable, Identifiable, Hashable {
        let items: [String]
        let filterType: Filters.FilterType
        var id: Filters.FilterType {
            filterType
        }
    }
    case calendar(event: EventInfo)
    case filters(for: FilterValue)
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
    @Published var eventsWithNoDates: [EventInfo]
    @Published var isLoading: Bool = true
    
    @Published var searchText = ""
    @Published var noDateIsExpanded: Bool = true
    var filters: Filters?
    @Published var selectedFilter: String?
    
    @Published var route: Destination?
    var cancellables = Set<AnyCancellable>()
    
    func setup() async {
        await fetchEvents()
        self.favourites = repository.retrieveFavorites()
    }
    
    init(
        favourites: [EventInfo] = [],
        allEvents: [EventInfo] = [],
        events: [EventInfo] = [],
        selectedDate: Date = .now,
        eventsWithNoDates: [EventInfo] = []) {
        self.favourites = favourites
        self.allEvents = allEvents
        self.events = events
        self.selectedDate = selectedDate
        self.eventsWithNoDates = eventsWithNoDates
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
        selectedFilter = nil
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
            
            eventsWithNoDates = response?.eventsWithNoDate.sorted(by: { $0.name < $1.name }) ?? []
            
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
    
    func addToCalendar(event: EventInfo, date: Date?) {
        Task {
            await CalendarManager.saveEventToCalendar(eventInfo: event, date: date)
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
    
    func didSelectFilter(_ filter: String, filterType: Filters.FilterType) {
        selectedFilter = filter
        switch filterType {
        case .eventTypes:
            events = allEvents.filter { $0.eventType == filter }
        case .sources:
            events = allEvents.filter { $0.source == filter }
        }
        route = nil
    }
    
    func selectedFilterSource() -> Filters.FilterType? {
        if filters?.sources.contains(where: { $0 == selectedFilter }) == true {
            return .sources
        }
        
        if filters?.eventTypes.contains(where: { $0 == selectedFilter }) == true {
            return .sources
        }
        
        return nil
    }
    
    func clearFilters() {
        selectedFilter = nil
        events = allEvents
    }
    
    func datesByMonth(dates: [Date]) -> [DateModel] {
        var monthsDict = [String: [Date]]()
        var monthStrings: [String] = []
        dates.filter { $0 >= .now }.sorted(by: { $0 < $1 }).forEach { date in
            let monthString = date.asString(with: .mmm)
            if var month = monthsDict[monthString] {
                month.append(date)
                monthsDict[monthString] = month
            }
            else {
                monthsDict[monthString] = [date]
                monthStrings.append(monthString)
            }
        }
        
        return monthStrings.compactMap { .init(id: $0, month: $0, dates: monthsDict[$0]) }
    }
}
