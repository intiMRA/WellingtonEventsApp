//
//  BurgerDetailsView.swift
//  WellingtonEvents
//
//  Created by Inti Albuquerque on 06/08/2025.
//

import SwiftUI
import DesignLibrary

struct BurgerDetailsView: View {
    @State var viewModel: BurgerDetailsViewModel
    @EnvironmentObject var burgerActionsManager: BurgerActionsManager

    init(viewModel: BurgerDetailsViewModel) {
        self._viewModel = State(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            content
            switch viewModel.route {
            case .alert(let toastStyle):
                ToastView(model: .init(style: toastStyle, shouldDismiss: { [weak viewModel] in viewModel?.resetRoute() }))
            default:
                EmptyView()
            }
        }
        .task {
            await viewModel.generateSnapshot()
        }
        .sheet(item: $viewModel.route.webView, id: \.self) { url in
            NavigationView {
                WebView(url: url)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button {
                                viewModel.resetRoute()
                            }
                            label: {
                                Text("Close")
                            }
                        }
                        ToolbarItem(placement: .automatic) {
                            Button {
                                UIApplication.shared.open(url)
                            }
                            label: {
                                Text("Open In Browser")
                            }
                        }
                    }
            }
        }
        .sheet(item: $viewModel.route.editEvent, id: \.burger) { info in
            EkEventEditView(ekEvent: info.ekEvent, eventEditModel: info.burger, dismiss: viewModel.didDismissEditCalanderView)
        }
    }
}

extension BurgerDetailsView {
    @ViewBuilder
    var imageOverlay: some View {
        HStack(alignment: .top) {
            Text("\(viewModel.burgerModel.price.formatted(.currency(code: "NZD")))\(viewModel.burgerModel.sidesIncluded ? String(localized: " with sides") : "")")
                .imageOverlay()
            
            Spacer()
            if let beerPrice = viewModel.burgerModel.beerMatchPrice {
                Text(String(localized: "Add beer for \((beerPrice - viewModel.burgerModel.price).formatted(.currency(code: "NZD")))"))
                    .imageOverlay()
            }
        }
        .padding(.all, .xSmall)
    }
}
extension BurgerDetailsView {
    @ViewBuilder
    var content: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: .small) {
                ZStack(alignment: .bottomLeading) {
                    DetailImageView(url: viewModel.burgerModel.image)
                    imageOverlay
                }

                actionIconsView

                Divider()
                    .foregroundStyle(.text)

                Text(viewModel.burgerModel.name)
                    .font(.title)
                    .foregroundStyle(.text)
                    .multilineTextAlignment(.leading)

                dietryIcons

                Divider()
                    .foregroundStyle(.text)

                infoView

                Divider()
                    .foregroundStyle(.text)

                Text(viewModel.burgerModel.description)
                    .font(.body)
                    .foregroundStyle(.text)
                    .multilineTextAlignment(.leading)

                Divider()
                    .foregroundStyle(.text)

                MapSnapshotView(
                    image: viewModel.mapImage,
                    location: viewModel.location,
                    venue: viewModel.burgerModel.venue,
                    loadingImage: viewModel.loadingImage
                )

                Divider()
                    .foregroundStyle(.text)

                StyledButtonView(type: .openWebView) {
                    viewModel.showWebView()
                }
                .padding(.bottom, .medium)
            }
        }
        .padding(.horizontal, .medium)
    }
}


extension BurgerDetailsView {
    @ViewBuilder
    var dietryIcons: some View {
        HStack {
            ForEach (viewModel.burgerModel.dietaryRequirements, id: \.self) { requirement in
                requirement.image
                    .resizable()
                    .squareFrame(size: 36)
            }
        }
    }
}

extension BurgerDetailsView {
    @ViewBuilder
    var actionIconsView: some View {
        let isFavourited = burgerActionsManager.isBurgerFavourited(id: viewModel.burgerModel.id)
        HStack(alignment: .top, spacing: .xSmall) {
            Button {
                Task {
                    if isFavourited {
                        await burgerActionsManager.deleteFromFavorites(burger: viewModel.burgerModel, errorHandler: viewModel.showErrorAlert)
                    } else {
                        await burgerActionsManager.saveToFavorites(burger: viewModel.burgerModel, errorHandler: viewModel.showErrorAlert)
                    }
                }
            } label: {
                (isFavourited ? Image(.heartFill) : Image(.heart))
                    .resizable()
                    .squareFrame(size: 36)
            }

            Button {
                viewModel.presentEditCalendar()
            } label: {
                VStack {
                    (viewModel.isInCalendar ? Image(.calendarTick) : Image(.calendar))
                        .resizable()
                        .squareFrame(size: 36)
                    if viewModel.isInCalendar {
                        Text("Edit")
                            .font(.caption)
                            .foregroundStyle(.accent)
                    }
                }
            }
            .foregroundStyle(.text)

            if let url = URL(string: viewModel.burgerModel.url) {
                ShareLink(item: url) {
                    Image(.share)
                        .squareFrame(size: 36)
                }
            }
        }
        .padding(.all, .medium)
    }
}


extension BurgerDetailsView {
    @ViewBuilder
    var infoView: some View {
        HStack(spacing: .xxSmall) {
            Text("Main Protein:")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.textSecondary)
            Text(viewModel.burgerModel.mainProtein)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
        }
        if viewModel.burgerModel.beerMatchPrice != nil {
            HStack(alignment: .top, spacing: .xxSmall) {
                Text("Breer Match:")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.textSecondary)
                Text(viewModel.burgerModel.beerMatch)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
        }
        
        HStack(spacing: .xxSmall) {
            Text("Meals Available:")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.textSecondary)
            Text(viewModel.burgerModel.mealAvailable)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
        }
        
        HStack(alignment: .top, spacing: .xxSmall) {
            Text("Address:")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.textSecondary)
            Text(viewModel.burgerModel.venue)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
        }
    }
}
