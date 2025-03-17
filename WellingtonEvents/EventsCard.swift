//
//  EventsCard.swift
//  WellingtonEvents
//
//  Created by ialbuquerque on 25/02/2025.
//

import Foundation
import SwiftUI

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
                        Rectangle()
                            .fill(.gray)
                            .frame(width: 100, height: 100)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                    case .failure(let error):
                        Rectangle()
                            .fill(.red)
                            .frame(width: 100, height: 100)
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
                        Text(event.source)
                            .font(.subheadline)
                            .foregroundStyle(.red)
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
                                    .resizable()
                                    .squareFrame(size: 30)
                            }
                            .padding(.leading, .xxSmall)
                        }
                    }
                }
            }
        }
        .padding(.all, .medium)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.cardBackground)
                .shadow(color: .shadow.opacity(0.25), radius: 2, x: 1, y: 1))
        .padding(.horizontal, .medium)
    }
}
