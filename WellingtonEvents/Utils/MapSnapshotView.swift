import SwiftUI
import MapKit
import DesignLibrary

struct MapSnapshotView: View {
    let image: UIImage?
    let location: CLLocationCoordinate2D?
    let venue: String
    let loadingImage: Bool

    var body: some View {
        if let image, let location {
            Button {
                openDirectionsInAppleMaps(coordinate: location, address: venue)
            }
            label: {
                VStack(spacing: .empty) {
                    Image(uiImage: image)
                        .resizable()
                        .frame(maxWidth: .infinity, maxHeight: MapSnapshotGenerator.snapshotSize.height)
                        .aspectRatio(MapSnapshotGenerator.ratio, contentMode: .fit)
                        .roundedCorner(8, corners: [.topLeft, .topRight])

                    AddressView(venue: venue)
                }
            }
        }
        else {
            VStack(spacing: .empty) {
                Rectangle()
                    .fill(Color.cardBackground)
                    .frame(maxWidth: .infinity, maxHeight: MapSnapshotGenerator.snapshotSize.height)
                    .aspectRatio(MapSnapshotGenerator.ratio, contentMode: .fit)
                    .roundedCorner(8, corners: [.topLeft, .topRight])
                    .if(loadingImage) { view in
                        view
                            .overlay {
                                ProgressView()
                                    .foregroundStyle(.text)
                            }
                    }
                AddressView(venue: venue)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private func openDirectionsInAppleMaps(coordinate: CLLocationCoordinate2D, address: String) {
        let destinationPlacemark = MKPlacemark(coordinate: coordinate)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        destinationMapItem.name = address

        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]

        MKMapItem.openMaps(with: [destinationMapItem], launchOptions: launchOptions)
    }
}
