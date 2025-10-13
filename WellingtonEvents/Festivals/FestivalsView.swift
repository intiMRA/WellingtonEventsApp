//
//  FestivalsView.swift
//  WellingtonEvents
//
//  Created by Inti Albuquerque on 07/10/2025.
//

import SwiftUI
import DesignLibrary

struct FestivalCellView: View {
    let name: String
    let icon: String
    var body: some View {
        HStack {
            Image(icon)
            Text(name)
                .font(.headline)
                .foregroundStyle(.text)
            Spacer()
            Image(systemName: "chevron.right")
        }
        .frame(maxWidth: .infinity, idealHeight: 44)
    }
}

struct FestivalsView: View {
    @StateObject var festivalsActionsManagers: ActionsManager = .init(repository: nil)
    @State private var viewModel: FestivalsViewModel = .init()
    @EnvironmentObject var router: Navigator
    var body: some View {
            List {
                ForEach(viewModel.currentFestivalDetails, id: \.name) { festival in
                    if festival.name == Festivals.burgerWellington.rawValue {
                        Button {
                            router.navigate(to: .burgers)
                        } label: {
                            FestivalCellView(name: "Burger Wellington", icon: "burger")
                        }
                    }
                    else {
                        Button {
                            let festivalId = "\(festival.id)\(festival.name)"
                            festivalsActionsManagers.injectRepository(FestivalEventsRepository(fetchUrl: .cutom(festival.url), festivalId: festivalId))
                            router.navigate(to: .festivalListing(festivalUrl: festival.url, festivalId: festivalId))
                        } label: {
                            FestivalCellView(name: festival.name, icon: festival.icon)
                        }
                    }
                }
            }
            .listStyle(.plain)
            .task {
                await viewModel.fetchFestivals()
            }
            .navigationDestination(for: Navigator.StackDestination.self) { path in
                switch path {
                case .eventDetails(let eventInfo, let repo):
                    EventDetailsView(viewModel: .init(event: eventInfo, repository: repo))
                        .environmentObject(festivalsActionsManagers)
                case .burgerDetails(let burgerModel, let isFavorite, let didTapFavorite, let finishedDismissEditCalanderView):
                    BurgerDetailsView(
                        viewModel: .init(
                            burgerModel: burgerModel,
                            isFavorite: isFavorite,
                            didTapFavorite: didTapFavorite,
                            finishedDismissEditCalanderView: finishedDismissEditCalanderView
                        )
                    )
                case .burgers:
                    BurgerListView()
                        .environmentObject(router)
                case let .festivalListing(festivalUrl, festivalId):
                    ListView(viewModel: .init(repository: FestivalEventsRepository(fetchUrl: .cutom(festivalUrl), festivalId: festivalId)))
                        .environmentObject(festivalsActionsManagers)
                        .environmentObject(router)
                }
            }
    }
}

#Preview {
    FestivalsView()
}
