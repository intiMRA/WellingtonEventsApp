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
    @Published var isBackTap = false
    let repository: BurgerRepositoryProtocol = BurgerRepository()
    
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
            Task { [weak self] in
                try? await Task.sleep(for: .seconds(2))
                self?.isLoading = false
            }
        }
        let response: BurgerResponse? = try? await repository.fetchBurgers()

        burgers = response?.burgers ?? []
        filters = response?.filters
        allBurgers = burgers
        Task { [weak self] in
            guard let self else { return }
            for burger in allBurgers {
                isInCalendar[burger.id] = (try? await CalendarManager.retrieveBurger(burger: burger) != nil) ?? false
            }
        }
    }
    
    func resetRoute() {
        route = nil
    }
}

extension BurgerListViewModel {
    func presentEditCalendar(burgerModel: BurgerModel) {
        Task { [weak self] in
            guard let self else { return }
            let ekEvent = await CalendarManager.ekEvent(for: burgerModel)
            route = .editEvent(burger: burgerModel, ekEvent: ekEvent)
        }
    }
    
    func showErrorAlert(_ title: String? = nil, _ message: String) {
        route = .alert(.error(title: title, message: message))
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
            Task { [weak self] in
                guard let self else { return }
                route = .alert(.success(title: AlertMessages.deleteCalendarSuccess.title, message: AlertMessages.deleteCalendarSuccess.message))
                isInCalendar[burgerModel.id] = false
            }
        @unknown default:
            fatalError("Unknown EKEventEditViewAction")
        }
    }
    
    func refreshCalendarState() {
        Task { [weak self] in
            guard let self else { return }
            for burger in allBurgers {
                isInCalendar[burger.id] = (try? await CalendarManager.retrieveBurger(burger: burger) != nil) ?? false
            }
        }
    }
}
