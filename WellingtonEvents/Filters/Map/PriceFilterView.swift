//
//  PriceFilterView.swift
//  WellingtonEvents
//
//  Created by Inti Albuquerque on 10/08/2025.
//

import SwiftUI
import DesignLibrary

struct PriceFilterView: View {
    @State var selectedPrice: Double = 0
    let min: Double
    let max: Double
    let dismiss: () -> Void
    let didSelectPrice: (Double) -> Void
    init(
        min: Double,
        max: Double,
        selectedPrice: Double,
        dismiss: @escaping () -> Void,
        didSelectPrice: @escaping (Double) -> Void) {
        self.selectedPrice = selectedPrice
            self.max = max
            self.min = min
        self.dismiss = dismiss
        self.didSelectPrice = didSelectPrice
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .medium) {
                if selectedPrice == 0 {
                    Text("Select a price")
                }
                else {
                    Text("Selected price: \(selectedPrice.formatted(.currency(code: "NZD")))")
                }
                Slider(value: $selectedPrice, in: min...max) {
                                Text("Price")
                            } minimumValueLabel: {
                                Text("\(min.formatted(.currency(code: "NZD")))")
                            } maximumValueLabel: {
                                Text("\(max.formatted(.currency(code: "NZD")))")
                            }
                Divider()
                StyledButtonView(type: .applyFilters) {
                    didTapConfirmationButton()
                }
                .padding(.top, .small)
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
    
    func didTapConfirmationButton() {
        guard selectedPrice > 0 else { return }
        didSelectPrice(selectedPrice)
    }
}
