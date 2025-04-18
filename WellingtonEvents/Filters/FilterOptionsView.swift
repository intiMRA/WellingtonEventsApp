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
                    HStack {
                        let isSelected = viewModel.filterIsSelected(filter)
                        Image(systemName: "checkmark.square")
                            .renderingMode(.template)
                            .foregroundStyle(isSelected ?  Color.blue.opacity(0.7) : Color.gray.opacity(0.7))
                            .bold(isSelected)
                        Text(filter)
                            .lineLimit(1)
                            .font(.title3)
                            .foregroundStyle(.text)
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .onTapGesture {
                        withAnimation {
                            viewModel.didTapOnFilter(filter)
                        }
                    }
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

