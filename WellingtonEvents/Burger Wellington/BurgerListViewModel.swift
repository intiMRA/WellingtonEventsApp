//
//  BurgerListViewModel.swift
//  WellingtonEvents
//
//  Created by Inti Albuquerque on 06/08/2025.
//

import Foundation

@MainActor
class BurgerListViewModel: ObservableObject {
    @Published var burgers: [BurgerModel] = []
    @Published var isLoading: Bool = true
    private let repository: BurgerRepositoryProtocol = BurgerRepository()
    
    func fetchBurgers() async {
        isLoading = true
        defer {
            isLoading = false
        }
        burgers = (try? await repository.fetchBurgers())?.burgers ?? []
    }
}
