//
//  EventsView.swift
//  WellingtonEvents
//
//  Created by ialbuquerque on 06/01/2025.
//

import SwiftUI
import DesignLibrary
import SwiftUINavigation

enum ViewFocusState: Equatable, Hashable {
    case search
}
struct ListView: View {
    @StateObject var viewModel: ListViewModel = .init()
    @EnvironmentObject var actionsManager: ActionsManager
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @FocusState private var focusState: ViewFocusState?
    private let spaceName = "pullToRefresh"
    private let scrollViewId = "scrollView"
    @State private var safeAreaInsets = EdgeInsets()
    @State private var width: CGFloat = .zero
    
    var body: some View {
        NavigationStack(path: $viewModel.navigationPath) {
            contentView
                .wellingTOnToolbar(favoritesSelected: viewModel.selectedFilterSource().contains(where: { $0 == .favorited }), didTapFavourites: {
                    viewModel.didTapFavouritesFilter(favourites: actionsManager.favourites)
                })
        }
        .disabled(viewModel.isLoading)
        .task {
            await viewModel.setup()
            await actionsManager.setUp(events: viewModel.events)
        }
        .animation(nil, value: viewModel.events)
        .animation(.easeIn, value: viewModel.isLoading)
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
        .sheet(item: $viewModel.route.alert, id: \.self) { style in
            ToastView(model: .init(style: style, shouldDismiss: { [weak viewModel] in viewModel?.resetRoute() }))
                .padding(.top, .medium)
                .presentationBackground(.clear)
                .presentationDetents([.fraction(1/6)])
        }
        .sheet(item: $viewModel.route.filters, id: \.id) { value in
            NavigationView {
                FilterOptionsView(viewModel: .init(
                    filterTye: value.id.rawValue,
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
        .sheet(item: $viewModel.route.webView, id: \.self) { url in
            if let url = URL(string: url) {
                NavigationView {
                    WebView(url: url)
                }
            }
        }
        .onChange(of: scenePhase) { _, newValue in
            switch newValue {
            case .active:
                viewModel.appBecameActive()
            default:
                break
            }
        }
    }
    
    @ViewBuilder
    var lazyStackView: some View {
        LazyVStack(spacing: .medium) {
            cardItemsView
        }
    }
    
    @ViewBuilder
    var lazyGridView: some View {
        LazyVGrid(columns: [.init(), .init()], spacing: 16) {
            cardItemsView
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

extension ListView {
    @ViewBuilder
    var loadingView: some View {
        VStack {
            LottieView(lottieFile: .fountain, loopMode: .loop)
            Text("Loading...")
                .font(.subheadline)
                .foregroundStyle(.fountainBackground)
                .padding(.bottom, .medium)
        }
    }
}

extension ListView {
    @ViewBuilder
    var cardItemsView: some View {
        if viewModel.events.isEmpty {
            HStack {
                Text("No events found")
                    .font(.title3)
                    .foregroundStyle(.text)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, .medium)
        }
        
        ForEach(viewModel.events) { event in
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
                            viewModel.didFavoriteEvent(favourites: actionsManager.favourites)
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

extension ListView {
    @ViewBuilder
    var listView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                PullToRefreshView(coordinateSpaceName: spaceName) {
                    Task {
                        await viewModel.fetchEvents()
                        await actionsManager.setUp(events: viewModel.events)
                    }
                }
                VStack { }
                    .background {
                        Color.clear
                    }
                    .frame(height: 130)
                    .id(scrollViewId)
                
                VStack(alignment: .leading, spacing: .medium) {
                    switch horizontalSizeClass {
                    case .regular:
                        lazyGridView
                    default:
                        lazyStackView
                    }
                }
            }
            .scrollDismissesKeyboard(.immediately)
            .onChange(of: viewModel.scrollToTop) { oldValue, newValue in
                if newValue != oldValue && newValue {
                    proxy.scrollTo(scrollViewId, anchor: .top)
                    viewModel.scrollToTop = false
                }
            }
        }
        .coordinateSpace(name: spaceName)
    }
}

extension ListView {
    @ViewBuilder
    var filtersView: some View {
        ScrollView(.horizontal) {
            HStack {
                
                let selectedSources = viewModel.selectedFilterSource()
                
                let quickDatesSelected = selectedSources.contains(where: { $0 == .quickDate })
                
                let datesSelected = selectedSources.contains(where: { $0 == .date })
                FilterView(
                    isSelected: datesSelected || quickDatesSelected,
                    title: quickDatesSelected ? viewModel.filterTitle(for: .quickDate, isSelected: true) : viewModel.filterTitle(for: .date, isSelected: datesSelected),
                    hasIcon: true) {
                        viewModel.showDateSelector()
                    } clearFilters: {
                        viewModel.clearFilters(for: [.date, .quickDate])
                    }
                let eventsSelected = selectedSources.contains(where: { $0 == .eventType })
                FilterView(
                    isSelected: eventsSelected,
                    title: viewModel.filterTitle(for: .eventType, isSelected: eventsSelected),
                    hasIcon: true) {
                        viewModel.expandFilter(for: viewModel.filters?.eventTypes ?? [], filterType: .eventType)
                    } clearFilters: {
                        viewModel.clearFilters(for: .eventType)
                    }
                switch viewModel.locationManager.authorizationStatus {
                case .authorizedAlways, .authorizedWhenInUse:
                    let distanceSelected = selectedSources.contains(where: { $0 == .distance })
                    FilterView(
                        isSelected: distanceSelected,
                        title: viewModel.filterTitle(for: .distance, isSelected: distanceSelected),
                        hasIcon: true) {
                            viewModel.showDistanceSelector()
                        } clearFilters: {
                            viewModel.clearFilters(for: .distance)
                        }
                default:
                    EmptyView()
                }
              
                let sourceSelected = selectedSources.contains(where: { $0 == .source })
                FilterView(
                    isSelected: sourceSelected,
                    title: viewModel.filterTitle(for: .source, isSelected: sourceSelected),
                    hasIcon: true) {
                        viewModel.expandFilter(for: viewModel.filters?.sources ?? [], filterType: .source)
                    } clearFilters: {
                        viewModel.clearFilters(for: .source)
                    }
                
                let happeningOnceSelected = selectedSources.contains(where: { $0 == .oneOf })
                FilterView(
                    isSelected: happeningOnceSelected,
                    title: viewModel.filterTitle(for: .oneOf, isSelected: happeningOnceSelected),
                    hasIcon: false) {
                        viewModel.didTapOneOfFilter()
                    }
                
                let multipleDatesSelected = selectedSources.contains(where: { $0 == .multipleDates })
                FilterView(
                    isSelected: multipleDatesSelected,
                    title: viewModel.filterTitle(for: .multipleDates, isSelected: multipleDatesSelected),
                    hasIcon: false) {
                        viewModel.didTapMultipleDatesFilter()
                    }
                
            }
            .padding(.vertical, .xxSmall)
            .padding(.horizontal, .xxxSmall)
        }
        .scrollIndicators(.hidden)
    }
}

extension ListView {
    @ViewBuilder
    var contentView: some View {
        ZStack(alignment: .topLeading) {
            if viewModel.isLoading {
                loadingView
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            else {
                listView
                    .simultaneousGesture(TapGesture().onEnded({ _ in
                        focusState = nil
                    }))
            }
            VStack(spacing: .empty) {
                SearchView(searchText: $viewModel.searchText, focusState: $focusState)
                
                filtersView
            }
            .padding(.horizontal, .medium)
            .padding(.top, .medium)
            .background {
                Color(uiColor: .systemBackground)
                    .opacity(colorScheme == .light ? 0.95 : 0.9)
            }
        }
        .background {
            GeometryReader { geometry in
                Color.clear
                    .padding(.horizontal, .medium)
                    .onChange(of: geometry.safeAreaInsets, { _, newValue in
                        safeAreaInsets = newValue
                    })
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
        .overlay(alignment: .top) {
            Color(uiColor: .systemBackground)
                .opacity(colorScheme == .light ? 0.95 : 0.9)
                .frame(height: safeAreaInsets.top)
                .frame(maxWidth: .infinity)
                .ignoresSafeArea()
        }
        .navigationDestination(for: StackDestination.self) { path in
            switch path {
            case .eventDetails(let eventInfo):
                EventDetailsView(viewModel: .init(event: eventInfo, repository: viewModel.repository))
                    .environmentObject(actionsManager)
            }
        }
    }
}
