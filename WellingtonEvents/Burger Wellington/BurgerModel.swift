//
//  BurgerModel.swift
//  WellingtonEvents
//
//  Created by Inti Albuquerque on 06/08/2025.
//

import Foundation
import SwiftUI

struct BurgerResponse: Codable, Sendable {
    
    struct Filters: Codable {
        struct PriceRange: Codable {
            let min: Double
            let max: Double
        }
        
        let dietaryRequirements: [String]
        let priceRange: PriceRange
        let beerMatch: [String]
        let proteins: [String]
    }
    
    let burgers: [BurgerModel]
    let filters: Filters
}

enum DietryRequirement: String, Codable, Sendable {
    case vegan = "Vegan Available"
    case dairyFree = "Dairy Free Available"
    case nutFree = "Nut Free Available"
    case glutenFree = "Gluten Free Available"
    case vegetarian = "Vegetarian Available"
    
    var image: Image {
        switch self {
        case .vegan:
            Image(.plantBased)
        case .dairyFree:
            Image(.dairyFree)
        case .nutFree:
            Image(.nutFree)
        case .glutenFree:
            Image(.glutenFree)
        case .vegetarian:
            Image(.vegetarian)
        }
    }
}

struct BurgerModel: Identifiable, Codable, Sendable, Equatable {
    let id: String
    let name: String
    let image: String
    let description: String
    let price: Double
    let beerMatchPrice: Double?
    let mealAvailable: String
    let beerMatch: String
    let venue: String
    let coordinates: Location
    let sidesIncluded: Bool
    let mainProtein: String
    let dietaryRequirements: [DietryRequirement]
    let url: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case image
        case description
        case price
        case beerMatchPrice
        case mealAvailable
        case beerMatch
        case venue
        case coordinates
        case sidesIncluded
        case mainProtein
        case dietaryRequirements
        case url
    }
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.image = try container.decode(String.self, forKey: .image)
        self.description = try container.decode(String.self, forKey: .description)
        self.price = try container.decode(Double.self, forKey: .price)
        self.beerMatchPrice = try container.decodeIfPresent(Double.self, forKey: .beerMatchPrice)
        self.mealAvailable = try container.decode(String.self, forKey: .mealAvailable)
        self.beerMatch = try container.decode(String.self, forKey: .beerMatch)
        self.venue = try container.decode(String.self, forKey: .venue)
        self.coordinates = try container.decode(Location.self, forKey: .coordinates)
        self.sidesIncluded = try container.decode(Bool.self, forKey: .sidesIncluded)
        self.mainProtein = try container.decode(String.self, forKey: .mainProtein)
        self.dietaryRequirements = try container.decode([String].self, forKey: .dietaryRequirements).compactMap { .init(rawValue: $0) }
        self.url = try container.decode(String.self, forKey: .url)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(image, forKey: .image)
        try container.encode(description, forKey: .description)
        try container.encode(price, forKey: .price)
        if let beerMatchPrice = beerMatchPrice {
            try container.encode(beerMatchPrice, forKey: .beerMatchPrice)
        }
        try container.encode(mealAvailable, forKey: .mealAvailable)
        try container.encode(beerMatch, forKey: .beerMatch)
        try container.encode(venue, forKey: .venue)
        try container.encode(coordinates, forKey: .coordinates)
        try container.encode(sidesIncluded, forKey: .sidesIncluded)
        try container.encode(mainProtein, forKey: .mainProtein)
        try container.encode(dietaryRequirements, forKey: .dietaryRequirements)
        try container.encode(url, forKey: .url)
    }
}

extension BurgerModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
