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
    @State var selectedQuickDate: QuickDateType?
    let dismiss: () -> Void
    let didSelectDates: (Date, Date, QuickDateType?) -> Void
    init(
        startDate: Date,
        endDate: Date,
        selectedQuickDate: QuickDateType?,
        dismiss: @escaping () -> Void,
        didSelectDates: @escaping (Date, Date, QuickDateType?) -> Void) {
            self._startDate = State(wrappedValue: startDate)
            self._endDate = State(wrappedValue: endDate)
            self._selectedQuickDate = State(wrappedValue: selectedQuickDate)
            self.dismiss = dismiss
            self.didSelectDates = didSelectDates
        }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .medium) {
                datePickers
                Divider()
                quickFiltersView
                confirmationButtonView
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
                   didTapConfirmationButton()
                } label : {
                    Text("Apply Filters")
                }
            }
        }
    }
    
    @ViewBuilder
    var confirmationButtonView: some View {
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
        
    }
    
    func didTapConfirmationButton() {
        if endDate < startDate {
            endDate = startDate
        }
        didSelectDates(startDate, endDate, selectedQuickDate)
    }
    
    @ViewBuilder
    var quickFiltersView: some View {
        LazyVGrid(columns: QuickDateType.lazyGrid, alignment: .leading, spacing: 8) {
            ForEach(QuickDateType.allCases, id: \.rawValue) { value in
                FilterView(
                    isSelected: selectedQuickDate == value,
                    title: value.name,
                    hasIcon: false) {
                        withAnimation {
                            if selectedQuickDate == value {
                                selectedQuickDate = nil
                            } else {
                                selectedQuickDate = value
                            }
                        }
                    }
            }
        }
    }
    
    @ViewBuilder
    var datePickers: some View {
        VStack {
            HStack {
                Text("From:")
                    .foregroundStyle(selectedQuickDate != nil ? .textSecondary : .text)
                    .bold()
                Spacer()
                if selectedQuickDate != nil {
                    Text(startDate.asString(with: .ddMMMYyyySpaced))
                        .foregroundStyle(.textSecondary)
                        .padding(.all, .xSmall)
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray)
                                .opacity(0.5)
                        }
                }
                else {
                    DatePicker("", selection: $startDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                }
            }
            HStack {
                Text("To:")
                    .foregroundStyle(selectedQuickDate != nil ? .textSecondary : .text)
                    .bold()
                Spacer()
                if selectedQuickDate != nil {
                    Text(endDate.asString(with: .ddMMMYyyySpaced))
                        .foregroundStyle(.textSecondary)
                        .padding(.all, .xSmall)
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray)
                                .opacity(0.5)
                        }
                }
                else {
                    DatePicker("", selection: $endDate, in: startDate..., displayedComponents: .date)
                        .datePickerStyle(.compact)
                }
            }
        }
    }
}
