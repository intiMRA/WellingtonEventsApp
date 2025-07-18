//
//  EventDetailsView.swift
//  WellingtonEvents
//
//  Created by Inti Albuquerque on 18/07/2025.
//

import Foundation
import SwiftUI
import MapKit
import DesignLibrary

struct EventDetailsView: View {
    @State var viewModel: EventDetailsViewModel
    
    init(viewModel: EventDetailsViewModel) {
        self._viewModel = State(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack {
            if let image = viewModel.image, let location = viewModel.event.location {
                Button {
                    openDirectionsInAppleMaps(coordinate: .init(latitude: location.lat, longitude: location.long), arress: viewModel.event.venue)
                }
                label: {
                    Image(uiImage: image)
                        .resizable()
                        .frame(width: EventDetailsViewModel.snapshorSize.width, height: EventDetailsViewModel.snapshorSize.height)
                        .roundedShadow()
                }
            }
            else {
                Rectangle()
                    .fill(Color.gray)
                    .frame(width: EventDetailsViewModel.snapshorSize.width, height: EventDetailsViewModel.snapshorSize.height)
                    .roundedShadow()
            }
        }
        .task {
            viewModel.generateSnapshot()
        }
    }
    
    private func openDirectionsInAppleMaps(coordinate: CLLocationCoordinate2D, arress: String) {
        let destinationPlacemark = MKPlacemark(coordinate: coordinate)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        destinationMapItem.name = arress

        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]

        MKMapItem.openMaps(with: [destinationMapItem], launchOptions: launchOptions)
    }
}
