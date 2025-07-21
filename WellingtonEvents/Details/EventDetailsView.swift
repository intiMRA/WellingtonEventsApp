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
import SwiftUINavigation

struct EventDetailsView: View {
    @State var viewModel: EventDetailsViewModel
    
    init(viewModel: EventDetailsViewModel) {
        self._viewModel = State(wrappedValue: viewModel)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .small) {
                imageView(url: viewModel.event.imageUrl ?? "")
                Divider()
                    .foregroundStyle(.text)
                
                Text(viewModel.event.name)
                    .font(.title)
                    .foregroundStyle(.text)
                    .multilineTextAlignment(.leading)
                
                HStack(alignment: .top) {
                    Text("Date:")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.textSecondary)
                    
                    Text(viewModel.event.displayDate)
                        .font(.subheadline)
                        .foregroundStyle(.textSecondary)
                        .multilineTextAlignment(.leading)
                }
                Divider()
                    .foregroundStyle(.text)
                
                Text(viewModel.event.description)
                    .foregroundStyle(.text)
                    .multilineTextAlignment(.leading)
                
                Divider()
                    .foregroundStyle(.text)
                mapImage
            }
        }
        .padding(.horizontal, .medium)
        .task {
            await viewModel.generateSnapshot()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.showWebView()
                }
                label: {
                    Text("View Event")
                }
            }
        }
        .sheet(item: $viewModel.route.webView, id: \.self) { url in
            NavigationView {
                WebView(url: url)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button {
                                viewModel.resetRoute()
                            }
                            label: {
                                Text("Close")
                            }
                        }
                    }
            }
        }
    }
    
    @ViewBuilder
    func imageView(url: String) -> some View {
        AsyncImage(url: URL(string: url)) { phase in
            switch phase {
            case .empty:
                RoundedRectangle(cornerRadius: 8)
                    .fill(.gray)
                    .overlay {
                        ProgressView()
                            .foregroundStyle(.text)
                    }
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
        if let image = viewModel.image, let location = viewModel.location {
            Button {
                openDirectionsInAppleMaps(coordinate: location, arress: viewModel.event.venue)
            }
            label: {
                VStack(spacing: .empty) {
                    Image(uiImage: image)
                        .resizable()
                        .frame(maxWidth: .infinity, maxHeight: EventDetailsViewModel.snapshorSize.height)
                        .aspectRatio(EventDetailsViewModel.ratio, contentMode: .fit)
                        .roundedCorner(8, corners: [.topLeft, .topRight])
                    
                    HStack(alignment: .top) {
                        Text("Address:")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.textSecondary)
                        Text(viewModel.event.venue)
                            .font(.subheadline)
                            .foregroundStyle(.textSecondary)
                            .multilineTextAlignment(.leading)
                    }
                    .padding(.all, .small)
                    .frame(maxWidth: .infinity)
                    .background {
                        Rectangle()
                            .fill(.cardBackground)
                            .roundedCorner(8, corners: [.bottomLeft, .bottomRight])
                    }
                }
            }
        }
        else {
            VStack(spacing: .empty) {
                Rectangle()
                    .fill(Color.cardBackground)
                    .frame(maxWidth: .infinity, maxHeight: EventDetailsViewModel.snapshorSize.height)
                    .aspectRatio(EventDetailsViewModel.ratio, contentMode: .fit)
                    .roundedShadow()
                    .if(viewModel.loadingImage) { view in
                        view
                            .overlay {
                                ProgressView()
                                    .foregroundStyle(.text)
                            }
                    }
                HStack(alignment: .top) {
                    Text("Address:")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.textSecondary)
                    Text(viewModel.event.venue)
                        .font(.subheadline)
                        .foregroundStyle(.textSecondary)
                        .multilineTextAlignment(.leading)
                }
                .padding(.all, .small)
                .frame(maxWidth: .infinity)
                .background {
                    Rectangle()
                        .fill(.cardBackground)
                        .roundedCorner(8, corners: [.bottomLeft, .bottomRight])
                }
                
            }
            .frame(maxWidth: .infinity)
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
