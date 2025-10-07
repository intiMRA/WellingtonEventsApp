//
//  ContentView.swift
//  WellingtonEvents
//
//  Created by ialbuquerque on 06/01/2025.
//

import SwiftUI
import NetworkLayerSPM
import EventKitUI

@Observable
@MainActor
class ContentViewModel {
    var currentFestivals: [Festivals] = []
    
    func fetchFestivals() async {
        let festvalStrings: [String] = (try? await NetworkLayer.defaultNetworkLayer.request(.init(urlBuilder: UrlBuilder.festivals, httpMethod: .GET))) ?? []
        
        currentFestivals = festvalStrings.compactMap { Festivals(rawValue: $0) }
    }
}

class Navigator: ObservableObject {
    enum StackDestination: Hashable {
        case eventDetails(EventInfo, EventsRepository)
        case burgerDetails(
            model: BurgerModel,
            isFavorite: (BurgerModel) -> Bool,
            didTapFavorite: (BurgerModel) -> Void,
            finishedDismissEditCalanderView: (EKEventEditViewAction, EventEditProtocol) -> Void
        )
        case burgers
        case festivalListing(festivalUrl: String, festivalId: String)
        
        static func == (lhs: Navigator.StackDestination, rhs: Navigator.StackDestination) -> Bool {
            switch (lhs, rhs) {
            case let (.eventDetails(lhsEvent, _), .eventDetails(rhsEvent, _)):
                return lhsEvent == rhsEvent
            case let (.burgerDetails(lhsBurger, _, _, _), .burgerDetails(rhsBurger, _, _, _)):
                return lhsBurger == rhsBurger
            case (.burgers, .burgers):
                return true
            case let (.festivalListing(lhsFestivalUrl, lhsFestivalId), .festivalListing(rhsFestivalUrl, rhsFestivalId)):
                return lhsFestivalUrl == rhsFestivalUrl && lhsFestivalId == rhsFestivalId
            default:
                return false
            }
        }
        
        func hash(into hasher: inout Hasher) {
            switch self {
            case let .eventDetails(event, _):
                hasher.combine("\(type(of: self)):\(event)")
            case let .burgerDetails(burger, _, _, _):
                hasher.combine("\(type(of: self)):\(burger)")
            case .burgers:
                hasher.combine("\(type(of: self)):")
            case let .festivalListing(url, id):
                hasher.combine("\(type(of: self)):\(url),\(id)")
                
            }
        }
    }
    
    @Published var navigationPaths: [StackDestination] = []
    
    func navigate(to destination: StackDestination) {
        navigationPaths.append(destination)
    }
}

struct ContentView: View {
    @StateObject var actionsManager: ActionsManager = .init(repository: DefaultEventsRepository())
    @State var viewModel: ContentViewModel = .init()
    @StateObject var router: Navigator = .init()
    var body: some View {
        TabView {
            Tab("Events", image: "events") {
                NavigationStack(path: $router.navigationPaths) {
                    ListView()
                        .environmentObject(actionsManager)
                        .environmentObject(router)
                        .navigationDestination(for: Navigator.StackDestination.self) { path in
                            switch path {
                            case .eventDetails(let eventInfo, let repo):
                                EventDetailsView(viewModel: .init(event: eventInfo, repository: repo))
                                    .environmentObject(actionsManager)
                            default:
                                EmptyView()
                            }
                        }
                }
            }
            Tab("Map", image: "map") {
                NavigationStack(path: $router.navigationPaths) {
                    MapView()
                        .environmentObject(actionsManager)
                        .environmentObject(router)
                        .navigationDestination(for: Navigator.StackDestination.self) { path in
                            switch path {
                            case .eventDetails(let eventInfo, let repo):
                                EventDetailsView(viewModel: .init(event: eventInfo, repository: repo))
                                    .environmentObject(actionsManager)
                            default:
                                EmptyView()
                            }
                        }
                }
            }
            if !viewModel.currentFestivals.isEmpty {
                Tab("Festivals", image: "events-tab") {
                    NavigationStack(path: $router.navigationPaths) {
                        FestivalsView()
                            .environmentObject(router)
                    }
                }
            }
        }
        .task {
            await viewModel.fetchFestivals()
        }
    }
}

#Preview {
    ContentView()
}
