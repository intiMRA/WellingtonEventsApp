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
        ScrollView {
            imageView(url: viewModel.event.url)
            Text(viewModel.event.name)
                .font(.headline)
                .padding()
            Text(viewModel.event.description)
                .padding()
            mapImage

        }
        .task {
            viewModel.generateSnapshot()
        }
    }
    
    @ViewBuilder
    func imageView(url: String) -> some View {
        AsyncImage(url: URL(string: url)) { phase in
            switch phase {
            case .empty:
                RoundedRectangle(cornerRadius: 8)
                    .fill(.gray)
            case .success(let image):
                image
                    .resizable()
            case .failure(let error):
                Image(.noImageAtTime)
                    .resizable()
                    .foregroundStyle(.textSecondary)
                    .onAppear {
                        print(error)
                    }
            @unknown default:
                Rectangle()
                    .fill(.gray)
            }
        }
        .frame(height: 155)
        .frame(maxWidth: .infinity)
        .scaledToFill()
        .roundedShadow()
    }
    
    @ViewBuilder
    var mapImage: some View {
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
    
    private func openDirectionsInAppleMaps(coordinate: CLLocationCoordinate2D, arress: String) {
        let destinationPlacemark = MKPlacemark(coordinate: coordinate)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        destinationMapItem.name = arress

        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]

        MKMapItem.openMaps(with: [destinationMapItem], launchOptions: launchOptions)
    }
}
