//
//  FilterOptionsViewModel.swift
//  WellingtonEvents
//
//  Created by ialbuquerque on 17/03/2025.
//

import Foundation

struct FilterValues: Equatable, Identifiable, Hashable {
    let items: [String]
    let filterType: Filters.FilterType
    var id: Filters.FilterType {
        filterType
    }
}

struct Filter: Equatable {
    let filterType: Filters.FilterType
    let filter: String
}

@MainActor
@Observable
class FilterOptionsViewModel {
    var selectedFilters: [Filter]
    let possibleFilters: FilterValues
    let finishedFiltering: ([Filter]) -> Void
    let dismiss: () -> Void
    
    init(
        possibleFilters: FilterValues,
        selectedFilters: [Filter],
        finishedFiltering: @escaping ([Filter]) -> Void,
        dismiss: @escaping () -> Void) {
        self.selectedFilters = selectedFilters
        self.finishedFiltering = finishedFiltering
        self.possibleFilters = possibleFilters
        self.dismiss = dismiss
    }
    
    func didFinishedFiltering() {
        finishedFiltering(selectedFilters)
        dismiss()
    }
    
    func didTapOnFilter(_ filter: String) {
        let filterWithType = Filter(filterType: possibleFilters.filterType, filter: filter)
        if selectedFilters.contains(filterWithType) {
            selectedFilters.removeAll(where: { $0 == filterWithType })
        }
        else {
            selectedFilters.append(filterWithType)
        }
    }
    
    func filterIsSelected(_ filter: String) -> Bool {
        selectedFilters.contains(where: { $0.filter == filter })
    }
}
