//
//  BurgerRepository.swift
//  WellingtonEvents
//
//  Created by Inti Albuquerque on 06/08/2025.
//

import Foundation
import NetworkLayerSPM

protocol BurgerRepositoryProtocol: AnyObject, Actor {
    func fetchBurgers() async throws -> BurgerResponse
}

actor BurgerRepository: BurgerRepositoryProtocol {
    func fetchBurgers() async throws -> BurgerResponse {
        try await NetworkLayer.defaultNetworkLayer.request(.init(urlBuilder: UrlBuilder.burgers, httpMethod: .GET))
    }
}
