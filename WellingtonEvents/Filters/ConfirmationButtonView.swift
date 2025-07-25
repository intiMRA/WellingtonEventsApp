//
//  ConfirmationButtonView.swift
//  WellingtonEvents
//
//  Created by Inti Albuquerque on 24/07/2025.
//
import SwiftUI
import DesignLibrary

struct StyledButtonView: View {
    enum StyledButtonViewType {
        case applyFilters
        case openWebView
        
        var title: String {
            switch self {
            case .applyFilters:
                return String(localized: "Apply Filters")
            case .openWebView:
                return String(localized: "View Event")
            }
        }
    }
    
    let type: StyledButtonViewType
    var didTapConfirmationButton: () -> Void
    
    var body: some View {
        Button{
            didTapConfirmationButton()
        } label: {
            Text(type.title)
                .frame(maxWidth: .infinity, idealHeight: 44)
                .background {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.accent)
                }
                .foregroundStyle(.selectedChipText)
                .bold()
        }
    }
}
