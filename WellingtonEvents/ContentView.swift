//
//  ContentView.swift
//  WellingtonEvents
//
//  Created by ialbuquerque on 06/01/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject var actionsManager: ActionsManager = .init()
    
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
        }
    }
}

#Preview {
    ContentView()
}
