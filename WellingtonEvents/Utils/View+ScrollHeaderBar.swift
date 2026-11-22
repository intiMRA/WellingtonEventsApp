//
//  View+ScrollHeaderBar.swift
//  WellingtonEvents
//
//  Created by Inti Albuquerque on 21/11/2026.
//

import SwiftUI

extension View {
    @ViewBuilder
    func scrollHeaderBar(@ViewBuilder content: () -> some View) -> some View {
        if #available(iOS 26.0, *) {
            safeAreaBar(edge: .top, spacing: .zero) {
                content()
            }
            .scrollEdgeEffectStyle(.soft, for: .top)
        } else {
            safeAreaInset(edge: .top, spacing: .zero) {
                content()
                    .background(.bar)
            }
        }
    }
}
