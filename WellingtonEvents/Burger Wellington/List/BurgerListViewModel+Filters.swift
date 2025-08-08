//
//  BurgerListViewModel+Filters.swift
//  WellingtonEvents
//
//  Created by Inti Albuquerque on 08/08/2025.
//

import Foundation
extension BurgerListViewModel {
    func expandFilter(for items: [String], filterType: BurgerFilterIds) {
        guard !items.isEmpty else {
            return
        }
        route = .filters(for: .init(id: filterType, items: items))
    }
    
    func clearFilters(for source: BurgerFilterIds) {
        selectedFilters.removeAll(where: { $0.burgerFilterId == source })
        applyFilters()
    }
    
    func clearFilters(for sources: [BurgerFilterIds]) {
        selectedFilters.removeAll(where: { filter in sources.contains(where: { $0 == filter.burgerFilterId }) })
        applyFilters()
    }
    
    func didTapSidesFilter() {
        if selectedFilters.contains(where: { $0.burgerFilterId == .sidesIncluded }) {
            selectedFilters.removeAll(where: { $0.burgerFilterId == .sidesIncluded })
        }
        else {
            selectedFilters.append(SidesFilter())
        }
        applyFilters()
    }
    
    func didSelectFilterValues(values: [String], type: String) {
        guard let type = BurgerFilterIds(rawValue: type) else {
            return
        }
        
        switch type {
        case .dietryRestrictions:
            selectedFilters.removeAll(where: { $0.burgerFilterId == .dietryRestrictions })
            selectedFilters.append(DietryRestrictionsFilter(dietryRestrictions: values))
        case .beerMatches:
            selectedFilters.removeAll(where: { $0.burgerFilterId == .beerMatches })
            selectedFilters.append(BeerMatchesFilter(beerMatches: values))
        case .protein:
            selectedFilters.removeAll(where: { $0.burgerFilterId == .protein })
            selectedFilters.append(ProteinFilter(proteins: values))
        default:
            break
        }
        applyFilters()
    }
    
    private func applyFilters(scrollToTop: Bool = true) {
        guard !selectedFilters.isEmpty else {
            burgers = allBurgers
            selectedFilters = []
            self.scrollToTop = true
            return
        }
        
        var newBurgers = allBurgers
        for burger in allBurgers {
            for filter in selectedFilters {
                // search has to be applies differently
                if filter.burgerFilterId == .search {
                    continue
                }
                filter.execute(burger: burger, burgers: &newBurgers)
            }
        }
        let searchFilter = selectedFilters.first(where: { $0.burgerFilterId == .search }) as? SearchFilter
        searchFilter?.execute(burgers: &newBurgers)
        burgers = newBurgers
        self.scrollToTop = scrollToTop
    }
    
    func selectedFilterSource() -> [BurgerFilterIds] {
        return selectedFilters.map { $0.burgerFilterId }
    }
    
    func didSelectDistance(_ distance: Double) {
        clearFilters(for: [.distance])
        selectedFilters.append(DistanceFilter(distance: distance))
        resetRoute()
        applyFilters()
    }
    
    func showDistanceSelector() {
        let distanceFilter = selectedFilters.first(where: { $0.burgerFilterId == .distance }) as? DistanceFilter
        route = .distance(distance: distanceFilter?.distance ?? 0.0)
    }
    
    func showPriceSelector() {
        let priceFilter = selectedFilters.first(where: { $0.burgerFilterId == .price }) as? PriceFilter
        route = .price(price: priceFilter?.maxPrice ?? filters?.priceRange.max ?? 0.0)
    }
    
    func didTapFavouritesFilter() {
        if selectedFilters.contains(where: { $0.burgerFilterId == .favorited }) {
            selectedFilters.removeAll(where: { $0.burgerFilterId == .favorited })
        }
        else {
            selectedFilters.append(FavouritesFilter(favourites: favourites))
        }
        applyFilters()
    }
    
