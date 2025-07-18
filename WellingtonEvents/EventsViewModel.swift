//
//  EventsViewModel.swift
//  WellingtonEvents
//
//  Created by ialbuquerque on 06/01/2025.
//

import Foundation
import CasePaths
import Combine
import SwiftUI
import DesignLibrary

@CasePathable
enum Destination {
    struct FilterValues: Identifiable {
        var id: FilterIds
        var items: [String]
    }
    
    case calendar(event: EventInfo)
    case filters(for: FilterValues)
    case alert(ToastStyle)
    case dateSelector(startDate: Date, endDate: Date, selectedQuickDate: QuickDateType?, id: String)
    case webView(url: String)
}

enum StackDestination: Hashable {
    case eventDetails(EventInfo)
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
    @Published var eventsInCalendar: [EventInfo] = []
    let repository: EventsRepository = DefaultEventsRepository()
    
    var allEvents: [EventInfo]
    @Published var events: [EventInfo]
    @Published var isLoading: Bool = true
    
    @Published var searchText = ""
    @Published var scrollToTop = false
    
    var filters: Filters?
    @Published var selectedFilters: [any FilterObjectProtocol] = []
    
    @Published var route: Destination?
    var cancellables = Set<AnyCancellable>()
    
    @Published var navigationPath: [StackDestination] = []
    
    func setup() async {
        await fetchEvents()
        self.favourites = await repository.retrieveFavorites()
        refreshCalendarEvents()
        guard !allEvents.isEmpty else {
            return
        }
        await repository.deleteFromFavorites(eventIds: favourites.compactMap { event in
            if !allEvents.contains(where: { $0.id == event.id }) {
                return event.id
            }
            return nil
        })
        
        await repository.didDeleteFromCalendar(eventIds: eventsInCalendar.compactMap { event in
            if !allEvents.contains(where: { $0.id == event.id }) {
                return event.id
            }
            return nil
        })
    }
    
    init(
        favourites: [EventInfo] = [],
        eventsInCalendar: [EventInfo] = [],
        allEvents: [EventInfo] = [],
        events: [EventInfo] = []) {
            self.favourites = favourites
            self.eventsInCalendar = eventsInCalendar
            self.allEvents = allEvents
            self.events = events
            $searchText
                .dropFirst()
                .debounce(for: .seconds(0.1), scheduler: DispatchQueue.main)
                .sink { [weak self] value in
                    guard let self else {
                        return
                    }
                    didTypeSearch(string: value)
                }
                .store(in: &cancellables)
        }
    
    func fetchEvents() async {
        selectedFilters = []
        isLoading = true
        defer {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [unowned self] in
                self.isLoading = false
            }
        }
        do {
            let response = try await repository.fetchEvents()
            events = (response?.events.filter { !$0.dates.isEmpty } ?? [])
                .sorted(by: {
                    guard let date1 = $0.dates.first, let date2 = $1.dates.first else {
                        return false
                    }
                    return date1 < date2
                })
            
            filters = response?.filters
            
            allEvents = events
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    func appBecameActive() {
        Task {
            if await !repository.canFetchFromCache() {
                await setup()
            }
        }
    }
    
    func isEventFavourited(id: String) -> Bool {
        favourites.contains(where: { id == $0.id })
    }
    
    func isEventInCalendar(id: String) -> Bool {
        eventsInCalendar.contains(where: { id == $0.id })
    }
    
    func saveToFavorites(event: EventInfo) {
        Task {
            await repository.saveToFavorites(event: event)
            favourites.append(event)
        }
    }
    
    func deleteFromFavorites(event: EventInfo) {
        Task {
            await repository.deleteFromFavorites(event: event)
            favourites.removeAll(where: { event.id == $0.id })
        }
    }
    
    func saveToCalendar(event: EventInfo) {
        if event.dates.count > 1 {
            route = .calendar(event: event)
        }
        else {
            addToCalendar(event: event, date: event.dates.firstValidDate)
            refreshCalendarEvents()
        }
    }
    
    private func addToCalendar(event: EventInfo, date: Date?) {
        Task {
            do {
                try await CalendarManager.saveEventToCalendar(eventInfo: event, date: date, repository: repository)
                route = .alert(.success(message: "Event successfully added to your calendar."))
                refreshCalendarEvents()
            }
            catch {
                route = .alert(.error(message: error.localizedDescription))
            }
        }
    }
    
    func deleteFromCalendar(event: EventInfo) {
        Task {
            do {
                try await CalendarManager.removeFromCalendar(event: event, repository: repository)
            }
            catch {
                print(error.localizedDescription)
            }
            refreshCalendarEvents()
        }
    }
    
    func didTapOnEvent(with id: String) {
        guard let event = allEvents.first(where: { $0.id == id }) else {
            return
        }
        
        navigationPath.append(.eventDetails(event))
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
    
    func refreshCalendarEvents() {
        Task {
            eventsInCalendar = await repository.retrieveSavedToCalendar()
        }
    }
}
