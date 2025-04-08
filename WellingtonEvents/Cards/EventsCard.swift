//
//  EventsCard.swift
//  WellingtonEvents
//
//  Created by ialbuquerque on 25/02/2025.
//

import Foundation
import SwiftUI
import DesignLibrary

struct FavouriteModel {
    let isFavourited: Bool
    let didTapFavorites: () -> Void
}

struct EventsCardView: View {
    let event: EventInfo
    let FavouriteModel: FavouriteModel
    var addToCalendar: (() -> Void)? = nil
    var didTapOnCard: (String) -> Void
    
    var body: some View {
        Button {
            didTapOnCard(event.id)
        } label: {
            HStack {
                AsyncImage(url: URL(string: event.imageUrl ?? "")) { phase in
                    switch phase {
                    case .empty:
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.gray)
                            .squareFrame(size: 100)
                            .shadow(color: .shadow.opacity(0.25), radius: 2, x: 1, y: 1)
                    case .success(let image):
                        image
                            .resizable()
                            .squareFrame(size: 100)
                            .roundedShadow()
                    case .failure(let error):
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.red)
                            .squareFrame(size: 100)
                            .shadow(color: .shadow.opacity(0.25), radius: 2, x: 1, y: 1)
                            .onAppear {
                                print(error)
                                print(event.imageUrl ?? "")
                            }
                        
                    @unknown default:
                        Rectangle()
                            .fill(.gray)
                            .frame(width: 100, height: 100)
                    }
                }
                
                Spacer()
                VStack(alignment: .leading, spacing: .xxxSmall) {
                    Text(event.name)
                        .multilineTextAlignment(.leading)
                        .font(.body.bold())
                        .foregroundStyle(.text)
                    
                    Text(event.venue)
                        .multilineTextAlignment(.leading)
                        .font(.subheadline)
                        .foregroundStyle(.text)
                    if event.dates.count > 1 {
                        Text("\(event.displayDate ?? "multiple dates") + more")
                            .font(.subheadline)
                            .foregroundStyle(.text)
                    }
                    else {
                        Text(event.displayDate ?? "multiple dates")
                            .font(.subheadline)
                            .foregroundStyle(.text)
                    }
                    HStack {
                        Text("From: \(event.source)")
                            .font(.subheadline)
                            .foregroundStyle(.text)
                        Spacer()
                        Button {
                            FavouriteModel.didTapFavorites()
                        } label: {
                            (FavouriteModel.isFavourited ? Image(.heartFill) : Image(.heart))
                                .resizable()
                                .squareFrame(size: 30)
                        }
                        .padding(.leading, .xxSmall)
                        
                        if let addToCalendar {
                            Button {
                                print("tap calendar")
                                addToCalendar()
                            } label: {
                                Image(systemName: "calendar.badge.plus")
                                    .renderingMode(.template)
                                    .resizable()
                                    .squareFrame(size: 30)
                            }
                            .padding(.leading, .xxSmall)
                            .foregroundStyle(.text)
                        }
                    }
                }
            }
        }
        .padding(.all, .medium)
        .roundedShadow(color: Gradient(colors: [.cardGradient1, .cardGradient2]))
        .padding(.horizontal, .medium)
    }
}
