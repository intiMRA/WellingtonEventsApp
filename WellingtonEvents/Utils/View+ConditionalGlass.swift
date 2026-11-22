//
//  View+ConditionalGlass.swift
//  WellingtonEvents
//
//  Created by Inti Albuquerque on 17/09/2025.
//

import SwiftUI

private enum LegacyShadow {
    static let radius: CGFloat = 2
    static let yOffset: CGFloat = 2
    static let opacity: Double = 0.25
}

extension View {
    @ViewBuilder
    func conditionalGlass(
        tint: Color? = nil,
        isInteractive: Bool = false,
        in shape: some Shape = Capsule(),
        legacyColor: Color? = nil,
        hasLegacyShadow: Bool = false
    ) -> some View {
        if #available(iOS 26.0, *) {
            glassEffect(.regular.tint(tint).interactive(isInteractive), in: shape)
        } else {
            background {
                if let legacyColor {
                    shape
                        .fill(legacyColor)
                        .shadow(
                            color: Color(.shadow).opacity(LegacyShadow.opacity),
                            radius: hasLegacyShadow ? LegacyShadow.radius : 0,
                            y: hasLegacyShadow ? LegacyShadow.yOffset : 0
                        )
                }
            }
        }
    }

    @ViewBuilder
    func conditionalGlassContainer() -> some View {
        if #available(iOS 26.0, *) {
            GlassEffectContainer {
                self
            }
        } else {
            self
        }
    }
}
