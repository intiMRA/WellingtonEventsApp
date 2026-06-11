//
//  BurgerDetailsViewModel.swift
//  WellingtonEvents
//
//  Created by Inti Albuquerque on 07/08/2025.
//

import Foundation
import CoreLocation
import CasePaths
import DesignLibrary
import EventKit
import EventKitUI

@Observable
@MainActor
class BurgerDetailsViewModel {
    
    @CasePathable
    enum Destination: Hashable {
        case webView(url: URL)
        case alert(ToastStyle)
        case editEvent(burger: BurgerModel, ekEvent: EKEvent?)
    }
    
    var mapImage: UIImage?
    var location: CLLocationCoordinate2D?
    var loadingImage: Bool = false
    
    var route: Destination?

    let burgerModel: BurgerModel
    let repository: BurgerRepositoryProtocol = BurgerRepository()

    var isInCalendar: Bool = false

    init(burgerModel: BurgerModel) {
        self.burgerModel = burgerModel
        Task { [weak self] in
            guard let self else { return }
            isInCalendar = (try? await CalendarManager.retrieveBurger(burger: burgerModel)) != nil
        }
    }
    
    func generateSnapshot() async {
        loadingImage = true
        defer {
            loadingImage = false
        }
        let location = CLLocationCoordinate2D(
            latitude: burgerModel.coordinates.lat,
            longitude: burgerModel.coordinates.long
        )
        self.location = location
        self.mapImage = await MapSnapshotGenerator.generateSnapshot(for: location)
    }
    
    func showWebView() {
        guard let url = URL(string: burgerModel.url) else { return }
        route = .webView(url: url)
    }
    
    func resetRoute() {
        route = nil
    }
    
    func showErrorAlert(_ title: String? = nil, _ message: String) {
        route = .alert(.error(title: title, message: message))
    }
}

extension BurgerDetailsViewModel {
    func presentEditCalendar() {
        Task { [weak self] in
            guard let self else { return }
            let ekEvent = await CalendarManager.ekEvent(for: burgerModel)
            route = .editEvent(burger: burgerModel, ekEvent: ekEvent)
        }
    }
    
    func didDismissEditCalanderView(action: EKEventEditViewAction, eventEditModel: EventEditProtocol) {
        switch action {
        case .saved:
            route = .alert(.success(title: AlertMessages.editCalendarSuccess.title, message: AlertMessages.editCalendarSuccess.message))
            isInCalendar = true
        case .canceled:
            resetRoute()
        case .deleted:
            isInCalendar = false
            route = .alert(.success(title: AlertMessages.deleteCalendarSuccess.title, message: AlertMessages.deleteCalendarSuccess.message))
        @unknown default:
            fatalError("Unknown EKEventEditViewAction")
        }
    }
}
