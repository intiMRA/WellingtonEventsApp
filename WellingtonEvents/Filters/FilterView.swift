//
//  FilterView.swift
//  WellingtonEvents
//
//  Created by ialbuquerque on 21/03/2025.
//

import SwiftUI
import DesignLibrary

struct FilterView: View {
    let isSelected: Bool
    let title: String
    let hasIcon: Bool
    let minWidth: CGFloat?
    let hasShadow: Bool
    let action: () -> Void
    let clearFilters: () -> Void
    
    init(isSelected: Bool, title: String, hasIcon: Bool, minWidth: CGFloat? = nil, hasShadow: Bool = false, action: @escaping () -> Void, clearFilters: @escaping () -> Void = {}) {
        self.isSelected = isSelected
        self.title = title
        self.hasIcon = hasIcon
        self.action = action
        self.clearFilters = clearFilters
        self.minWidth = minWidth
        self.hasShadow = hasShadow
    }
    
    var body: some View {
        Button {
            withAnimation {
                action()
            }
        } label: {
            if hasIcon {
                if isSelected {
                    HStack {
                        Text(title)
                            .font(.headline)
                        Button {
                            withAnimation {
                                clearFilters()
                            }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                        }
                    }
                }
                else {
                    Text("\(title) \(Image(systemName: "chevron.down"))")
                        .font(.headline)
                }
            }
            else {
                Text(title)
                    .font(.headline)
            }
        }
        .foregroundStyle(isSelected ? .selectedChipText : .text)
        .padding(.horizontal, .small)
        .padding(.vertical, .xSmall)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .background {
            if #available(iOS 26.0, *) {
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? .accent : .clear)
                    .glassEffect()
                    .if(hasShadow) { view in
                        view
                            .shadow(radius: 2, x: 0, y: 2)
                    }
            }
            else {
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? .accent : .cardBackground)
                    .if(hasShadow) { view in
                        view
                            .shadow(radius: 2, x: 0, y: 2)
                    }
            }
        }
    }
}
