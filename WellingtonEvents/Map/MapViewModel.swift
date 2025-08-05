//
//  MapViewModel.swift
//  WellingtonEvents
//
//  Created by Inti Albuquerque on 29/07/2025.
//

import Foundation
import MapKit
import CasePaths
import DesignLibrary
import SwiftUI

struct MapEventtModel: Identifiable , Equatable{
    let id: String
    var events: [EventInfo]
    let coordinate: CLLocationCoordinate2D
    
    var title: String {
        events.first?.name ?? ""
    }
    
    var isOneEvent: Bool {
        events.count == 1
    }
}

@MainActor
class MapViewModel: ObservableObject {
    @CasePathable
    enum Destination: Hashable {
        case cards([EventInfo])
        case alert(ToastStyle)
        case calendar(event: EventInfo)
        case filters(for: FilterValues)
        case distance(distance: Double)
        case dateSelector(startDate: Date, endDate: Date, selectedQuickDate: QuickDateType?, id: String)
    }
    
    private static let defaultSpan = MKCoordinateSpan(latitudeDelta: 0.012, longitudeDelta: 0.012)
    static let wellingtonRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -41.2865, longitude: 174.7762),
        span: defaultSpan
    )

    var locationManager: CLLocationManager?
    var allEvents: [MapEventtModel] = []
    let repository: EventsRepository
    
    @Published var searchText: String = ""
    @Published var events: [MapEventtModel] = []
    @Published var route: Destination?
    @Published var navigationPath: [StackDestination] = []
    @Published var selectedFilters: [any FilterObjectProtocol] = [QuickDateFilter(quickDateType: .today)]
    @Published var cameraPosition: MapCameraPosition = .userLocation(fallback: .region(MapViewModel.wellingtonRegion))
    
    var userLocation: MapCameraPosition? {
        var region: MapCameraPosition?
        if let userLocation = locationManager?.location?.coordinate {
            region = .region(MKCoordinateRegion(
                center: userLocation,
                span: Self.defaultSpan
            ))
        }
        return region
    }
    
    var isCenterOnUserLocation: Bool {
        cameraPosition == userLocation
    }

    init(repository: EventsRepository = DefaultEventsRepository()) {
        self.locationManager = CLLocationManager()
        self.repository = repository
    }

    func requestLocationAuthorization() {
        locationManager?.requestWhenInUseAuthorization()
    }
    
    func fetchEvents() async {
        do {
            let response = try await repository.fetchEvents()
            let events = (response?.events.filter { !$0.dates.isEmpty } ?? [])
            
            var locationEvents: [String: MapEventtModel] = [:]
            for event in events {
                if let location = await location(for: event) {
                    let id = "\(location.latitude)\(location.longitude)"
                    
                    if let existingEvent = locationEvents[id] {
                        var existingEvents = existingEvent.events
                        existingEvents.append(event)
                        locationEvents[id] = .init(
                            id: id,
                            events: existingEvents,
                            coordinate: location
                        )
                    }
                    else {
                        locationEvents[id] = .init(
                            id: id,
                            events: [event],
                            coordinate: location
                        )
                    }
                }
            }
            self.events = locationEvents.map { $0.value }
            self.allEvents = self.events
            applyFilters()
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    func location(for event: EventInfo) async -> CLLocationCoordinate2D? {
        guard let coordinates = event.location else {
            return nil
        }
        return .init(latitude: coordinates.lat, longitude: coordinates.long)
    }
    
    func showCards(for mapModel: MapEventtModel) {
        route = .cards(mapModel.events)
    }
    
    func dissmissCalendar(_ style: ToastStyle?) {
        withAnimation {
            guard let style else {
                resetRoute()
                return
            }
            route = .alert(style)
        }
    }
    
    func showErrorAlert(_ title: String? = nil, _ message: String) {
        route = .alert(.error(title: title, message: message))
    }
    
    func didTapOnEvent(_ event: EventInfo) {
        resetRoute()
        navigationPath.append(.eventDetails(event))
    }
    
    func resetRoute() {
        route = nil
    }
    
    func centerMapOnUserLocation() {
        cameraPosition = userLocation ?? .region(Self.wellingtonRegion)
    }
}
