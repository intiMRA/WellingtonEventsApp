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
    static let calendar = Calendar.current
    
    enum BurgerRepositoryError: Error {
        case failedToFetchResponse
    }
    
    enum DefaultKeys: String {
        case favoriteBurgers
        case burgersCacheDate
        case burgersResponseCache
    }
    
    func getFavoriteBurgers() async -> [BurgerModel] {
        guard let data = UserDefaults.standard.object(forKey: DefaultKeys.favoriteBurgers.rawValue) as? Data else {
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
        if canFetchFromCache() {
            if let cachedResponseData = UserDefaults.standard.data(forKey: DefaultKeys.burgersResponseCache.rawValue) {
                return try JSONDecoder().decode(BurgerResponse.self, from: cachedResponseData)
            }
        }
        guard let response: BurgerResponse = try await NetworkLayer.defaultNetworkLayer.request(.init(urlBuilder: UrlBuilder.burgers, httpMethod: .GET)) else {
            if let cachedResponseData = UserDefaults.standard.data(forKey: DefaultKeys.burgersResponseCache.rawValue) {
                return try JSONDecoder().decode(BurgerResponse.self, from: cachedResponseData)
            }
            else {
                throw BurgerRepositoryError.failedToFetchResponse
            }
        }
        UserDefaults.standard.set(try JSONEncoder().encode(response), forKey: DefaultKeys.burgersResponseCache.rawValue)
        UserDefaults.standard.set(Date.now.asString(with: .ddMMYyyy), forKey: DefaultKeys.burgersCacheDate.rawValue)
        
        return response
    }
    
    func canFetchFromCache() -> Bool {
        guard
            let userDefaultsDateString = UserDefaults.standard.object(forKey: DefaultKeys.burgersCacheDate.rawValue) as? String,
            let userDefaultsDate = userDefaultsDateString.asDate(with: .ddMMYyyy)
        else {
            return false
        }
        return Self.calendar.isDate(.now, inSameDayAs: userDefaultsDate)
    }
        
    private func save(favourites: [BurgerModel]) throws {
        UserDefaults.standard.set(try JSONEncoder().encode(favourites), forKey: DefaultKeys.favoriteBurgers.rawValue)
    }
}
