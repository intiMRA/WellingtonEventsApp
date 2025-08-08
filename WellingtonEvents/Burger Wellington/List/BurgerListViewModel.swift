//
//  BurgerListViewModel.swift
//  WellingtonEvents
//
//  Created by Inti Albuquerque on 06/08/2025.
//

import Foundation
import CasePaths
import CoreLocation
import Combine

enum BurgerListViewStackDestinations: Hashable {
    case burgerDetails(BurgerModel)
}

struct BurgerFilterValues: Identifiable, Equatable, Hashable {
    var id: BurgerFilterIds
    var items: [String]
}

@MainActor
class BurgerListViewModel: ObservableObject {
    
    @CasePathable
    enum Destination {
        case filters(for: BurgerFilterValues)
        case distance(distance: Double)
        case price(price: Double)
    }
    let locationManager = CLLocationManager()
    
    var oldSearchText: String = ""
    @Published var searchText: String = ""
    var cancellables: Set<AnyCancellable> = .init()
    
    @Published var burgers: [BurgerModel] = []
    @Published var allBurgers: [BurgerModel] = []
    @Published var isLoading: Bool = true
    let repository: BurgerRepositoryProtocol = BurgerRepository()
    @Published var navigationPath: [BurgerListViewStackDestinations] = []
    @Published var favourites: [BurgerModel] = []
    
    var filters: BurgerResponse.Filters?
    @Published var selectedFilters: [any BurgerFilterObjectProtocol] = []
    
    @Published var route: Destination?
    @Published var scrollToTop: Bool = false
    
    init() {
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
    
    func fetchBurgers() async {
        selectedFilters = []
        isLoading = true
        defer {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [unowned self] in
                self.isLoading = false
            }
        }
        let response: BurgerResponse? = try? await repository.fetchBurgers()
        
        burgers = response?.burgers ?? []
        filters = response?.filters
        allBurgers = burgers
    }
    
    func loadFavourites() async {
        favourites = await repository.getFavoriteBurgers()
    }
    
    func resetRoute() {
        route = nil
    }
}
