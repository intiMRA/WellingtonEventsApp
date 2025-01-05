//
//  EventsView.swift
//  WellingtonEvents
//
//  Created by ialbuquerque on 06/01/2025.
//

import SwiftUI
import DesignLibrary

struct EventsView: View {
    @State var viewModel: EventsViewModel = .init()
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(viewModel.events, id: \.url) { event in
                    Button {
                        if let url = URL(string: event.url), UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        } else {
                            print("Cannot open URL")
                        }
                    } label: {
                        HStack {
                            AsyncImage(url: URL(string: event.imageUrl ?? "")) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                            } placeholder: {
                                Rectangle()
                                    .fill(.gray)
                                    .frame(width: 100, height: 100)
                            }
                            Spacer()
                            VStack(alignment: .leading) {
                                Text(event.name)
                                Text(event.venue)
                                Text(event.date ?? "")
                            }
                            
                        }
                    }
                    .padding(.horizontal, .medium)
                }
            }
        }
        .task {
            await viewModel.fetchEvents()
        }
    }
}
