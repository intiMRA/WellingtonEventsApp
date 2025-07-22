//
//  EventDetailsViewModel.swift
//  WellingtonEvents
//
//  Created by Inti Albuquerque on 18/07/2025.
//

import Foundation
@preconcurrency import MapKit
import CasePaths
import DesignLibrary
import SwiftUI

@MainActor
@Observable
class EventDetailsViewModel: ObservableObject {
    @CasePathable
    enum Destination: Hashable {
        case webView(url: URL)
        case calendar(event: EventInfo)
        case alert(ToastStyle)
    }
    
    static let snapshorSize = CGSize(width: UITraitCollection.current.horizontalSizeClass == .regular ? 800 : 400, height: UITraitCollection.current.horizontalSizeClass == .regular ? 400 : 200)
    static let ratio = snapshorSize.width / snapshorSize.height
    let event: EventInfo
    var image: UIImage?
    var location: CLLocationCoordinate2D?
    var loadingImage: Bool = false
    var route: Destination?
    weak var repository: EventsRepository?
    
    private let options: MKMapSnapshotter.Options = .init()
    
    var eventDate: String? {
        guard let firstDate = event.dates.first else { return nil }
        let dateString: String
        if firstDate.displayAsAllDay {
            dateString = firstDate.asString(with: .eeeddmmmSpaced)
        }
        else {
            dateString = firstDate.asString(with: .eeeddmmmSpacedHMMA)
        }
        if event.dates.count > 1 {
            return String(localized: "\(dateString) + more")
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
        let geocoder = CLGeocoder()
        if let lat = event.location?.lat, let long = event.location?.long {
            location = .init(latitude: lat, longitude: long)
        }
        else {
            do {
                let locationFromAddress = try await geocoder.geocodeAddressString(event.venue)
                location = locationFromAddress.first?.location?.coordinate
            }
            catch {
                print("Error geocoding address: \(error)")
            }
        }
        
        guard let location else {
            return
        }
        self.location = location
        let mapOptions = MKMapSnapshotter.Options()
        mapOptions.region = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapOptions.size = EventDetailsViewModel.snapshorSize
        mapOptions.showsBuildings = true
        mapOptions.pointOfInterestFilter = .includingAll
        let snapshotter = MKMapSnapshotter(options: mapOptions)
        do {
            let snapshot = try await snapshotter.start()
            
            let pinImage = UIImage(resource: .location) // Your pin image
            var finalImage: UIImage?
            let mapImage = snapshot.image
            
            UIGraphicsBeginImageContextWithOptions(mapImage.size, true, mapImage.scale)
            mapImage.draw(at: .zero)
            
            let pointOnImage = snapshot.point(for: location)
            let pinRect = CGRect(
                x: pointOnImage.x - 20,
                y: pointOnImage.y - 43,
                width: 40,
                height: 43
            )
            pinImage.draw(in: pinRect)
            
            finalImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            self.image = finalImage ?? mapImage
        }
        catch {
            print("Error creating snapshot: \(error.localizedDescription)")
        }
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
