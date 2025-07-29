//
//  LocationsFilterView.swift
//  WellingtonEvents
//
//  Created by Inti Albuquerque on 29/07/2025.
//

import SwiftUI
import DesignLibrary

struct DistanceFilterView: View {
    @State var selectedDistance: Double = 0
    let dismiss: () -> Void
    let didSelectDistance: (Double) -> Void
    init(selectedDistance: Double, dismiss: @escaping () -> Void, didSelectDistance: @escaping (Double) -> Void) {
        self.selectedDistance = selectedDistance
        self.dismiss = dismiss
        self.didSelectDistance = didSelectDistance
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .medium) {
                if selectedDistance == 0 {
                    Text("Select a distance")
                }
                else {
                    Text("Select distance: \(selectedDistance, specifier: "%.0f")km")
                }
                Slider(value: $selectedDistance, in: 1.0...300.0) {
                                Text("Distance") // Accessibility label
                            } minimumValueLabel: {
                                Text("1km")
                            } maximumValueLabel: {
                                Text("300km")
                            }
                Divider()
                quickDistances
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
        guard selectedDistance > 0 else { return }
        didSelectDistance(selectedDistance)
    }
    
    @ViewBuilder
    var quickDistances: some View {
        LazyVGrid(columns: Distances.lazyGrid, alignment: .leading, spacing: 8) {
            ForEach(Distances.allCases, id: \.self) { distance in
                FilterView(
                    isSelected: selectedDistance == distance.value,
                    title: distance.name,
                    hasIcon: false) {
                        withAnimation {
                            if selectedDistance == distance.value {
                                selectedDistance = 0
                            } else {
                                selectedDistance = distance.value
                            }
                        }
                    }
            }
        }
    }
}
