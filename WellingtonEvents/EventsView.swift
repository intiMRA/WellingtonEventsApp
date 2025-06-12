//
//  EventsView.swift
//  WellingtonEvents
//
//  Created by ialbuquerque on 06/01/2025.
//

import SwiftUI
import DesignLibrary
import SwiftUINavigation

struct EventsView: View {
    @StateObject var viewModel: EventsViewModel = .init()
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.colorScheme) private var colorScheme
    private let spaceName = "pullToRefresh"
    private let scrollViewId = "scrollView"
    @State private var safeAreaInsets = EdgeInsets()
    
    var body: some View {
        NavigationStack {
            contentView
                .simultaneousGesture(TapGesture().onEnded({ _ in
                    hideKeyboard()
                }))
                .simultaneousGesture(DragGesture().onEnded({ value in
                    hideKeyboard()
                }))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        HStack {
                            Spacer(minLength: CommonPadding.medium.rawValue)
                            
                            Image(.bar)
                                .resizable()
                                .renderingMode(.template)
                                .foregroundStyle(.text)
                            
                            Spacer(minLength: CommonPadding.medium.rawValue)
                        }
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        let selectedSources = viewModel.selectedFilterSource()
                        let favoritesSelected = selectedSources.contains(where: { $0 == .favorited })
                        Button {
                            viewModel.didTapFavouritesFilter()
                        } label: {
                            (favoritesSelected ? Image(.heartFill) : Image(.heart))
                                .resizable()
                                .squareFrame(size: 36)
                        }
                    }
                }
        }
        .disabled(viewModel.isLoading)
        .task {
            await viewModel.setup()
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
                        viewModel?.refreshCalendarEvents()
                    }))
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
        .sheet(item: $viewModel.route.alert, id: \.self) { style in
            ToastView(model: .init(style: style, shouldDismiss: { [weak viewModel] in viewModel?.resetRoute() }))
                .presentationBackground(.clear)
                .presentationDetents([.fraction(1/7)])
        }
        .sheet(item: $viewModel.route.dateSelector, id: \.id) { dates in
            NavigationView {
                DatesFilterView(startDate: dates.startDate,
                                endDate: dates.endDate,
                                dismiss: viewModel.resetRoute,
                                didSelectDates: viewModel.didSelectDates)
            }
            .presentationDetents([ .medium, .large])
        }
        .sheet(item: $viewModel.route.quickDateSelector, id: \.id) { value in
            NavigationView {
                QuickDatesFilterView(selectedDate: value.selectedQuickDate,
                                     didSelectDate: viewModel.didSelectQuickDates,
                                     dismiss: viewModel.resetRoute)
            }
            .presentationDetents([ .medium, .large])
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
    var contentView: some View {
        ZStack(alignment: .topLeading) {
            if viewModel.isLoading {
                loadingView
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            else {
                listView
            }
            VStack(spacing: .empty) {
                SearchView(searchText: $viewModel.searchText)
                
                filtersView
            }
            .padding(.horizontal, .medium)
            .padding(.top, .medium)
            .background {
                Color(uiColor: .systemBackground)
                    .opacity(colorScheme == .light ? 0.95 : 0.9)
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .background {
            GeometryReader { geometry in
                Color.clear
                    .onChange(of: geometry.safeAreaInsets, { _, newValue in
                        safeAreaInsets = newValue
                    })
            }
        }
        .overlay(alignment: .top) {
            Color(uiColor: .systemBackground)
                .opacity(colorScheme == .light ? 0.95 : 0.9)
                .frame(height: safeAreaInsets.top)
                .frame(maxWidth: .infinity)
                .ignoresSafeArea()
        }
    }
    
    @ViewBuilder
    var filtersView: some View {
        ScrollView(.horizontal) {
            HStack {
                let selectedSources = viewModel.selectedFilterSource()
                
                let quickDatesSelected = selectedSources.contains(where: { $0 == .quickDate })
                FilterView(
                    isSelected: quickDatesSelected,
                    title: viewModel.filterTitle(for: .quickDate, isSelected: quickDatesSelected),
                    hasIcon: true) {
                        viewModel.showQuickDateSelector()
                    } clearFilters: {
                        viewModel.clearFilters(for: .quickDate)
                    }
                
                let datesSelected = selectedSources.contains(where: { $0 == .date })
                FilterView(
                    isSelected: datesSelected,
                    title: viewModel.filterTitle(for: .date, isSelected: datesSelected),
                    hasIcon: true) {
                        viewModel.showDateSelector()
                    } clearFilters: {
                        viewModel.clearFilters(for: .date)
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
                
                let eventsSelected = selectedSources.contains(where: { $0 == .eventType })
                FilterView(
                    isSelected: eventsSelected,
                    title: viewModel.filterTitle(for: .eventType, isSelected: eventsSelected),
                    hasIcon: true) {
                        viewModel.expandFilter(for: viewModel.filters?.eventTypes ?? [], filterType: .eventType)
                    } clearFilters: {
                        viewModel.clearFilters(for: .eventType)
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
    
    @ViewBuilder
    var listView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                PullToRefreshView(coordinateSpaceName: spaceName) {
                    Task {
                        await viewModel.fetchEvents()
                    }
                }
                VStack {
                    
                }
                .background {
                    Color.clear
                }
                .frame(height: 130)
                .id(scrollViewId)
                
                VStack(alignment: .leading, spacing: .medium) {
                    LazyVStack(spacing: .medium) {
                        ForEach(viewModel.events) { event in
                            let isFavourited = viewModel.isEventFavourited(id: event.id)
                            let isInCalendar = viewModel.isEventInCalendar(id: event.id)
                            EventsCardView(
                                event: event,
                                FavouriteModel: .init(
                                    isFavourited: isFavourited,
                                    didTapFavorites: {
                                        if isFavourited {
                                            viewModel.deleteFromFavorites(event: event)
                                        }
                                        else {
                                            viewModel.saveToFavorites(event: event)
                                        }
                                    }),
                                calendarModel: .init(
                                    isInCalendar: isInCalendar,
                                    addToCalendar: {
                                        if isInCalendar {
                                            viewModel.deleteFromCalendar(event: event)
                                        }
                                        else {
                                            viewModel.saveToCalendar(event: event)
                                        }
                                    })
                            ) {
                                viewModel.didTapOnEvent(with: $0)
                            }
                        }
                    }
                }
            }
            .onChange(of: viewModel.scrollToTop) { _, newValue in
                if newValue {
                    proxy.scrollTo(scrollViewId, anchor: .top)
                    viewModel.scrollToTop = false
                }
            }
        }
        .coordinateSpace(name: spaceName)
    }
    
    @ViewBuilder
    var loadingView: some View {
        LottieView(lottieFile: .fountain, loopMode: .loop)
    }
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