    func selectedFilters(for type: BurgerFilterIds) -> [String] {
        switch type {
        case .dietryRestrictions:
            return (selectedFilters.first(where: { $0.burgerFilterId == .dietryRestrictions }) as? DietryRestrictionsFilter)?.dietryRestrictions ?? []
        case .beerMatches:
            return (selectedFilters.first(where: { $0.burgerFilterId == .beerMatches }) as? BeerMatchesFilter)?.beerMatches ?? []
        case .protein:
            return (selectedFilters.first(where: { $0.burgerFilterId == .protein }) as? ProteinFilter)?.proteins ?? []
        default:
            return []
        }
    }
    
    func didTypeSearch(string: String) {
        selectedFilters.removeAll(where: { $0.burgerFilterId == .search })
        if !string.isEmpty {
            selectedFilters.append(SearchFilter(searchString: string))
        }
        applyFilters()
    }
}

extension BurgerListViewModel {
    func filterTitle(for type: BurgerFilterIds, isSelected: Bool) -> String {
        switch type {
        case .favorited:
            return String(localized: "Favorited")
        case .sidesIncluded:
            return String(localized: "With Sides")
        case .search:
            return ""
        case .distance:
            return isSelected ? getSelectedDistanceFilterString() : String(localized: "Distance")
        case .dietryRestrictions:
            return isSelected ? getSelectedRestrictions() : String(localized: "Restrictions")
        case .beerMatches:
            return isSelected ? getSelectedBeerMatches() : String(localized: "Beers")
        case .price:
            return isSelected ? getSelectedPriceFilterString() : String(localized: "Price")
        case .protein:
            return isSelected ? getSelectedProteins() : String(localized: "Proteins")
        }
    }
    
    private func getSelectedDistanceFilterString() -> String {
        let filter = (selectedFilters.first(where: { $0.burgerFilterId == .distance }) as? DistanceFilter)
       
        return "\(String(localized: "Distance:")) \(Int(filter?.distance ?? 0.0)) \(String(localized: "km"))"
    }
    
    private func getSelectedRestrictions() -> String {
        let restrictions = selectedFilters(for: .dietryRestrictions)
        if restrictions.count > 1 {
            return "\(String(localized: "Restrictions:")) \(restrictions.count) \(String(localized: "selected"))"
        }
        return "\(String(localized: "Restriction:")) \(restrictions.first ?? "")"
    }
    
    private func getSelectedBeerMatches() -> String {
        let beers = selectedFilters(for: .beerMatches)
        if beers.count > 1 {
            return "\(String(localized: "Beers:")) \(beers.count) \(String(localized: "selected"))"
        }
        return "\(String(localized: "Beer:")) \(beers.first ?? "")"
    }
    
    private func getSelectedPriceFilterString() -> String {
        let filter = (selectedFilters.first(where: { $0.burgerFilterId == .price }) as? PriceFilter)
       
        return "\(String(localized: "Max Price:")) \(filter?.maxPrice.formatted(.currency(code: "NZD")) ?? "$0.00")"
    }
    
    private func getSelectedProteins() -> String {
        let proteins = selectedFilters(for: .protein)
        if proteins.count > 1 {
            return "\(String(localized: "Proteins:")) \(proteins.count) \(String(localized: "selected"))"
        }
        return "\(String(localized: "Protein:")) \(proteins.first ?? "")"
    }
    
    
    func addToFavourites(_ burger: BurgerModel) async {
        try? await repository.addFavoriteBurger(burger)
        favourites = await repository.getFavoriteBurgers()
        applyFilters(scrollToTop: false)
    }
    
    func removeFromFavourites(_ burger: BurgerModel) async {
        try? await repository.removeFavoriteBurger(burger)
        favourites = await repository.getFavoriteBurgers()
        applyFilters(scrollToTop: false)
    }
    
    func isFavourite(_ burger: BurgerModel) -> Bool {
        favourites.contains(where: { $0.id == burger.id })
    }
}
