//
//  SearchFilter.swift
//  WellingtonEvents
//
//  Created by ialbuquerque on 31/05/2025.
//

struct SearchFilter: FilterObjectProtocol, BurgerFilterObjectProtocol {
    let burgerFilterId: BurgerFilterIds = .search
    let id: FilterIds = .search
    let searchString: String

    func matches(_ event: EventInfo) -> Bool { true }
    func matches(_ burger: BurgerModel) -> Bool { true }

    func execute<T: Filterable>(items: inout [T]) {
        let all = items
        items.removeAll(where: { !$0.name.lowercased().starts(with: searchString.lowercased()) })
        items.append(contentsOf: all.filter { item in
            item.name.lowercased().contains(searchString.lowercased()) && !items.contains(where: { $0.id == item.id })
        })
        items.append(contentsOf: all.filter { item in
            item.venue.lowercased().contains(searchString.lowercased()) && !items.contains(where: { $0.id == item.id })
        })
    }
}
