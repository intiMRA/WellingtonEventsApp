//
//  EventsViewModel+Filters.swift
//  WellingtonEvents
//
//  Created by ialbuquerque on 16/04/2025.
//

import Foundation

extension EventsViewModel {
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
    
    func expandFilter(for items: [String], filterType: FilterIds) {
        guard !items.isEmpty else {
            return
        }
        route = .filters(for: .init(id: filterType, items: items))
    }
    
    func clearFilters(for source: FilterIds) {
        selectedFilters.removeAll(where: { $0.id == source })
        applyFilters()
    }
    
    func didSelectFilterValues(values: [String], type: FilterIds) {
        switch type {
        case .source:
            selectedFilters.removeAll(where: { $0.id == .source })
            selectedFilters.append(SourcesFilter(sources: values))
        case .eventType:
            selectedFilters.removeAll(where: { $0.id == .eventType })
            selectedFilters.append(EventTypesFilter(eventTypes: values))
        default:
            break
        }
        applyFilters()
    }
    
    private func applyFilters() {
        guard !selectedFilters.isEmpty else {
            events = allEvents
            selectedFilters = []
            return
        }
        
        var newEvents: [EventInfo] = allEvents
        for event in allEvents {
            for filter in selectedFilters {
                filter.execute(event: event, events: &newEvents)
            }
        }
        self.events = newEvents
    }
    
    func selectedFilterSource() -> [FilterIds] {
        return selectedFilters.map { $0.id }
    }
    
    func didSelectDates(_ startDate: Date, _ endDate: Date) {
        selectedFilters.removeAll(where: { $0.id == .date })
        selectedFilters.append(DateFilter(startDate: startDate, endDate: endDate))
        resetRoute()
        applyFilters()
    }
    
    func showDateSelector() {
        let filter = selectedFilters.first(where: { $0.id == .date }) as? DateFilter
        let startDate = filter?.startDate ?? .now
        let endDate = filter?.endDate ?? .now
        route = .dateSelector(startDate: startDate, endDate: endDate, id: startDate.id + endDate.id)
    }
    
    func didTapFavouritesFilter() {
        if selectedFilters.contains(where: { $0.id == .favorited }) {
            selectedFilters.removeAll(where: { $0.id == .favorited })
        }
        else {
            selectedFilters.append(FavouritesFilter(favourites: favourites))
        }
        applyFilters()
    }
    
    func didTapOneOfFilter() {
        if selectedFilters.contains(where: { $0.id == .oneOf }) {
            selectedFilters.removeAll(where: { $0.id == .oneOf })
        }
        else {
            selectedFilters.append(OneOfFilter())
        }
        applyFilters()
    }
    
    func didTapMultipleDatesFilter() {
        if selectedFilters.contains(where: { $0.id == .multipleDates }) {
            selectedFilters.removeAll(where: { $0.id == .multipleDates })
        }
        else {
            selectedFilters.append(MultipleDatesFilter())
        }
        applyFilters()
    }
    
    func selectedFilters(for type: FilterIds) -> [String] {
        switch type {
        case .source:
            return (selectedFilters.first(where: { $0.id == .source }) as? SourcesFilter)?.sources ?? []
        case .eventType:
            return (selectedFilters.first(where: { $0.id == .eventType }) as? EventTypesFilter)?.eventTypes ?? []
        default:
            return []
        }
    }
    
}
