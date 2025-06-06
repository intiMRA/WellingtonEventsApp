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
            Grid(alignment: .leading, horizontalSpacing: 8, verticalSpacing: 8) {
                ForEach(QuickDateType.asGrid, id: \.0) { row in
                    GridRow {
                        HStack {
                            ForEach(row.1, id: \.rawValue) { value in
                                FilterView(
                                    isSelected: selectedDate == value,
                                    title: value.name,
                                    hasIcon: false) {
                                        selectedDate = value
                                    }
                            }
                            
                            Spacer()
                        }
                    }
                    .frame(maxWidth: .infinity)
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

