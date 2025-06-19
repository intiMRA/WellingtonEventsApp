//
//  QuickDatesFilterView.swift
//  WellingtonEvents
//
//  Created by ialbuquerque on 06/06/2025.
//
import Foundation
import SwiftUI
import DesignLibrary

struct QuickDatesFilterView: View {
    @State var selectedDate: QuickDateType
    var didSelectDate: (QuickDateType) -> Void
    let dismiss: () -> Void
    
    init(selectedDate: QuickDateType?, didSelectDate: @escaping (QuickDateType) -> Void, dismiss: @escaping () -> Void) {
        self._selectedDate = State(wrappedValue: selectedDate ?? .today)
        self.didSelectDate = didSelectDate
        self.dismiss = dismiss
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: QuickDateType.lazyGrid, alignment: .leading, spacing: 8) {
                ForEach(QuickDateType.allCases, id: \.rawValue) { value in
                    FilterView(
                        isSelected: selectedDate == value,
                        title: value.name,
                        hasIcon: false) {
                            selectedDate = value
                        }
                }
            }
        }
        .padding(.horizontal, .medium)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    dismiss()
                } label : {
                    Text("Cancel")
                }
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    didSelectDate(selectedDate)
                } label : {
                    Text("Apply Filters")
                }
            }
        }
        
    }
}

