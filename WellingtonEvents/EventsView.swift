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
                }
                
                filtersView
                    .padding(.horizontal, .medium)
                    .padding(.top, .medium)
                    .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: Text("Search For Event Names"))
            }
        }
        .task {
            await viewModel.setup()
        }
        .animation(nil, value: viewModel.events)
        .animation(.easeIn, value: viewModel.isLoading)
        .sheet(item: $viewModel.route.calendar) { event in
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(viewModel.datesByMonth(dates: event.dates)) { month in
                        Text(month.month)
                            .font(.headline)
                            .foregroundStyle(.text)
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 4) {
                            ForEach(month.dates, id: \.self) { date in
                                Button {
                                    viewModel.addToCalendar(event: event, date: date)
                                    viewModel.route = nil
                                } label: {
                                    VStack {
                                        Text(date.asString(with: .dd))
                                            .lineLimit(1)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .background {
                                        RoundedRectangle(cornerRadius: 2)
                                            .fill(Color.gray.opacity(0.7))
                                            .frame(width: 44, height: 44)
                                    }
                                }
                                .frame(width: 44, height: 44)
                            }
                        }
                    }
                }
                .padding(.horizontal, .medium)
            }
        }
        .sheet(item: $viewModel.route.filters, id: \.self) { value in
            NavigationView {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))]) {
                        ForEach(value.items, id: \.self) { filter in
                            Button {
                                viewModel.didSelectFilter(filter, filterType: value.filterType)
                            } label: {
                                VStack {
                                    Text(filter)
                                        .lineLimit(1)
                                        .font(.headline)
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .foregroundStyle(.text)
                        }
                    }
                }
                .navigationTitle("Select A Filter")
                .navigationBarTitleDisplayMode(.inline)
            }
            .presentationDetents([ .medium, .large])
        }
    }
    
    @ViewBuilder
    var filtersView: some View {
        ScrollView(.horizontal) {
            HStack {
                let selectedSource = viewModel.selectedFilterSource()
                Button {
                    viewModel.expandFilter(for: viewModel.filters?.sources ?? [], filterType: .sources)
                } label: {
                    if selectedSource == .sources {
                        HStack {
                            Text("Sources")
                                .font(.headline)
                            Button {
                                viewModel.clearFilters()
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                            }
                        }
                    }
                    else {
                        Text("Sources \(Image(systemName: "chevron.down"))")
                            .font(.headline)
                    }
                }
                .foregroundStyle(.text)
                .padding(.all, .xSmall)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.cardBackground)
                        .shadow(color: .shadow.opacity(0.25), radius: 2, x: 1, y: 1))
                
                Button {
                    viewModel.expandFilter(for: viewModel.filters?.eventTypes ?? [], filterType: .eventTypes)
                } label: {
                    if selectedSource == .eventTypes {
                        HStack {
                            Text("Event Types")
                                .font(.headline)
                            Button {
                                viewModel.clearFilters()
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                            }
                        }
                    }
                    else {
                        Text("Event Types \(Image(systemName: "chevron.down"))")
                            .font(.headline)
                    }
                }
                .foregroundStyle(.text)
                .padding(.all, .xSmall)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.cardBackground)
                        .shadow(color: .shadow.opacity(0.25), radius: 2, x: 1, y: 1))
            }
            .padding(.vertical, .xxSmall)
        }
    }
    
    @ViewBuilder
    var listView: some View {
        ScrollView {
            if !viewModel.eventsWithNoDates.isEmpty {
                Button {
                    viewModel.noDateIsExpanded.toggle()
                } label: {
                    HStack {
                        Text("Events With No Date \(viewModel.noDateIsExpanded ? Image(systemName: "chevron.down") : Image(systemName: "chevron.right"))")
                            .font(.headline)
                        Spacer()
                    }
                    .padding(.bottom, .medium)
                }
                .foregroundStyle(.primary)
                .padding(.top, 78)
                .padding(.horizontal, .medium)
                VStack(alignment: .leading) {
                    if viewModel.noDateIsExpanded {
                        LazyVStack(spacing: .medium) {
                            ForEach(viewModel.eventsWithNoDates) { event in
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
                                            viewModel.didTapOnEvent(with: $0)
                                        }
                                        .padding(.bottom, .medium)
                            }
                        }
                    }
                    
                }
            }
            
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
        .padding(.top, 0)
        .refreshable {
            await viewModel.fetchEvents()
        }
        .animation(.default, value: viewModel.noDateIsExpanded)
    }
}
