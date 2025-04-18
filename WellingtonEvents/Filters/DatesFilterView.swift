//
//  DatesFilterView.swift
//  WellingtonEvents
//
//  Created by ialbuquerque on 10/04/2025.
//

import SwiftUI
import DesignLibrary

struct DatesFilterView: View {
    @State var startDate: Date
    @State var endDate: Date
    let dismiss: () -> Void
    let didSelectDates: (Date, Date) -> Void
    init(startDate: Date, endDate: Date, dismiss: @escaping () -> Void, didSelectDates: @escaping (Date, Date) -> Void) {
        self._startDate = State(wrappedValue: startDate)
        self._endDate = State(wrappedValue: endDate)
        self.dismiss = dismiss
        self.didSelectDates = didSelectDates
    }
    
    var body: some View {
        Group {
            if UIDevice.current.userInterfaceIdiom == .phone {
                ScrollView {
                    VStack(alignment: .leading, spacing: .xxSmall) {
                        datePickers
                    }
                }
            }
            else {
                HStack(alignment: .center, spacing: .xxSmall) {
                    datePickers
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
                    if endDate < startDate {
                        endDate = startDate
                    }
                    didSelectDates(startDate, endDate)
                } label : {
                    Text("Apply Filters")
                }
            }
        }
    }
    
    @ViewBuilder
    var datePickers: some View {
        VStack(alignment: .leading, spacing: .xxxSmall) {
            Text("From")
                .bold()
            
            DatePicker("Start date", selection: $startDate, displayedComponents: .date)
                .datePickerStyle(.graphical)
        }
        
        VStack(alignment: .leading, spacing: .xxxSmall) {
            Text("To")
                .bold()
            
            DatePicker("", selection: $endDate, in: startDate..., displayedComponents: .date)
                .datePickerStyle(.graphical)
        }
    }
}
