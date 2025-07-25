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
    @EnvironmentObject var actionsManager: ActionsManager
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
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 44))], spacing: 8) {
                        ForEach(month.dates, id: \.self) { date in
                            Button {
                                viewModel.selectedDate = date
                            } label: {
                                VStack {
                                    Text(date.asString(with: .dd))
                                        .lineLimit(1)
                                        .foregroundStyle(viewModel.isDateSelected(date) ? .selectedChipText : .text)
                                    if !date.displayAsAllDay {
                                        Text(date.asString(with: .hhmm))
                                            .font(.caption)
                                            .lineLimit(1)
                                            .foregroundStyle(viewModel.isDateSelected(date) ? .selectedChipText : .text)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .background {
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(Color.accentColor, lineWidth: 1)
                                        .fill(viewModel.isDateSelected(date) ? .accentColor.opacity(0.7) : Color.clear)
                                        .squareFrame(size: 44)
                                }
                            }
                            .squareFrame(size: 44)
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
                    Task {
                        await addToCalander()
                    }
                } label: {
                    Text("Add To Calendar")
                }
            }
        }
    }
    
    func addToCalander() async {
        if await actionsManager.addToCalendar(event: viewModel.event, date: viewModel.selectedDate, errorHandler: viewModel.errorHandler) {
            viewModel.dismiss(.success(title: AlertMessages.addCalendarSuccess.title, message: AlertMessages.addCalendarSuccess.message))
        }
    }
}
