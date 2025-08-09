//
//  BurgerListView.swift
//  WellingtonEvents
//
//  Created by Inti Albuquerque on 06/08/2025.
//

import SwiftUI
import DesignLibrary

struct BurgerListView: View {
    @StateObject var viewModel: BurgerListViewModel = .init()
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var width: CGFloat = .zero
    @FocusState var focusState: ViewFocusState?
    @State private var safeAreaInsets = EdgeInsets()
    @Environment(\.colorScheme) private var colorScheme
    private let scrollViewId = "scrollViewId"
    private let spaceName = "pullToRefresh"
    var body: some View {
        NavigationStack(path: $viewModel.navigationPath) {
            ZStack(alignment: .topLeading) {
                if viewModel.isLoading {
                    loadingView
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                else {
                    burgerList
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
            .wellingTOnToolbar(favoritesSelected: viewModel.selectedFilterSource().contains(where: { $0 == .favorited }), didTapFavourites: {
                viewModel.didTapFavouritesFilter()
            })
            .overlay(alignment: .top) {
                Color(uiColor: .systemBackground)
                    .opacity(colorScheme == .light ? 0.95 : 0.9)
                    .frame(height: safeAreaInsets.top)
                    .frame(maxWidth: .infinity)
                    .ignoresSafeArea()
            }
            .navigationDestination(for: BurgerListViewStackDestinations.self) { path in
                switch path {
                case .burgerDetails(let model):
                    BurgerDetailsView(viewModel: .init(
                        burgerModel: model, isFavorite: viewModel.isFavourite, didTapFavorite: { [weak viewModel] model in
                            Task {
                                let favourited = viewModel?.isFavourite(model) ?? false
                                if favourited {
                                    await viewModel?.removeFromFavourites(model)
                                } else {
                                    await viewModel?.addToFavourites(model)
                                }
                            }
                        },
                        finishedDismissEditCalanderView: { action, model in
                            viewModel.didDismissEditCalanderViewNoAlert(action: action, eventEditModel: model)
                        }
                    ))
                }
            }
        }
        .task {
            await viewModel.fetchBurgers()
            await viewModel.loadFavourites()
        }
        .disabled(viewModel.isLoading)
        .animation(.easeIn, value: viewModel.isLoading)
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
        .sheet(item: $viewModel.route.distance, id: \.self) { distance in
            NavigationView {
                DistanceFilterView(
                    selectedDistance: distance,
                    dismiss: viewModel.resetRoute,
                    didSelectDistance: viewModel.didSelectDistance)
            }
            .presentationDetents([ .medium, .large])
        }
        .sheet(item: $viewModel.route.price, id: \.selectedPrice) { price in
            NavigationView {
                PriceFilterView(
                    min: price.min,
                    max: price.max,
                    selectedPrice: price.selectedPrice,
                    dismiss: viewModel.resetRoute,
                    didSelectPrice: viewModel.didSelectPrice)
            }
            .presentationDetents([ .medium, .large])
        }
        .sheet(item: $viewModel.route.alert, id: \.self) { style in
            ToastView(model: .init(style: style, shouldDismiss: { [weak viewModel] in viewModel?.resetRoute() }))
                .padding(.top, .medium)
                .presentationBackground(.clear)
                .presentationDetents([.fraction(1/6)])
        }
        .sheet(item: $viewModel.route.editEvent, id: \.burger) { info in
            EkEventEditView(ekEvent: info.ekEvent, eventEditModel: info.burger, dismiss: viewModel.didDismissEditCalanderView)
        }
    }
}

extension BurgerListView {
    @ViewBuilder
    var burgerList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                PullToRefreshView(coordinateSpaceName: spaceName) {
                    Task {
                        await viewModel.fetchBurgers()
                    }
                }
                VStack { }
                    .background {
                        Color.clear
                    }
                    .frame(height: 130)
                    .id(scrollViewId)
                burgerStackView
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

extension BurgerListView {
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

extension BurgerListView {
    @ViewBuilder
    var filtersView: some View {
        ScrollView(.horizontal) {
            HStack {
                let selectedSources = viewModel.selectedFilterSource()
                
                let dietryRestrictionsSelected = selectedSources.contains(where: { $0 == .dietryRestrictions })
                
                FilterView(
                    isSelected: dietryRestrictionsSelected,
                    title: viewModel.filterTitle(for: .dietryRestrictions, isSelected: dietryRestrictionsSelected),
                    hasIcon: true) {
                        viewModel.expandFilter(for: viewModel.filters?.dietaryRequirements ?? [], filterType: .dietryRestrictions)
                    } clearFilters: {
                        viewModel.clearFilters(for: .dietryRestrictions)
                    }
                
                let proteinSelected = selectedSources.contains(where: { $0 == .protein })
                
                FilterView(
                    isSelected: proteinSelected,
                    title: viewModel.filterTitle(for: .protein, isSelected: proteinSelected),
                    hasIcon: true) {
                        viewModel.expandFilter(for: viewModel.filters?.proteins ?? [], filterType: .protein)
                    } clearFilters: {
                        viewModel.clearFilters(for: .protein)
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
                
                let priceSelected = selectedSources.contains(where: { $0 == .price })
                FilterView(
                    isSelected: priceSelected,
                    title: viewModel.filterTitle(for: .price, isSelected: priceSelected),
                    hasIcon: true) {
                        viewModel.showPriceSelector()
                    } clearFilters: {
                        viewModel.clearFilters(for: .price)
                    }
                
                let beerSelected = selectedSources.contains(where: { $0 == .beerMatches })
                FilterView(
                    isSelected: beerSelected,
                    title: viewModel.filterTitle(for: .beerMatches, isSelected: beerSelected),
                    hasIcon: true) {
                        viewModel.expandFilter(for: viewModel.filters?.beerMatch ?? [], filterType: .beerMatches)
                    } clearFilters: {
                        viewModel.clearFilters(for: .beerMatches)
                    }
                
                let sidesIncludedSelected = selectedSources.contains(where: { $0 == .sidesIncluded })
                FilterView(
                    isSelected: sidesIncludedSelected,
                    title: viewModel.filterTitle(for: .sidesIncluded, isSelected: sidesIncludedSelected),
                    hasIcon: false) {
                        viewModel.didTapSidesFilter()
                    }
            }
            .padding(.vertical, .xxSmall)
            .padding(.horizontal, .xxxSmall)
        }
        .scrollIndicators(.hidden)
    }
}

extension BurgerListView {
    @ViewBuilder
    var burgerStackView: some View {
        LazyVStack {
            ForEach(viewModel.burgers) { model in
                let isFavorited = viewModel.isFavourite(model)
                BurgerCardView(
                    favouriteModel: .init(isFavourited: isFavorited, didTapFavorites: {
                        Task {
                            if isFavorited {
                                await viewModel.removeFromFavourites(model)
                            } else {
                                await viewModel.addToFavourites(model)
                            }
                        }
                    }),
                    calendarModel: .init(
                        isInCalendar: viewModel.isInCalendar[model.id] ?? false,
                        addToCalendar: {
                            viewModel.presentEditCalendar(burgerModel: model)
                        }),
                    model: model,
                    width: width) { model in
                        viewModel.navigationPath.append(.burgerDetails(model))
                    }
            }
        }
    }
}
