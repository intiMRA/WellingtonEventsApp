//
//  View+ToolBar.swift
//  WellingtonEvents
//
//  Created by Inti Albuquerque on 08/08/2025.
//

import Foundation
import SwiftUI
import DesignLibrary

extension View {
    @ViewBuilder
    func wellingTOnToolbar(favoritesSelected: Bool, didTapFavourites: @escaping () -> Void) -> some View {
        self
            .toolbarBackground(.hidden, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Spacer(minLength: CommonPadding.medium.rawValue)
                        
                        Image(.bar)
                            .resizable()
                            .renderingMode(.template)
                            .foregroundStyle(.text)
                            .scaledToFit()
                        
                        Spacer(minLength: CommonPadding.medium.rawValue)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        didTapFavourites()
                    } label: {
                        if #available(iOS 26.0, *) {
                            (favoritesSelected ? Image(.heartFillClear) : Image(.heartClear))
                                .resizable()
                                .squareFrame(size: 36)
                        } else {
                            (favoritesSelected ? Image(.heartFill) : Image(.heart))
                                .resizable()
                                .squareFrame(size: 36)
                        }
                    }
                }
            }
    }
}
