//
//  LocationFilter.swift
//  WellingtonEvents
//
//  Created by Inti Albuquerque on 29/07/2025.
//

import Foundation
import CoreLocation
import SwiftUI

enum Distances: Equatable, CaseIterable, Hashable {
    
    case one
    case two
    case five
    case ten
    case fifteen
    case twenty
    case fifty
    case hundred
    case twoHundred
    
    var name: String {
        "\(self.value)km"
    }
    
    var value: Double {
        switch self {
        case .one:
            return 1
        case .two:
            return 2
        case .five:
            return 5
        case .ten:
            return 10
        case .fifteen:
            return 15
        case .twenty:
            return 20
        case .fifty:
            return 50
        case .hundred:
            return 100
        case .twoHundred:
            return 200
        }
    }
    @MainActor
    static var lazyGrid: [GridItem] = {
        [
            GridItem(.flexible(minimum: 50, maximum: .infinity), alignment: .leading),
            GridItem(.flexible(minimum: 50, maximum: .infinity), alignment: .trailing),
            GridItem(.flexible(minimum: 50, maximum: .infinity), alignment: .trailing)
        ]
    }()
}

struct DistanceFilter: FilterObjectProtocol {
    var id: FilterIds = .distance
    var distance: Double
    let locationManager = CLLocationManager()
    
    func execute(event: EventInfo, events: inout [EventInfo]) {
        guard let location = event.location else {
            events.removeAll(where: { $0.id == event.id })
            return
        }
        if !withInRange(coordinate: .init(latitude: location.lat, longitude: location.long), radiusInKm: distance) {
            events.removeAll(where: { $0.id == event.id })
        }
    }

    func withInRange(coordinate: CLLocation, radiusInKm: Double) -> Bool {
        guard let location = locationManager.location else {
            return false
        }
        let distanceInMeters = location.distance(from: coordinate)
        let radiusInMeters = radiusInKm * 1000
        return distanceInMeters <= radiusInMeters
    }
}
