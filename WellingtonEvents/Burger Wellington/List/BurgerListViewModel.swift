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
import EventKit
import EventKitUI
import DesignLibrary

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
        case price(selectedPrice: Double, min: Double, max: Double)
        case alert(ToastStyle)
        case editEvent(burger: BurgerModel, ekEvent: EKEvent?)
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
    
    @Published var isInCalendar: [String: Bool] = [:]
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
        Task {
            for burger in allBurgers {
                isInCalendar[burger.id] = (try? await CalendarManager.retrieveBurger(burger: burger) != nil) ?? false
            }
        }
    }
    
    func loadFavourites() async {
        favourites = await repository.getFavoriteBurgers()
    }
    
    func resetRoute() {
        route = nil
    }
}

extension BurgerListViewModel {
    func presentEditCalendar(burgerModel: BurgerModel) {
        Task {
            var ekEvent = try? await CalendarManager.retrieveBurger(burger: burgerModel)
            if ekEvent == nil {
                ekEvent = EKEvent(eventStore: CalendarManager.eventStore)
                ekEvent?.title = burgerModel.name
                ekEvent?.notes = burgerModel.description
                ekEvent?.location = burgerModel.venue
                ekEvent?.calendar = CalendarManager.eventStore.defaultCalendarForNewEvents
                ekEvent?.url = URL(string: burgerModel.url)
            }
            route = .editEvent(burger: burgerModel, ekEvent: ekEvent)
        }
    }
    
    func didDismissEditCalanderView(action: EKEventEditViewAction, eventEditModel: EventEditProtocol) {
        guard let burgerModel = eventEditModel as? BurgerModel else {
            return
        }
        switch action {
        case .saved:
            route = .alert(.success(title: AlertMessages.editCalendarSuccess.title, message: AlertMessages.editCalendarSuccess.message))
            isInCalendar[burgerModel.id] = true
        case .canceled:
            resetRoute()
        case .deleted:
            Task {
                route = .alert(.success(title: AlertMessages.deleteCalendarSuccess.title, message: AlertMessages.deleteCalendarSuccess.message))
                isInCalendar[burgerModel.id] = false
            }
        @unknown default:
            fatalError("Unknown EKEventEditViewAction")
        }
    }
    
    func didDismissEditCalanderViewNoAlert(action: EKEventEditViewAction, eventEditModel: EventEditProtocol) {
        guard let burgerModel = eventEditModel as? BurgerModel else {
            return
        }
        switch action {
        case .saved:
            isInCalendar[burgerModel.id] = true
        case .canceled:
            break
        case .deleted:
                isInCalendar[burgerModel.id] = false
        @unknown default:
            fatalError("Unknown EKEventEditViewAction")
        }
    }
}
