//
//  MapView.swift
//  WellingtonEvents
//
//  Created by Inti Albuquerque on 29/07/2025.
//

import Foundation
import SwiftUI
import MapKit
import DesignLibrary
import SwiftUINavigation

struct MapView: View {
    @StateObject var viewModel: MapViewModel = .init()
    @EnvironmentObject var actionsManager: ActionsManager
    @FocusState private var focusState: ListViewFocusState?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var width: CGFloat = .zero
    @State var dotSize: CGFloat = 10
   
    var body: some View {
        NavigationStack(path: $viewModel.navigationPath) {
            ZStack(alignment: .topLeading) {
                Map(position: $viewModel.cameraPosition) {
                    ForEach(viewModel.events) { model in
                        Annotation((model.isOneEvent && dotSize > 15) ? model.title : "", coordinate: model.coordinate, accessoryAnchor: .bottom) {
                            Button {
                                if !model.isOneEvent {
                                    viewModel.showCards(for: model)
                                }
                                else if let firstEvent = model.events.first {
                                    viewModel.didTapOnEvent(firstEvent)
                                }
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(model.isOneEvent ? .blue : .wellingtonYellow)
                                        .squareFrame(size: dotSize)
                                    if !model.isOneEvent , dotSize > 10 {
                                        Text("\(model.events.count)")
                                            .font(.caption.bold())
                                            .foregroundStyle(.accent)
    
                                    }
                                }
                            }
                        }
                    }
                    if let userLocation = viewModel.locationManager?.location?.coordinate {
                        Annotation("Your Location", coordinate: userLocation) {
                            ZStack {
                                Image(.userLocation)
                                    .resizable()
                                    .frame(width: dotSize * 2, height: dotSize * 2.2)
                            }
                        }
                    }
                }
                .ignoresSafeArea(.keyboard, edges: .bottom)
                .simultaneousGesture(TapGesture().onEnded({ _ in
                    focusState = nil
                }))
                .onMapCameraChange { context in
                    switch context.camera.distance {
                    case ..<500:
                        dotSize = 25
                    case 500..<4000:
                        dotSize = 20
                    case 4000..<5000:
                        dotSize = 15
                    default:
                        dotSize = 10
                    }
                    focusState = nil
                }
                VStack {
                    refineView
                        
                    Spacer()
                    
                    locationButton
                }
                .padding(.all, .medium)
            }
            .task {
                viewModel.requestLocationAuthorization()
                await viewModel.fetchEvents()
            }
            .sheet(item: $viewModel.route.cards, id: \.self) { events in
                cards(for: events)
                    .padding(.all, .medium)
                    .presentationDetents([.fraction(1/3), .fraction(3/6), .medium])
            }
            .sheet(item: $viewModel.route.alert, id: \.self) { style in
                ToastView(model: .init(style: style, shouldDismiss: { [weak viewModel] in viewModel?.resetRoute() }))
                    .padding(.top, .medium)
                    .presentationBackground(.clear)
                    .presentationDetents([.fraction(1/6)])
            }
            .sheet(item: $viewModel.route.calendar) { event in
                NavigationView {
                    DatePickerView(viewModel: .init(
                        event: event,
                        repository: viewModel.repository,
                        dismiss: { [weak viewModel] style in
                            viewModel?.dissmissCalendar(style)
                        }))
                    .environmentObject(actionsManager)
                }
            }
            .sheet(item: $viewModel.route.filters, id: \.id) { value in
                NavigationView {
                    FilterOptionsView(viewModel: .init(
                        filterTye: value.id,
                        possibleFilters: value.items,
                        selectedFilters: viewModel.selectedFilters(for: value.id),
                        finishedFiltering: viewModel.didSelectFilterValues,
                        dismiss: { [weak viewModel] in viewModel?.resetRoute() }))
                }
                .presentationDetents([ .medium, .large])
            }
            .sheet(item: $viewModel.route.dateSelector, id: \.id) { dates in
                NavigationView {
                    DatesFilterView(startDate: dates.startDate,
                                    endDate: dates.endDate,
                                    selectedQuickDate: dates.selectedQuickDate,
                                    dismiss: viewModel.resetRoute,
                                    didSelectDates: viewModel.didSelectDates)
                }
                .presentationDetents([ .medium, .large])
            }
            .sheet(item: $viewModel.route.distance, id: \.self) { distance in
                NavigationView {
                    DistanceFilterView(
                        selectedDistance: distance,
                        dismiss: viewModel.resetRoute,
                        didSelectDistance: viewModel.didSelectDistance)
                }
                .presentationDetents([ .medium, .large])
            }
            .navigationDestination(for: StackDestination.self) { path in
                switch path {
                case .eventDetails(let eventInfo):
                    EventDetailsView(viewModel: .init(event: eventInfo, repository: viewModel.repository))
                        .environmentObject(actionsManager)
                }
            }
            .scrollDismissesKeyboard(.interactively)
        }
    }
}

