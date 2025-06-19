//
//  FilterOptionsViewModel.swift
//  WellingtonEvents
//
//  Created by ialbuquerque on 17/03/2025.
//

import Foundation

@MainActor
@Observable
class FilterOptionsViewModel {
    let filterTye: FilterIds
    var selectedFilters: [String]
    let possibleFilters: [String]
    let finishedFiltering: ([String], FilterIds) -> Void
    let dismiss: () -> Void
    
    init(
        filterTye: FilterIds,
        possibleFilters: [String],
        selectedFilters: [String],
        finishedFiltering: @escaping ([String], FilterIds) -> Void,
        dismiss: @escaping () -> Void) {
            self.selectedFilters = selectedFilters
            self.finishedFiltering = finishedFiltering
            self.possibleFilters = possibleFilters
            self.dismiss = dismiss
            self.filterTye = filterTye
        }
    
    func didFinishedFiltering() {
        if !selectedFilters.isEmpty {
            finishedFiltering(selectedFilters, filterTye)
        }
        dismiss()
    }
    
    func didTapOnFilter(_ filter: String) {
        if selectedFilters.contains(filter) {
            selectedFilters.removeAll(where: { $0 == filter })
        }
        else {
            selectedFilters.append(filter)
        }
    }
    
    func filterIsSelected(_ filter: String) -> Bool {
        selectedFilters.contains(where: { $0 == filter })
    }
}
