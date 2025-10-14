//
//  SearchView.swift
//  WellingtonEvents
//
//  Created by ialbuquerque on 05/06/2025.
//

import SwiftUI
import DesignLibrary

struct SearchView: View {
    @Binding var searchText: String
    var focusState: FocusState<ViewFocusState?>.Binding
    var hasCancelButton: Bool = true
    
    var body: some View {
        ZStack(alignment: .trailing) {
            if focusState.wrappedValue != .search {
                HStack {
                    Image(.search)
                        .padding(.trailing, .empty)
                    
                    Text(searchText.nilIfEmpty ?? String(localized: "Search for events in Welly"))
                        .foregroundStyle(.searchText)
                    
                    Spacer()
                }
                .frame(height: 44)
                .padding(.horizontal, .medium)
                .background {
                    if #available(iOS 26.0, *) {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(hasCancelButton ? .cardBackground : .clear)
                            .shadow(radius: 2, x: 0, y: 2)
                            .glassEffect()
                    }
                    else {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.cardBackground)
                            .shadow(radius: 2, x: 0, y: 2)
                    }
                }
                .onTapGesture {
                    focusState.wrappedValue = .search
                }
            }
            ZStack(alignment: .trailing) {
                HStack(alignment: .center) {
                    TextField("", text: $searchText)
                        .frame(height: 44)
                        .frame(maxWidth: .infinity)
                        .focused(focusState, equals: .search)
                        .padding(.horizontal, .medium)
                        .background {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.cardBackground)
                                .shadow(radius: 2, x: 0, y: 2)
                                .conditionalGlass()
                        }
                    
                    if searchText.isEmpty, focusState.wrappedValue == .search, hasCancelButton {
                        HStack {
                            Button {
                                focusState.wrappedValue = nil
                            } label: {
                                Text("Cancel")
                            }
                        }
                        .padding(.trailing, .medium)
                    }
                }
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .renderingMode(.template)
                            .foregroundStyle(.accent)
                    }
                    .padding(.trailing, .xSmall)
                }
            }
            .opacity(focusState.wrappedValue == .search ? 1 : 0)
            
        }
        .animation(.default, value: focusState.wrappedValue)
        .animation(.default, value: searchText)
        .interactiveDismissDisabled(true)
        .task {
            focusState.wrappedValue = nil
        }
        .padding(.bottom, .xSmall)
    }
}
