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

struct CalendarModel {
    let isInCalendar: Bool
    var addToCalendar: () -> Void
}

struct EventsCardView: View {
    let event: EventInfo
    let FavouriteModel: FavouriteModel
    var calendarModel: CalendarModel?
    var didTapOnCard: (String) -> Void
    
    var body: some View {
        Button {
            didTapOnCard(event.id)
        } label: {
            VStack(alignment: .leading, spacing: .xSmall) {
                ZStack(alignment: .topTrailing) {
                    AsyncImage(url: URL(string: event.imageUrl ?? "")) { phase in
                        switch phase {
                        case .empty:
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.gray)
                                .frame(maxWidth: .infinity)
                                .frame(height: 155)
                                .shadow(color: .shadow.opacity(0.25), radius: 2, x: 1, y: 1)
                        case .success(let image):
                            image
                                .resizable()
                                .frame(maxWidth: .infinity, maxHeight: 250)
                                .scaledToFill()
                                .roundedShadow()
                        case .failure(let error):
                            Image(.noImageAtTime)
                                .resizable()
                                .foregroundStyle(.textSecondary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 155)
                                .scaledToFit()
                                .roundedShadow()
                                .onAppear {
                                    print(error)
                                    print(event.imageUrl ?? "")
                                }
                        @unknown default:
                            Rectangle()
                                .fill(.gray)
                                .frame(maxWidth: .infinity)
                                .frame(height: 155)
                        }
                    }
                    
                    HStack(spacing: .xSmall) {
                        Button {
                            FavouriteModel.didTapFavorites()
                        } label: {
                            (FavouriteModel.isFavourited ? Image(.heartFill) : Image(.heart))
                                .resizable()
                                .squareFrame(size: 36)
                        }
                        
                        if let calendarModel {
                            Button {
                                calendarModel.addToCalendar()
                            } label: {
                                (calendarModel.isInCalendar ? Image(.calendarTick) : Image(.calendar))
                                    .resizable()
                                    .squareFrame(size: 36)
                            }
                            .foregroundStyle(.text)
                        }
                    }
                    .padding(.all, .medium)
                }
                
                Text(event.name)
                    .multilineTextAlignment(.leading)
                    .font(.body.bold())
                    .foregroundStyle(.text)
                
                if event.dates.count > 1 {
                    Text("\(event.displayDate)")
                        .font(.subheadline.bold())
                        .foregroundStyle(.textSecondary)
                }
                else {
                    Text(event.displayDate)
                        .font(.subheadline.bold())
                        .foregroundStyle(.textSecondary)
                }
                
                HStack(alignment: .top) {
                    Text(event.venue)
                        .multilineTextAlignment(.leading)
                        .font(.subheadline)
                        .foregroundStyle(.textSecondary)
                        .padding(.trailing, .xxSmall)
                    
                    Image(systemName: "circle.fill")
                        .renderingMode(.template)
                        .font(.system(size: 8))
                        .foregroundStyle(.textSecondary)
                        .padding(.top, .xxSmall)
                        .padding(.trailing, .xxSmall)
                    
                    Text(event.source)
                        .font(.subheadline)
                        .foregroundStyle(.textSecondary)
                }
                
                Divider()
            }
        }
        .padding(.horizontal, .medium)
    }
}
