//
//  ConfirmationButtonView.swift
//  WellingtonEvents
//
//  Created by Inti Albuquerque on 24/07/2025.
//
import SwiftUI
import DesignLibrary

struct ConfirmationButtonView: View {
    var didTapConfirmationButton: () -> Void
    var body: some View {
        Button{
            didTapConfirmationButton()
        } label: {
            Text("Apply Filters")
                .frame(maxWidth: .infinity, idealHeight: 44)
                .background {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.accent)
                }
                .foregroundStyle(.selectedChipText)
                .bold()
        }
        .padding(.top, .small)
    }
}
