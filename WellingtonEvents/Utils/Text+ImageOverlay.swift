//
//  Text+ImageOverlay.swift
//  WellingtonEvents
//
//  Created by Inti Albuquerque on 09/08/2025.
//

import Foundation
import SwiftUI
import DesignLibrary

@MainActor
extension Text {
    public func imageOverlay() -> some View {
        self
            .multilineTextAlignment(.leading)
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundStyle(.selectedChipText)
            .padding(.all, .xSmall)
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.accent)
                    .opacity(0.8)
                    .shadow(color: .shadow.opacity(0.25), radius: 2, x: 1, y: 1)
            }
    }
}
