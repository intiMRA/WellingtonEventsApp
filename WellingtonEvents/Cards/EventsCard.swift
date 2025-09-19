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
    let favouriteModel: FavouriteModel
    var calendarModel: CalendarModel?
    var hasDivider: Bool = true
    @Binding var width: CGFloat
    var didTapOnCard: (EventInfo) -> Void
    
    var body: some View {
        Button {
            didTapOnCard(event)
        } label: {
            VStack(alignment: .leading, spacing: .xSmall) {
                ZStack(alignment: .bottomLeading) {
                    ZStack(alignment: .topTrailing) {
                        imageView
                        
                        if #available(iOS 26.0, *) {
                            actionIconsView26
                        } else {
                            actionIconsView
                        }
                    }
                    Text(event.source)
                        .imageOverlay()
                        .padding(.all, .xSmall)
                }
                
                Text(event.name)
                    .multilineTextAlignment(.leading)
                    .font(.body.bold())
                    .foregroundStyle(.text)
                
                dateAndTypeView
                
                infoView
                if hasDivider {
                    Divider()
                }
            }
        }
        .frame(width: width)
    }
}

extension EventsCardView {
    @ViewBuilder
    var infoView: some View {
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
            
            Text(event.eventType)
                .font(.subheadline)
                .foregroundStyle(.textSecondary)
        }
    }
}

extension EventsCardView {
    @ViewBuilder
    var actionIconsView: some View {
        HStack(spacing: .xSmall) {
            Button {
                favouriteModel.didTapFavorites()
            } label: {
                (favouriteModel.isFavourited ? Image(.heartFill) : Image(.heart))
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
                .foregroundStyle(.clear)
            }
            
            
            if let url = URL(string: event.url) {
                ShareLink(item: url) {
                    Image(.share)
                        .squareFrame(size: 36)
                }
            }
        }
        .padding(.all, .medium)
    }
    
    @available(iOS 26.0, *)
    @ViewBuilder
    var actionIconsView26: some View {
        HStack(spacing: .xSmall) {
            Button {
                favouriteModel.didTapFavorites()
            } label: {
                (favouriteModel.isFavourited ? Image(.heartFillClear) : Image(.heartClear))
                    .resizable()
                    .squareFrame(size: 36)
                    .glassEffect()
            }
            
            if let calendarModel {
                Button {
                    calendarModel.addToCalendar()
                } label: {
                    (calendarModel.isInCalendar ? Image(.calendarTickClear) : Image(.calendarClear))
                        .resizable()
                        .squareFrame(size: 36)
                        .glassEffect()
                }
            }
            
            
            if let url = URL(string: event.url) {
                ShareLink(item: url) {
                    Image(.shareClear)
                        .squareFrame(size: 36)
                        .glassEffect()
                }
            }
        }
        .padding(.all, .medium)
    }
}

extension EventsCardView {
    @ViewBuilder
    var imageView: some View {
        AsyncImage(url: URL(string: event.imageUrl ?? "")) { phase in
            switch phase {
            case .empty:
                RoundedRectangle(cornerRadius: 8)
                    .fill(.gray)
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            case .failure(let error):
                Image(.noImageAtTime)
                    .resizable()
                    .foregroundStyle(.textSecondary)
                    .onAppear {
                        print(error)
                        print(event.imageUrl ?? "")
                    }
            @unknown default:
                Rectangle()
                    .fill(.gray)
            }
        }
        .frame(height: 155)
        .frame(width: width)
        .scaledToFill()
        .roundedShadow()
    }
}

extension EventsCardView {
    @ViewBuilder
    var dateAndTypeView: some View {
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
    }
}
