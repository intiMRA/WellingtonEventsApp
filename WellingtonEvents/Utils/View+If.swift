//
//  View+If.swift
//  WellingtonEvents
//
//  Created by Inti Albuquerque on 20/06/2025.
//

import Foundation
import SwiftUI

extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
