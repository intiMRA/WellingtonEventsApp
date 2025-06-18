//
//  PullToRefreshView.swift
//  WellingtonEvents
//
//  Created by ialbuquerque on 09/06/2025.
//
import Foundation
import SwiftUI
import DesignLibrary
struct PullToRefreshView: View {
    
    var coordinateSpaceName: String
    var onRefresh: () -> Void
    
    @State var needRefresh: Bool = false
    
    init(coordinateSpaceName: String, onRefresh: @escaping () -> Void) {
        self.coordinateSpaceName = coordinateSpaceName
        self.onRefresh = onRefresh
    }
    
    var body: some View {
        GeometryReader { geo in
            if geo.frame(in: .named(coordinateSpaceName)).midY > 50, geo.frame(in: .named(coordinateSpaceName)).midY < 130 {
                Spacer()
                    .task {
                        needRefresh = true
                    }
            }
            else if (geo.frame(in: .named(coordinateSpaceName)).midY >= 130) {
                Spacer()
                    .task {
                        needRefresh = true
                         onRefresh()
                    }
            }
            else {
                Spacer()
                    .onAppear {
                        if needRefresh {
                            needRefresh = false
                        }
                    }
            }
            HStack {
                Spacer()
                if needRefresh {
                    LottieView(lottieFile: .standardLoading)
                        .squareFrame(size: .medium)
                }
                Spacer()
            }
            .opacity(needRefresh ? 1 : 0)
        }.padding(.top, -50)
    }
}
