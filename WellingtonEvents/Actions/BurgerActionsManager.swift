import Foundation

@MainActor
class BurgerActionsManager: ObservableObject {
    @Published var favourites: [BurgerModel] = []
    private let repository: BurgerRepositoryProtocol = BurgerRepository()

    func isBurgerFavourited(id: String) -> Bool {
        favourites.contains(where: { $0.id == id })
    }

    @discardableResult
    func saveToFavorites(burger: BurgerModel, errorHandler: (String?, String) -> Void) async -> Bool {
        do {
            try await repository.addFavoriteBurger(burger)
            favourites.append(burger)
            return true
        } catch {
            errorHandler(AlertMessages.addFavoritesFail.title, AlertMessages.addFavoritesFail.message)
            return false
        }
    }

    @discardableResult
    func deleteFromFavorites(burger: BurgerModel, errorHandler: (String?, String) -> Void) async -> Bool {
        do {
            try await repository.removeFavoriteBurger(burger)
            favourites.removeAll(where: { $0.id == burger.id })
            return true
        } catch {
            errorHandler(AlertMessages.deleteFavoritesFail.title, AlertMessages.deleteFavoritesFail.message)
            return false
        }
    }

    func loadFavourites() async {
        favourites = await repository.getFavoriteBurgers()
    }
}
