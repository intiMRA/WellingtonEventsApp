//
//  ContentView.swift
//  WellingtonEvents
//
//  Created by ialbuquerque on 06/01/2025.
//

import SwiftUI
import NetworkLayerSPM


enum Festivals: String {
    case burgerWellington = "BurgerWellington"
    case roxy = "RoxyFestival"
}

struct FestivalDetails: Codable {
    let id: String
    let name: String
    let url: String
    let icon: String
}

@Observable
@MainActor
class ContentViewModel {
    var currentFestivals: [Festivals] = []
    var currentFestivalDetails: [FestivalDetails] = []
    
    func fetchFestivals() async {
        let festvalStrings: [String] = (try? await NetworkLayer.defaultNetworkLayer.request(.init(urlBuilder: UrlBuilder.festivals, httpMethod: .GET))) ?? []
        
        currentFestivals = festvalStrings.compactMap { Festivals(rawValue: $0) }
        currentFestivalDetails = (try? await NetworkLayer.defaultNetworkLayer.request(.init(urlBuilder: UrlBuilder.festivalDetails, httpMethod: .GET))) ?? []
    }
    
    func details(for festival: Festivals) -> FestivalDetails? {
        currentFestivalDetails.first(where: { $0.id == festival.rawValue })
    }
}

struct ContentView: View {
    @StateObject var actionsManager: ActionsManager = .init(repository: DefaultEventsRepository())
    @StateObject var festivalsActionsManager: ActionsManager = .init(repository: nil)
    @State var viewModel: ContentViewModel = .init()
    
    var body: some View {
        TabView {
            Tab("Events", image: "events") {
                ListView()
                    .environmentObject(actionsManager)
            }
            Tab("Map", image: "map") {
                MapView()
                    .environmentObject(actionsManager)
            }
            
            ForEach(viewModel.currentFestivals, id: \.self) { festival in
                switch festival {
                case .burgerWellington:
                    Tab("Burger Wellington", image: "burger") {
                        BurgerListView()
                    }
                default:
                    if let details = viewModel.details(for: festival) {
                        Tab(details.name, image: details.icon) {
                            ListView(viewModel: .init(repository: FestivalEventsRepository(fetchUrl: .cutom(details.url))))
                                .environmentObject(festivalsActionsManager)
                        }
                    }
                }
            }
        }
        .task {
            await viewModel.fetchFestivals()
            guard let currentFestival = viewModel.currentFestivals.first, let festivalUrl = viewModel.details(for: currentFestival)?.url else { return }
            festivalsActionsManager.injectRepository(FestivalEventsRepository(fetchUrl: .cutom(festivalUrl)))
        }
    }
}

#Preview {
    ContentView()
}
