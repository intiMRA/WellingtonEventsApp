//
//  CLLocationCoordinate2D+Equatable.swift
//  WellingtonEvents
//
//  Created by Inti Albuquerque on 30/07/2025.
//

import Foundation
import CoreLocation

extension CLLocationCoordinate2D: @retroactive Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
