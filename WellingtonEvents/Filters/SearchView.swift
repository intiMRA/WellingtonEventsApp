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
    @FocusState var focused: Bool
    
    var body: some View {
        ZStack(alignment: .trailing) {
            if !focused {
                HStack {
                    Image(.search)
                        .padding(.trailing, .medium)
                    
                    Text(searchText.nilIfEmpty ?? "Search for events in Welly")
                        .foregroundStyle(.searchText)
                    
                    Spacer()
                }
                .frame(height: 44)
                .padding(.horizontal, .medium)
                .background {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.cardBackground)
                }
                .onTapGesture {
                    focused = true
                }
            }
            
            HStack(alignment: .center) {
                TextField("", text: $searchText)
                    .frame(height: 44)
                    .frame(maxWidth: .infinity)
                    .focused($focused)
                    .padding(.horizontal, .medium)
                    .background {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.cardBackground)
                    }
                
                Spacer()
            }
            .opacity(focused ? 1 : 0)
            
            if focused {
                Button {
                    focused = false
                } label: {
                    Text("Cancel")
                        .padding(.horizontal, .medium)
                }
            }
            
        }
        .animation(.default, value: focused)
        .interactiveDismissDisabled(true)
        .task {
            focused = false
        }
        .padding(.bottom, .xSmall)
    }
}
