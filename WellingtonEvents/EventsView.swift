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
                        .navigationTitle( "Events")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button {
                                    Task {
                                        await viewModel.fetchEvents()
                                    }
                                } label: {
                                    Text("Refresh")
                                }
                            }
                        }

                }
                
                filtersView
                    .padding(.horizontal, .medium)
                    .padding(.top, .medium)
                    .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: Text("Search For Event Names"))
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
                DatePickerView(viewModel: .init(event: event, dismiss: { [weak viewModel] style in viewModel?.dissmissCalendar(style) }))
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
    }
    
    @ViewBuilder
    var filtersView: some View {
        ScrollView(.horizontal) {
            HStack {
                let selectedSources = viewModel.selectedFilterSource()
                FilterView(
                    isSelected: selectedSources.contains(where: { $0 == .date }),
                    title: "Dates",
                    hasIcon: true) {
                        viewModel.showDateSelector()
                    } clearFilters: {
                        viewModel.clearFilters(for: .date)
                    }
                FilterView(
                    isSelected: selectedSources.contains(where: { $0 == .source }),
                    title: "Sources",
                    hasIcon: true) {
                        viewModel.expandFilter(for: viewModel.filters?.sources ?? [], filterType: .source)
                    } clearFilters: {
                        viewModel.clearFilters(for: .source)
                    }
                
                FilterView(
                    isSelected: selectedSources.contains(where: { $0 == .eventType }),
                    title: "Event Types",
                    hasIcon: true) {
                        viewModel.expandFilter(for: viewModel.filters?.eventTypes ?? [], filterType: .eventType)
                    } clearFilters: {
                        viewModel.clearFilters(for: .eventType)
                    }
                
                FilterView(
                    isSelected: selectedSources.contains(where: { $0 == .favorited }),
                    title: "Favorited",
                    hasIcon: false) {
                        viewModel.didTapFavouritesFilter()
                    }
                
                FilterView(
                    isSelected: selectedSources.contains(where: { $0 == .oneOf }),
                    title: "Happening once",
                    hasIcon: false) {
                        viewModel.didTapOneOfFilter()
                    }
                
                FilterView(
                    isSelected: selectedSources.contains(where: { $0 == .multipleDates }),
                    title: "Multiple dates",
                    hasIcon: false) {
                        viewModel.didTapMultipleDatesFilter()
                    }
                
            }
            .padding(.vertical, .xxSmall)
            .padding(.horizontal, .xxxSmall)
        }
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
                                })) {
                                    viewModel.saveToCalendar(event: event)
                                } didTapOnCard: {
                                    viewModel.didTapOnEvent(with: $0)
                                }
                    }
                }
            }
        }
        .padding(.top, 78)
    }
}
