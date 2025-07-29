//
//  MapViewModel+Filters.swift
//  WellingtonEvents
//
//  Created by Inti Albuquerque on 29/07/2025.
//

import Foundation
extension MapViewModel {
    
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
    
    func clearFilters(for sources: [FilterIds]) {
        selectedFilters.removeAll(where: { filter in sources.contains(where: { $0 == filter.id }) })
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
    
    func applyFilters() {
        guard !selectedFilters.isEmpty else {
            events = allEvents
            selectedFilters = []
            return
        }
        
        var newEvents: [MapEventtModel] = allEvents
        for event in allEvents {
            for filter in selectedFilters {
                // search has to be applies differently
                if filter.id == .search {
                    continue
                }
                filter.execute(event: event, events: &newEvents)
            }
        }
        let searchFilter = selectedFilters.first(where: { $0.id == .search }) as? SearchFilter
        searchFilter?.execute(events: &newEvents)
        self.events = newEvents
    }
    
    func selectedFilterSource() -> [FilterIds] {
        return selectedFilters.map { $0.id }
    }
    
    func didSelectDates(_ startDate: Date, _ endDate: Date, _ quickDateType: QuickDateType?) {
        clearFilters(for: [.date, .quickDate])
        if let quickDateType {
            selectedFilters.append(QuickDateFilter(quickDateType: quickDateType))
        }
        else {
            selectedFilters.append(DateFilter(startDate: startDate, endDate: endDate))
        }
        resetRoute()
        applyFilters()
    }
    
    func showDateSelector() {
        let dateFilter = selectedFilters.first(where: { $0.id == .date }) as? DateFilter
        let startDate = dateFilter?.startDate ?? .now
        let endDate = dateFilter?.endDate ?? .now
        let quickDateFilter = selectedFilters.first(where: { $0.id == .quickDate }) as? QuickDateFilter
        route = .dateSelector(startDate: startDate, endDate: endDate, selectedQuickDate: quickDateFilter?.quickDateType, id: startDate.id + endDate.id)
    }
    
    func didSelectDistance(_ distance: Double) {
        clearFilters(for: [.distance])
        selectedFilters.append(DistanceFilter(distance: distance))
        resetRoute()
        applyFilters()
    }
    
    func showDistanceSelector() {
        let dateFilter = selectedFilters.first(where: { $0.id == .distance }) as? DistanceFilter
        route = .distance(distance: dateFilter?.distance ?? 0.0)
    }
    
    func didTapFavouritesFilter(favourites: [EventInfo]) {
        if selectedFilters.contains(where: { $0.id == .favorited }) {
            selectedFilters.removeAll(where: { $0.id == .favorited })
        }
        else {
            selectedFilters.append(FavouritesFilter(favourites: favourites))
        }
        applyFilters()
    }
    
    func didFavoriteEvent(favourites: [EventInfo]) {
        if selectedFilters.contains(where: { $0.id == .favorited }) {
            events.removeAll(where: { event in !favourites.contains(where: { $0.id == event.id })})
        }
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
    
    func didTypeSearch(string: String) {
        selectedFilters.removeAll(where: { $0.id == .search })
        if !string.isEmpty {
            selectedFilters.append(SearchFilter(searchString: string))
        }
        applyFilters()
    }
}

extension MapViewModel {
    func filterTitle(for type: FilterIds, isSelected: Bool) -> String {
        switch type {
        case .date:
            return isSelected ? getSelectedDatesFilterString() : String(localized: "Dates")
        case .quickDate:
            return isSelected ? getSelectedQuickDatesFilterString() : String(localized: "Dates")
        case .source:
            return isSelected ? getSelectedSourcesFilterString() : String(localized: "Sources")
        case .eventType:
            return isSelected ? getSelectedEventTypesFilterString() : String(localized: "Event Types")
        case .oneOf:
            return String(localized: "Happening once")
        case .multipleDates:
            return String(localized: "Multiple dates")
        case .favorited:
            return String(localized: "Favorited")
        case .search:
            return ""
        case .distance:
            return isSelected ? getSelectedDistanceFilterString() : String(localized: "Distance")
        }
    }
    
    private func getSelectedDistanceFilterString() -> String {
        let filter = (selectedFilters.first(where: { $0.id == .distance }) as? DistanceFilter)
       
        return "\(String(localized: "Distance:")) \(Int(filter?.distance ?? 0.0)) \(String(localized: "km"))"
    }
    
    private func getSelectedDatesFilterString() -> String {
        let datesFilter = (selectedFilters.first(where: { $0.id == .date }) as? DateFilter)
        let startDate = datesFilter?.startDate
        
        if let startDate, let endDate = datesFilter?.endDate {
            if endDate.checkConditionIgnoringTime(other: startDate, condition: { $0 > $1 }) {
                return "\(String(localized: "Dates:")) \(startDate.asString(with: .ddMMMMSpaced)) - \(endDate.asString(with: .ddMMMMSpaced))"
            }
        }
        return "\(String(localized: "Date:")) \(startDate?.asString(with: .ddMMMMSpaced) ?? "")"
    }
    
    private func getSelectedQuickDatesFilterString() -> String {
        guard let datesFilter = (selectedFilters.first(where: { $0.id == .quickDate }) as? QuickDateFilter) else {
            return String(localized: "Dates")
        }
        
        return "\(String(localized: "Quick Dates:")) \(datesFilter.quickDateType.name)"
    }
    
    private func getSelectedSourcesFilterString() -> String {
        let sources = selectedFilters(for: .source)
        if sources.count > 1 {
            return "\(String(localized: "Sources:")) \(sources.count) \(String(localized: "selected"))"
        }
        return "\(String(localized: "Source:")) \(sources.first ?? "")"
    }
    
    private func getSelectedEventTypesFilterString() -> String {
        let eventTypes = selectedFilters(for: .eventType)
        if eventTypes.count > 1 {
            return "\(String(localized: "Event types:")) \(eventTypes.count) \(String(localized: "selected"))"
        }
        return "\(String(localized: "Event type:")) \(eventTypes.first ?? "")"
    }
}
