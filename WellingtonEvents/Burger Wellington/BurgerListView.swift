//
//  BurgerListView.swift
//  WellingtonEvents
//
//  Created by Inti Albuquerque on 06/08/2025.
//

import SwiftUI

struct BurgerListView: View {
    @StateObject var viewModel: BurgerListViewModel = .init()
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var width: CGFloat = .zero
    var body: some View {
        ScrollView {
            LazyVStack {
                if viewModel.isLoading {
                    ProgressView()
                }
                ForEach(viewModel.burgers) { model in
                    BurgerCardView(
                        favouriteModel: .init(isFavourited: false, didTapFavorites: { }),
                        model: model,
                        width: width) { _ in
                            
                        }
                }
            }
            .background {
                GeometryReader { geometry in
                    Color.clear
                        .padding(.horizontal, .medium)
                        .onChange(of: geometry.size) { _, newValue in
                            guard newValue.width > 0 else { return }
                            switch horizontalSizeClass {
                            case .regular:
                                width =  (newValue.width / 2) - 32
                            default:
                                width =  newValue.width - 32
                            }
                        }
                }
            }

        }
        .task {
            await viewModel.fetchBurgers()
        }
    }
}

#Preview {
    BurgerListView()
}
