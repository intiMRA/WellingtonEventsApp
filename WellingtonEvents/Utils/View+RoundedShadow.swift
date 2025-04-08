//
//  SwiftUIView.swift
//  WellingtonEvents
//
//  Created by ialbuquerque on 07/04/2025.
//

import SwiftUI

extension View {
    func roundedShadow(color: Gradient? = nil) -> some View {
        self
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(color ?? Gradient(colors: [.clear]))
                    .shadow(color: .shadow.opacity(0.25), radius: 2, x: 1, y: 1))
    }
}
