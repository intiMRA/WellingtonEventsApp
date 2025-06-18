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
    let action: () -> Void
    let clearFilters: () -> Void
    
    init(isSelected: Bool, title: String, hasIcon: Bool, action: @escaping () -> Void, clearFilters: @escaping () -> Void = {}) {
        self.isSelected = isSelected
        self.title = title
        self.hasIcon = hasIcon
        self.action = action
        self.clearFilters = clearFilters
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
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(isSelected ? .accent : .cardBackground))
    }
}
