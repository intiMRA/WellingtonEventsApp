import Foundation
@preconcurrency import MapKit
import UIKit

struct MapSnapshotGenerator {
    static let snapshotSize = CGSize(
        width: UITraitCollection.current.horizontalSizeClass == .regular ? 800 : 400,
        height: UITraitCollection.current.horizontalSizeClass == .regular ? 400 : 200
    )
    static let ratio = snapshotSize.width / snapshotSize.height

    static func generateSnapshot(for location: CLLocationCoordinate2D) async -> UIImage? {
        let mapOptions = MKMapSnapshotter.Options()
        mapOptions.region = MKCoordinateRegion(
            center: location,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        mapOptions.size = snapshotSize
        mapOptions.showsBuildings = true
        mapOptions.pointOfInterestFilter = .includingAll
        let snapshotter = MKMapSnapshotter(options: mapOptions)
        do {
            let snapshot = try await snapshotter.start()
            return drawPin(on: snapshot, at: location)
        } catch {
            print("Error creating snapshot: \(error.localizedDescription)")
            return nil
        }
    }

    private static func drawPin(on snapshot: MKMapSnapshotter.Snapshot, at location: CLLocationCoordinate2D) -> UIImage {
        let pinImage = UIImage(resource: .location)
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

        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return finalImage ?? mapImage
    }
}
