//
//  EventDetailsViewModel.swift
//  WellingtonEvents
//
//  Created by Inti Albuquerque on 18/07/2025.
//

import Foundation
import CoreLocation
import CasePaths
import DesignLibrary
import SwiftUI
import EventKit

@MainActor
@Observable
class EventDetailsViewModel: ObservableObject {
    
    @CasePathable
    enum Destination: Hashable {
        case webView(url: URL)
        case calendar(event: EventInfo)
        case alert(ToastStyle)
        case editEvent(eventInfo: EventInfo, ekEvent: EKEvent)
    }
    
    let event: EventInfo
    var image: UIImage?
    var location: CLLocationCoordinate2D?
    var loadingImage: Bool = false
    var route: Destination?
    weak var repository: EventsRepository?

    var happeningSoon: Bool {
        event.dates.firstValidDate?.happeningSoon ?? false
    }
    
    var happeningNow: Bool {
        event.dates.firstValidDate?.happeningNow ?? false
    }
    
    var multipleDates: Bool {
        event.dates.count > 1
    }
    
    var eventDate: String? {
        guard let firstDate = event.dates.firstValidDate else { return nil }
        let dateString: String
        if firstDate.displayAsAllDay {
            dateString = firstDate.asString(with: .eeeddmmmSpaced)
        }
        else {
            dateString = firstDate.asString(with: .eeeddmmmSpacedHMMA)
        }
        return dateString
    }
    
    init(event: EventInfo, repository: EventsRepository?) {
        self.event = event
        self.repository = repository
    }
    
    func generateSnapshot() async {
        loadingImage = true
        defer {
            loadingImage = false
        }
        var location: CLLocationCoordinate2D?
        if let lat = event.location?.lat, let long = event.location?.long {
            location = .init(latitude: lat, longitude: long)
        } else {
            let geocoder = CLGeocoder()
            do {
                let locationFromAddress = try await geocoder.geocodeAddressString(event.venue)
                location = locationFromAddress.first?.location?.coordinate
            } catch {
                print("Error geocoding address: \(error)")
            }
        }

        guard let location else {
            return
        }
        self.location = location
        self.image = await MapSnapshotGenerator.generateSnapshot(for: location)
    }
    
    func showWebView() {
        guard let url = URL(string: event.url) else { return }
        route = .webView(url: url)
    }
    
    func resetRoute() {
        route = nil
    }
    
    func showErrorAlert(_ title: String? = nil, _ message: String) {
        route = .alert(.error(title: title, message: message))
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
}
