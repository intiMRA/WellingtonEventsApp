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
    func getFavoriteBurgers() async -> [BurgerModel]
    func addFavoriteBurger(_ burger: BurgerModel) async throws
    func removeFavoriteBurger(_ burger: BurgerModel) async throws
}

actor BurgerRepository: BurgerRepositoryProtocol {
    enum DefaultKeys: String {
        case favoriteBurgers = "favoriteBurgers"
    }
    
    static let userDefaults = UserDefaults.standard
    
    func getFavoriteBurgers() async -> [BurgerModel] {
        guard let data = Self.userDefaults.object(forKey: DefaultKeys.favoriteBurgers.rawValue) as? Data else {
            return []
        }
        let events = (try? JSONDecoder().decode([BurgerModel].self, from: data)) ?? []
        return events
    }
    
    func addFavoriteBurger(_ burger: BurgerModel) async throws {
        var favourites = await getFavoriteBurgers()
        favourites.append(burger)
        try save(favourites: favourites)
    }
    
    func removeFavoriteBurger(_ burger: BurgerModel) async throws {
        var favourites = await getFavoriteBurgers()
        favourites.removeAll { $0.id == burger.id }
        try save(favourites: favourites)
    }
    
    func fetchBurgers() async throws -> BurgerResponse {
        try await NetworkLayer.defaultNetworkLayer.request(.init(urlBuilder: UrlBuilder.burgers, httpMethod: .GET))
    }
        
    private func save(favourites: [BurgerModel]) throws {
        Self.userDefaults.set(try JSONEncoder().encode(favourites), forKey: DefaultKeys.favoriteBurgers.rawValue)
    }
}
