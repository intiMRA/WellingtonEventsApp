//
//  FilterOptionsView.swift
//  WellingtonEvents
//
//  Created by ialbuquerque on 17/03/2025.
//

import Foundation
import SwiftUI
import DesignLibrary

struct FilterOptionsView: View {
    @State var viewModel: FilterOptionsViewModel
    init(viewModel: FilterOptionsViewModel) {
        self._viewModel = State(wrappedValue: viewModel)
    }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                ForEach(viewModel.possibleFilters, id: \.self) { filter in
                    let isSelected = viewModel.filterIsSelected(filter)
                    Button {
                        withAnimation {
                            viewModel.didTapOnFilter(filter)
                        }
                    }
                    label: {
                        HStack {
                            Image(systemName: isSelected ? "checkmark.square" : "square")
                                .renderingMode(.template)
                            
                            Text(filter)
                                .lineLimit(1)
                                .font(.title3)
                            
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, minHeight: 44)
                    }
                    .foregroundStyle(isSelected ?  Color.accentColor : .unselectedTick)
                    .bold(isSelected)
                    Divider()
                }
            }
            .padding(.horizontal, .medium)
        }
        .animation(.easeIn, value: viewModel.selectedFilters)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    viewModel.dismiss()
                } label : {
                    Text("Cancel")
                }
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    viewModel.didFinishedFiltering()
                } label : {
                    Text("Apply Filters")
                }
            }
        }
    }
}

