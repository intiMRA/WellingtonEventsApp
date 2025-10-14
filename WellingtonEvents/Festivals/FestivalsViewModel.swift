//
//  FestivalsViewModel.swift
//  WellingtonEvents
//
//  Created by Inti Albuquerque on 07/10/2025.
//

import Foundation
import NetworkLayerSPM

enum Festivals: String {
    case burgerWellington = "BurgerWellington"
    case roxy = "RoxyFestival"
    case heritage = "HeritageFestival"
}

struct FestivalDetails: Codable {
    let id: String
    let name: String
    let url: String
    let icon: String
}

@Observable
@MainActor
class FestivalsViewModel {
    var currentFestivalDetails: [FestivalDetails] = []
    
    func fetchFestivals() async {
        currentFestivalDetails = (try? await NetworkLayer.defaultNetworkLayer.request(.init(urlBuilder: UrlBuilder.festivalDetails, httpMethod: .GET))) ?? []
    }
}
