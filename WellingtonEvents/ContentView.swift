//
//  ContentView.swift
//  WellingtonEvents
//
//  Created by ialbuquerque on 06/01/2025.
//

import SwiftUI
import NetworkLayerSPM

private struct festivalsUrlBuilder: NetworkLayerURLBuilder {
    func url() -> URL? {
        .init(string: "https://raw.githubusercontent.com/intiMRA/Wellington-Events-Scrapper/refs/heads/main/currentFestivals.json")
    }
}

enum Festivals: String {
    case burgerWellington = "BurgerWellington"
}

@Observable
@MainActor
class ContentViewModel {
    var currentFestivals: [Festivals] = []
    
    func fetchFestivals() async {
        let festvalStrings: [String] = (try? await NetworkLayer.defaultNetworkLayer.request(.init(urlBuilder: festivalsUrlBuilder(), httpMethod: .GET))) ?? []
        currentFestivals = festvalStrings.compactMap { Festivals(rawValue: $0) }
    }
}

struct ContentView: View {
    @StateObject var actionsManager: ActionsManager = .init()
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
                        Text("Bugers")
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
