//
//  EventDetailsViewModel.swift
//  WellingtonEvents
//
//  Created by Inti Albuquerque on 18/07/2025.
//

import Foundation
import MapKit

@MainActor
@Observable
class EventDetailsViewModel {
    static let snapshorSize = CGSize(width: 300, height: 200)
    let event: EventInfo
    var image: UIImage?
    private let options: MKMapSnapshotter.Options = .init()
    
    init(event: EventInfo) {
        self.event = event
    }
    
    func generateSnapshot() {
        guard let lat = event.location?.lat, let long = event.location?.long else {
            return
        }
        let mapOptions = MKMapSnapshotter.Options()
        mapOptions.region = MKCoordinateRegion(center: .init(latitude: lat, longitude: long), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapOptions.size = EventDetailsViewModel.snapshorSize
        mapOptions.showsBuildings = true
        mapOptions.pointOfInterestFilter = .includingAll
        let snapshotter = MKMapSnapshotter(options: mapOptions)
        snapshotter.start { snapshot, error in
            guard let snapshot = snapshot, error == nil else {
                print("Snapshot error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            let pinImage = UIImage(systemName: "circle.fill")?.withTintColor(.red) // Your pin image
            var finalImage: UIImage?
            let mapImage = snapshot.image
            
            if let pin = pinImage {
                UIGraphicsBeginImageContextWithOptions(mapImage.size, true, mapImage.scale)
                mapImage.draw(at: .zero)
                
                let pointOnImage = snapshot.point(for: .init(latitude: lat, longitude: long))
                let pinRect = CGRect(
                    x: pointOnImage.x - 5, // Center the pin horizontally
                    y: pointOnImage.y - 10,    // Position pin at the bottom of its image
                    width: 10,
                    height: 10
                )
                pin.draw(in: pinRect)
                
                finalImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
            }
            self.image = finalImage ?? mapImage
        }
    }
    
}
