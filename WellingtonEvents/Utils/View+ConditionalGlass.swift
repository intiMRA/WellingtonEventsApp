//
//  View+ConditionalGlass.swift
//  WellingtonEvents
//
//  Created by Inti Albuquerque on 17/09/2025.
//

import SwiftUI

extension View {
    @ViewBuilder
    func conditionalGlass() -> some View {
        if #available(iOS 26.0, *) {
            self
                .glassEffect()
        } else {
            self
        }
    }
}