extension MapView {
    @ViewBuilder
    func cards(for events: [EventInfo]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: .large) {
                ForEach(events) { event in
                    let isFavourited = actionsManager.isEventFavourited(id: event.id)
                    let isInCalendar = actionsManager.isEventInCalendar(id: event.id)
                    EventsCardView(
                        event: event,
                        favouriteModel: .init(
                            isFavourited: isFavourited,
                            didTapFavorites: {
                                Task {
                                    if isFavourited {
                                        await actionsManager.deleteFromFavorites(event: event, errorHandler: viewModel.showErrorAlert)
                                    }
                                    else {
                                        await actionsManager.saveToFavorites(event: event, errorHandler: viewModel.showErrorAlert)
                                    }
                                }
                            }),
                        calendarModel: .init(
                            isInCalendar: isInCalendar,
                            addToCalendar: {
                                Task {
                                    if isInCalendar {
                                        if await actionsManager.deleteFromCalendar(event: event, errorHandler: viewModel.showErrorAlert) {
                                            viewModel.route = .alert(.success(title: AlertMessages.deleteCalendarSuccess.title, message: AlertMessages.deleteCalendarSuccess.message))
                                        }
                                    }
                                    else {
                                        await saveTocalendar(event: event)
                                    }
                                }
                            }),
                        width: width
                    ) {
                        viewModel.didTapOnEvent($0)
                    }
                }
            }
        }
        .background {
            GeometryReader { geometry in
                Color.clear
                    .padding(.horizontal, .medium)
                    .onChange(of: geometry.size) { _, newValue in
                        switch horizontalSizeClass {
                        case .regular:
                            width =  (newValue.width / 2) - 32
                        default:
                            width =  newValue.width - 32
                        }
                    }
            }
        }
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

extension MapView {
    @ViewBuilder
    var filtersView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                let selectedSources = viewModel.selectedFilterSource()
                
                let quickDatesSelected = selectedSources.contains(where: { $0 == .quickDate })
                
                let datesSelected = selectedSources.contains(where: { $0 == .date })
                FilterView(
                    isSelected: datesSelected || quickDatesSelected,
                    title: quickDatesSelected ? viewModel.filterTitle(for: .quickDate, isSelected: true) : viewModel.filterTitle(for: .date, isSelected: datesSelected),
                    hasIcon: true,
                    hasShadow: true) {
                        viewModel.showDateSelector()
                    } clearFilters: {
                        viewModel.clearFilters(for: [.date, .quickDate])
                    }
                
                switch viewModel.locationManager?.authorizationStatus {
                case .authorizedAlways, .authorizedWhenInUse:
                    let distanceSelected = selectedSources.contains(where: { $0 == .distance })
                    FilterView(
                        isSelected: distanceSelected,
                        title: viewModel.filterTitle(for: .distance, isSelected: distanceSelected),
                        hasIcon: true,
                        hasShadow: true) {
                            viewModel.showDistanceSelector()
                        } clearFilters: {
                            viewModel.clearFilters(for: .distance)
                        }
                default:
                    EmptyView()
                }
            }
            .padding(.bottom, .small)
        }
    }
}

extension MapView {
    @ViewBuilder
    var refineView: some View {
        VStack(alignment: .leading, spacing: .empty) {
            SearchView(searchText: $viewModel.searchText, focusState: $focusState, hasCancelButton: false)
            filtersView
        }
        .background(Color.clear)
    }
    
    @ViewBuilder
    var locationButton: some View {
        HStack {
            Spacer()
            Button {
                viewModel.centerMapOnUserLocation()
            } label: {
                Image(systemName: "location.app.fill")
                    .renderingMode(.template)
                    .resizable()
                    .foregroundStyle(viewModel.isCenterOnUserLocation ? .accent : .text, .wellingtonYellow)
                    .squareFrame(size: 44)
                    .animation(.easeIn, value: viewModel.cameraPosition)
                    .shadow(radius: 2, x: 0, y: 2)
            }
        }
    }
}
