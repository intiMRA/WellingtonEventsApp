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
    
    let repository: EventsRepository = DefaultEventsRepository()
    
    var allEvents: [EventInfo]
    @Published var events: [EventInfo]
    @Published var isLoading: Bool = true
    
    @Published var searchText = ""
    var oldSearchText: String = ""
    @Published var scrollToTop = false
    
    var filters: Filters?
    @Published var selectedFilters: [any FilterObjectProtocol] = []
    
    @Published var route: Destination?
    var cancellables = Set<AnyCancellable>()
    
    @Published var navigationPath: [StackDestination] = []
    
    func setup() async {
        await fetchEvents()
    }
    
    init(
        favourites: [EventInfo] = [],
        eventsInCalendar: [EventInfo] = [],
        allEvents: [EventInfo] = [],
        events: [EventInfo] = []) {
            self.allEvents = allEvents
            self.events = events
            $searchText
                .dropFirst()
                .debounce(for: .seconds(0.1), scheduler: DispatchQueue.main)
                .sink { [weak self] value in
                    guard let self else {
                        return
                    }
                    if oldSearchText != value {
                        didTypeSearch(string: value)
                        oldSearchText = value
                    }
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
    
    func showErrorAlert(_ title: String? = nil, _ message: String) {
        route = .alert(.error(title: title, message: message))
    }
}
