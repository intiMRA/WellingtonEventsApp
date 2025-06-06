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
    var body: some View {
        NavigationStack {
            ZStack(alignment: .topLeading) {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                else {
                    listView
                        .simultaneousGesture(TapGesture().onEnded({ _ in
                            hideKeyboard()
                        }))
                        .simultaneousGesture(DragGesture().onEnded({ _ in
                            hideKeyboard()
                        }))
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .topBarLeading) {
                                HStack {
                                    Spacer(minLength: 16)
                                    
                                    Image(.bar)
                                        .resizable()
                                        .renderingMode(.template)
                                        .foregroundStyle(.text)
                                    
                                    Spacer(minLength: 16)
                                }
                            }
                        }
                        .refreshable {
                            await viewModel.fetchEvents()
                        }
                }
                VStack {
                    SearchView(searchText: $viewModel.searchText)
                    
                    filtersView
                }
                .padding(.horizontal, .medium)
                .padding(.top, .xLarge)
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
                
                let favoritesSelected = selectedSources.contains(where: { $0 == .favorited })
                FilterView(
                    isSelected: favoritesSelected,
                    title: viewModel.filterTitle(for: .favorited, isSelected: favoritesSelected),
                    hasIcon: false) {
                        viewModel.didTapFavouritesFilter()
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
        ScrollView {
            VStack(alignment: .leading, spacing: .medium) {
                Text("Events")
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .padding(.horizontal, .medium)
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
        .padding(.top, 150)
    }
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
