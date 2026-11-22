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
            .conditionalGlass(
                tint: .accent,
                in: RoundedRectangle(cornerRadius: 20),
                legacyColor: .accent.opacity(0.8),
                hasLegacyShadow: true
            )
    }
}
