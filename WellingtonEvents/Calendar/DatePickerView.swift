//
//  DatePickerView.swift
//  WellingtonEvents
//
//  Created by ialbuquerque on 17/03/2025.
//

import SwiftUI
import DesignLibrary

struct DatePickerView: View {
    @State var viewModel: DatePickerViewModel
    init(viewModel: DatePickerViewModel) {
        self._viewModel = State(wrappedValue: viewModel)
    }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                ForEach(viewModel.datesByMonth()) { month in
                    Text(month.month)
                        .font(.headline)
                        .foregroundStyle(.text)
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 4) {
                        ForEach(month.dates, id: \.self) { date in
                            Button {
                                viewModel.selectedDate = date
                            } label: {
                                VStack {
                                    Text(date.asString(with: .dd))
                                        .lineLimit(1)
                                }
                                .frame(maxWidth: .infinity)
                                .background {
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(viewModel.selectedDate == date ? Color.blue.opacity(0.7) : Color.gray.opacity(0.7))
                                        .frame(width: 44, height: 44)
                                }
                            }
                            .frame(width: 44, height: 44)
                        }
                    }
                }
            }
            .padding(.horizontal, .medium)
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    viewModel.dismiss(nil)
                } label : {
                    Text("Cancel")
                }
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    viewModel.addToCalendar()
                } label: {
                    Text("Add To Calendar")
                }
            }
        }
    }
}
