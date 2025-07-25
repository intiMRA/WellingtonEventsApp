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
    @EnvironmentObject var actionsManager: ActionsManager
    
    init(viewModel: EventDetailsViewModel) {
        self._viewModel = State(wrappedValue: viewModel)
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: .small) {
                imageView
                actionIconsView
                Divider()
                    .foregroundStyle(.text)
                
                infoView
                
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
                        .bold()
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
        .sheet(item: $viewModel.route.calendar) { event in
            NavigationView {
                DatePickerView(viewModel: .init(
                    event: viewModel.event,
                    repository: viewModel.repository,
                    dismiss: { [weak viewModel] style in
                        viewModel?.dissmissCalendar(style)
                    }))
                .environmentObject(actionsManager)
            }
        }
        .sheet(item: $viewModel.route.alert, id: \.self) { style in
            ToastView(model: .init(style: style, shouldDismiss: { [weak viewModel] in viewModel?.resetRoute() }))
                .presentationBackground(.clear)
                .presentationDetents([.fraction(1/6)])
        }
    }
    
    private func openDirectionsInAppleMaps(coordinate: CLLocationCoordinate2D, arress: String) {
        let destinationPlacemark = MKPlacemark(coordinate: coordinate)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        destinationMapItem.name = arress
        
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        
        MKMapItem.openMaps(with: [destinationMapItem], launchOptions: launchOptions)
    }
    
    func saveTocalendar(event: EventInfo) async {
        if event.dates.count > 1 {
            viewModel.route = .calendar(event: event)
        }
        else {
            if await actionsManager.addToCalendar(event: event, date: event.dates.firstValidDate, errorHandler: viewModel.showErrorAlert) {
                viewModel.route = .alert(.success(title: AlertMessages.addCalendarSuccess.title, message: AlertMessages.addCalendarSuccess.message))
            }
        }
    }
}

extension EventDetailsView {
    @ViewBuilder
    var infoView: some View {
        Text(viewModel.event.name)
            .font(.title)
            .foregroundStyle(.text)
            .multilineTextAlignment(.leading)
        VStack(alignment: .leading, spacing: .xxSmall) {
            if viewModel.happeningSoon {
                Text("Happening soon!")
                    .font(.caption)
                    .foregroundStyle(.red)
            }
            if viewModel.happeningNow {
                Text("Happening now!")
                    .font(.subheadline)
                    .foregroundStyle(.red)
            }
            else {
                HStack(alignment: .top) {
                    Text("Date:")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.textSecondary)
                    if let eventDate = viewModel.eventDate {
                        Text(eventDate)
                            .font(.subheadline)
                            .foregroundStyle(.textSecondary)
                            .multilineTextAlignment(.leading)
                    }
                }
            }
            
            if viewModel.multipleDates {
                Text("multiple dates")
                    .font(.caption)
                    .foregroundStyle(.textSecondary)
                    .multilineTextAlignment(.leading)
            }
        }
    }
}

extension EventDetailsView {
    @ViewBuilder
    var imageView: some View {
        ZStack(alignment: .bottomTrailing) {
            imageView(url: viewModel.event.imageUrl ?? "")
            Text(viewModel.event.source)
                .multilineTextAlignment(.leading)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.selectedChipText)
                .padding(.all, .xSmall)
                .background {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.accent)
                        .opacity(0.8)
                        .shadow(color: .shadow.opacity(0.25), radius: 2, x: 1, y: 1)
                }
                .padding(.all, .xSmall)
        }
    }
}

extension EventDetailsView {
    @ViewBuilder
    var actionIconsView: some View {
        let isFavourited = actionsManager.isEventFavourited(id: viewModel.event.id)
        let isInCalendar = actionsManager.isEventInCalendar(id: viewModel.event.id)
        HStack(spacing: .xSmall) {
            Button {
                Task {
                    if isFavourited {
                        await actionsManager.deleteFromFavorites(event: viewModel.event, errorHandler: viewModel.showErrorAlert)
                    }
                    else {
                        await actionsManager.saveToFavorites(event: viewModel.event, errorHandler: viewModel.showErrorAlert)
                    }
                }
            } label: {
                (isFavourited ? Image(.heartFill) : Image(.heart))
                    .resizable()
                    .squareFrame(size: 36)
            }
            
            Button {
                Task {
                    if isInCalendar {
                        if await actionsManager.deleteFromCalendar(event: viewModel.event, errorHandler: viewModel.showErrorAlert) {
                            viewModel.route = .alert(.success(title: AlertMessages.deleteCalendarSuccess.title, message: AlertMessages.deleteCalendarSuccess.message))
                        }
                    }
                    else {
                        await saveTocalendar(event: viewModel.event)
                    }
                }
            } label: {
                (isInCalendar ? Image(.calendarTick) : Image(.calendar))
                    .resizable()
                    .squareFrame(size: 36)
            }
            .foregroundStyle(.text)
            
            
            if let url = URL(string: viewModel.event.url) {
                ShareLink(item: url) {
                    Image(.share)
                        .squareFrame(size: 36)
                }
            }
        }
        .padding(.all, .medium)
    }
}

extension EventDetailsView {
    @ViewBuilder
    var addressView: some View {
        HStack(alignment: .top) {
            Text("Address:")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.textSecondary)
            Text(viewModel.event.venue)
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

extension EventDetailsView {
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
}

extension EventDetailsView {
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
        .frame(maxWidth: .infinity)
        .scaledToFill()
        .roundedShadow()
    }
}
