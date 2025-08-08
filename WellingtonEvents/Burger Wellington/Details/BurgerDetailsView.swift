//
//  BurgerDetailsView.swift
//  WellingtonEvents
//
//  Created by Inti Albuquerque on 06/08/2025.
//

import SwiftUI
import DesignLibrary
import MapKit

struct BurgerDetailsView: View {
    @State var viewModel: BurgerDetailsViewModel
    
    init(viewModel: BurgerDetailsViewModel) {
        self._viewModel = State(wrappedValue: viewModel)
    }
    
    var body: some View {
        ScrollView {
            content
        }
        .task {
            await viewModel.generateSnapshot()
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
                        ToolbarItem(placement: .automatic) {
                            Button {
                                UIApplication.shared.open(url)
                            }
                            label: {
                                Text("Open In Browser")
                            }
                        }
                    }
            }
        }
        .sheet(item: $viewModel.route.alert, id: \.self) { style in
            ToastView(model: .init(style: style, shouldDismiss: { [weak viewModel] in viewModel?.resetRoute() }))
                .padding(.top, .medium)
                .presentationBackground(.clear)
                .presentationDetents([.fraction(1/6)])
        }
//        .sheet(item: $viewModel.route.editEvent, id: \.eventInfo) { info in
//            EkEventEditView(ekEvent: info.ekEvent, eventInfo: info.eventInfo, dismiss: didDismissEditCalanderView)
//        }
    }
}

extension BurgerDetailsView {
    @ViewBuilder
    var content: some View {
        VStack(alignment: .leading, spacing: .small) {
            imageView(url: viewModel.burgerModel.image)
            
            actionIconsView
            
            Divider()
                .foregroundStyle(.text)
            
            Text(viewModel.burgerModel.name)
                .font(.title)
                .foregroundStyle(.text)
                .multilineTextAlignment(.leading)
            
            dietryIcons
            
            Divider()
                .foregroundStyle(.text)
            
            Text(viewModel.burgerModel.description)
                .font(.body)
                .foregroundStyle(.text)
                .multilineTextAlignment(.leading)
            
            Divider()
                .foregroundStyle(.text)
            
            mapImage
            
            Divider()
                .foregroundStyle(.text)
            
            StyledButtonView(type: .openWebView) {
                viewModel.showWebView()
            }
        }
        .padding(.horizontal, .medium)
        .padding(.bottom, .medium)
    }
}

extension BurgerDetailsView {
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
                    .frame(height: 250)
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
                    .frame(height: 250)
            }
        }
        .frame(maxWidth: .infinity)
        .scaledToFill()
        .roundedShadow()
    }
}

extension BurgerDetailsView {
    @ViewBuilder
    var dietryIcons: some View {
        HStack {
            ForEach (viewModel.burgerModel.dietaryRequirements, id: \.self) { requirement in
                requirement.image
                    .resizable()
                    .squareFrame(size: 36)
            }
        }
    }
}

extension BurgerDetailsView {
    @ViewBuilder
    var actionIconsView: some View {
        let isFavourited = viewModel.isFavorite(viewModel.burgerModel)
        HStack(alignment: .top, spacing: .xSmall) {
            Button {
                withAnimation {
                    viewModel.didTapFavorite(viewModel.burgerModel)
                }
            } label: {
                (isFavourited ? Image(.heartFill) : Image(.heart))
                    .resizable()
                    .squareFrame(size: 36)
            }
            
            if let url = URL(string: viewModel.burgerModel.url) {
                ShareLink(item: url) {
                    Image(.share)
                        .squareFrame(size: 36)
                }
            }
        }
    }
}

extension BurgerDetailsView {
    @ViewBuilder
    var mapImage: some View {
        if let image = viewModel.mapImage, let location = viewModel.location {
            Button {
                openDirectionsInAppleMaps(coordinate: location, adrress: viewModel.burgerModel.venue)
            }
            label: {
                VStack(spacing: .empty) {
                    Image(uiImage: image)
                        .resizable()
                        .frame(maxWidth: .infinity, maxHeight: EventDetailsViewModel.snapshorSize.height)
                        .aspectRatio(EventDetailsViewModel.ratio, contentMode: .fit)
                        .roundedCorner(8, corners: [.topLeft, .topRight])
                    
                    addressView
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
                addressView
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    private func openDirectionsInAppleMaps(coordinate: CLLocationCoordinate2D, adrress: String) {
        let destinationPlacemark = MKPlacemark(coordinate: coordinate)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        destinationMapItem.name = adrress
        
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        
        MKMapItem.openMaps(with: [destinationMapItem], launchOptions: launchOptions)
    }
}

extension BurgerDetailsView {
    @ViewBuilder
    var addressView: some View {
        HStack(alignment: .top) {
            Text("Address:")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.textSecondary)
            Text(viewModel.burgerModel.venue)
                .font(.subheadline)
                .foregroundStyle(.textSecondary)
                .multilineTextAlignment(.leading)
            Spacer()
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
