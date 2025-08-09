//
//  BurgerCardView.swift
//  WellingtonEvents
//
//  Created by Inti Albuquerque on 06/08/2025.
//

import SwiftUI
import DesignLibrary

struct BurgerCardView: View {
    let favouriteModel: FavouriteModel
    var calendarModel: CalendarModel?
    let model: BurgerModel
    let width: CGFloat
    let didTap: (BurgerModel) -> Void
    var body: some View {
        Button {
            didTap(model)
        } label: {
            VStack(alignment: .leading, spacing: .xSmall) {
                ZStack(alignment: .bottomLeading) {
                    ZStack(alignment: .topTrailing) {
                        imageView
                        HStack {
                            Spacer()
                            actionIconsView
                        }
                        .padding(.all, .medium)
                    }
                    HStack {
                        Text("\(model.price.formatted(.currency(code: "NZD")))\(model.sidesIncluded ? String(localized: " + sides") : "")")
                            .imageOverlay()
                            .padding(.all, .xSmall)
                    }
                }
                
                Text(model.name)
                    .multilineTextAlignment(.leading)
                    .font(.body.bold())
                    .foregroundStyle(.text)
                
                if !model.dietaryRequirements.isEmpty {
                    Text("Avaliable Dietary Options:")
                        .multilineTextAlignment(.leading)
                        .font(.caption.bold())
                        .foregroundStyle(.textSecondary)
                    dietryIcons
                }
                
                Text(model.venue)
                    .multilineTextAlignment(.leading)
                    .font(.subheadline.bold())
                    .foregroundStyle(.textSecondary)
                HStack(spacing: .xSmall) {
                    Text("Protein:")
                        .multilineTextAlignment(.leading)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.textSecondary)
                    
                    Text(model.mainProtein)
                        .multilineTextAlignment(.leading)
                        .font(.subheadline)
                        .foregroundStyle(.textSecondary)
                    Spacer()
                }
                Divider()
            }
        }
        .frame(width: width)
    }
}

extension BurgerCardView {
    @ViewBuilder
    var imageView: some View {
        AsyncImage(url: URL(string: model.image)) { phase in
            switch phase {
            case .empty:
                RoundedRectangle(cornerRadius: 8)
                    .fill(.gray)
            case .success(let image):
                image
                    .resizable()
            case .failure(let error):
                Image(.noImageAtTime)
                    .resizable()
                    .foregroundStyle(.textSecondary)
                    .onAppear {
                        print(error)
                        print(model.image)
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

extension BurgerCardView {
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
                    VStack {
                        (calendarModel.isInCalendar ? Image(.calendarTick) : Image(.calendar))
                            .resizable()
                            .squareFrame(size: 36)
                        if calendarModel.isInCalendar {
                            Text("Edit")
                                .font(.caption)
                                .foregroundStyle(.accent)
                        }
                    }
                }
                .foregroundStyle(.text)
            }
            
            if let url = URL(string: model.url) {
                ShareLink(item: url) {
                    Image(.share)
                        .squareFrame(size: 36)
                }
            }
        }
    }
}

extension BurgerCardView {
    @ViewBuilder
    var dietryIcons: some View {
        HStack {
            ForEach (model.dietaryRequirements, id: \.self) { requirement in
                requirement.image
                    .resizable()
                    .squareFrame(size: 36)
            }
        }
    }
}
