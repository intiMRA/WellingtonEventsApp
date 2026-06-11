import Testing
import Foundation
@testable import WellingtonEvents

struct BurgerListViewModelFilterTests {

    private func makeBurger(
        id: String = "burger-1",
        name: String = "Test Burger",
        venue: String = "Test Venue",
        price: Double = 18.0,
        beerMatch: String = "Pale Ale",
        sidesIncluded: Bool = false,
        mainProtein: String = "Beef",
        dietaryRequirements: [DietryRequirement] = [],
        coordinates: Location = Location(lat: -41.29, long: 174.78)
    ) -> BurgerModel {
        BurgerModel(
            id: id,
            name: name,
            image: "https://example.com/image.jpg",
            description: "A test burger",
            price: price,
            beerMatchPrice: nil,
            mealAvailable: "Lunch & Dinner",
            beerMatch: beerMatch,
            venue: venue,
            coordinates: coordinates,
            sidesIncluded: sidesIncluded,
            mainProtein: mainProtein,
            dietaryRequirements: dietaryRequirements,
            url: "https://example.com/burger"
        )
    }

    @MainActor
    private func makeViewModel(burgers: [BurgerModel]) -> BurgerListViewModel {
        let vm = BurgerListViewModel()
        vm.allBurgers = burgers
        vm.burgers = burgers
        return vm
    }

    // MARK: - Sides Filter

    @Test @MainActor func sidesFilterShowsOnlyBurgersWithSides() {
        let b1 = makeBurger(id: "1", sidesIncluded: true)
        let b2 = makeBurger(id: "2", sidesIncluded: false)
        let b3 = makeBurger(id: "3", sidesIncluded: true)

        let vm = makeViewModel(burgers: [b1, b2, b3])
        vm.didTapSidesFilter()

        #expect(vm.burgers.count == 2)
        #expect(vm.burgers.contains(where: { $0.id == "1" }))
        #expect(vm.burgers.contains(where: { $0.id == "3" }))
        #expect(!vm.burgers.contains(where: { $0.id == "2" }))
    }

    @Test @MainActor func sidesFilterTogglesOff() {
        let b1 = makeBurger(id: "1", sidesIncluded: true)
        let b2 = makeBurger(id: "2", sidesIncluded: false)

        let vm = makeViewModel(burgers: [b1, b2])
        vm.didTapSidesFilter()
        #expect(vm.burgers.count == 1)

        vm.didTapSidesFilter()
        #expect(vm.burgers.count == 2)
    }

    // MARK: - Price Filter

    @Test @MainActor func priceFilterShowsBurgersUnderMax() {
        let b1 = makeBurger(id: "1", price: 15.0)
        let b2 = makeBurger(id: "2", price: 20.0)
        let b3 = makeBurger(id: "3", price: 18.0)

        let vm = makeViewModel(burgers: [b1, b2, b3])
        vm.didSelectPrice(18.0)

        #expect(vm.burgers.count == 2)
        #expect(vm.burgers.contains(where: { $0.id == "1" }))
        #expect(vm.burgers.contains(where: { $0.id == "3" }))
        #expect(!vm.burgers.contains(where: { $0.id == "2" }))
    }

    @Test @MainActor func priceFilterShowsAllWhenHighMax() {
        let b1 = makeBurger(id: "1", price: 15.0)
        let b2 = makeBurger(id: "2", price: 20.0)

        let vm = makeViewModel(burgers: [b1, b2])
        vm.didSelectPrice(100.0)

        #expect(vm.burgers.count == 2)
    }

    // MARK: - Dietary Restrictions Filter

    @Test @MainActor func dietaryRestrictionsFilterShowsMatchingBurgers() {
        let b1 = makeBurger(id: "1", dietaryRequirements: [.glutenFree])
        let b2 = makeBurger(id: "2", dietaryRequirements: [.vegan])
        let b3 = makeBurger(id: "3", dietaryRequirements: [.glutenFree, .dairyFree])

        let vm = makeViewModel(burgers: [b1, b2, b3])
        vm.didSelectFilterValues(values: ["Gluten Free Available"], type: "dietryRestrictions")

        #expect(vm.burgers.count == 2)
        #expect(vm.burgers.contains(where: { $0.id == "1" }))
        #expect(vm.burgers.contains(where: { $0.id == "3" }))
        #expect(!vm.burgers.contains(where: { $0.id == "2" }))
    }

    @Test @MainActor func dietaryRestrictionsFilterMultipleValues() {
        let b1 = makeBurger(id: "1", dietaryRequirements: [.glutenFree])
        let b2 = makeBurger(id: "2", dietaryRequirements: [.vegan])
        let b3 = makeBurger(id: "3", dietaryRequirements: [])

        let vm = makeViewModel(burgers: [b1, b2, b3])
        vm.didSelectFilterValues(values: ["Gluten Free Available", "Vegan Available"], type: "dietryRestrictions")

        #expect(vm.burgers.count == 2)
        #expect(!vm.burgers.contains(where: { $0.id == "3" }))
    }

    // MARK: - Beer Matches Filter

    @Test @MainActor func beerMatchesFilterShowsMatchingBurgers() {
        let b1 = makeBurger(id: "1", beerMatch: "Pale Ale")
        let b2 = makeBurger(id: "2", beerMatch: "IPA")
        let b3 = makeBurger(id: "3", beerMatch: "Pale Ale")

        let vm = makeViewModel(burgers: [b1, b2, b3])
        vm.didSelectFilterValues(values: ["Pale Ale"], type: "beerMatches")

        #expect(vm.burgers.count == 2)
        #expect(vm.burgers.contains(where: { $0.id == "1" }))
        #expect(vm.burgers.contains(where: { $0.id == "3" }))
        #expect(!vm.burgers.contains(where: { $0.id == "2" }))
    }

    @Test @MainActor func beerMatchesFilterMultipleBeers() {
        let b1 = makeBurger(id: "1", beerMatch: "Pale Ale")
        let b2 = makeBurger(id: "2", beerMatch: "IPA")
        let b3 = makeBurger(id: "3", beerMatch: "Stout")

        let vm = makeViewModel(burgers: [b1, b2, b3])
        vm.didSelectFilterValues(values: ["Pale Ale", "IPA"], type: "beerMatches")

        #expect(vm.burgers.count == 2)
        #expect(!vm.burgers.contains(where: { $0.id == "3" }))
    }

    // MARK: - Protein Filter

    @Test @MainActor func proteinFilterShowsMatchingBurgers() {
        let b1 = makeBurger(id: "1", mainProtein: "Beef")
        let b2 = makeBurger(id: "2", mainProtein: "Chicken")
        let b3 = makeBurger(id: "3", mainProtein: "Wagyu Beef")

        let vm = makeViewModel(burgers: [b1, b2, b3])
        vm.didSelectFilterValues(values: ["Beef"], type: "protein")

        #expect(vm.burgers.count == 2)
        #expect(vm.burgers.contains(where: { $0.id == "1" }))
        #expect(vm.burgers.contains(where: { $0.id == "3" }))
        #expect(!vm.burgers.contains(where: { $0.id == "2" }))
    }

    @Test @MainActor func proteinFilterMultipleProteins() {
        let b1 = makeBurger(id: "1", mainProtein: "Beef")
        let b2 = makeBurger(id: "2", mainProtein: "Chicken")
        let b3 = makeBurger(id: "3", mainProtein: "Lamb")

        let vm = makeViewModel(burgers: [b1, b2, b3])
        vm.didSelectFilterValues(values: ["Beef", "Chicken"], type: "protein")

        #expect(vm.burgers.count == 2)
        #expect(!vm.burgers.contains(where: { $0.id == "3" }))
    }

    // MARK: - Favourites Filter

    @Test @MainActor func favouritesFilterShowsOnlyFavourites() {
        let b1 = makeBurger(id: "1")
        let b2 = makeBurger(id: "2")
        let b3 = makeBurger(id: "3")

        let vm = makeViewModel(burgers: [b1, b2, b3])
        vm.didTapFavouritesFilter(favourites: [b1, b3])

        #expect(vm.burgers.count == 2)
        #expect(vm.burgers.contains(where: { $0.id == "1" }))
        #expect(vm.burgers.contains(where: { $0.id == "3" }))
        #expect(!vm.burgers.contains(where: { $0.id == "2" }))
    }

    @Test @MainActor func favouritesFilterTogglesOff() {
        let b1 = makeBurger(id: "1")
        let b2 = makeBurger(id: "2")

        let vm = makeViewModel(burgers: [b1, b2])
        vm.didTapFavouritesFilter(favourites: [b1])
        #expect(vm.burgers.count == 1)

        vm.didTapFavouritesFilter(favourites: [b1])
        #expect(vm.burgers.count == 2)
    }

    // MARK: - Search Filter

    @Test @MainActor func searchFilterByNamePrefix() {
        let b1 = makeBurger(id: "1", name: "Wagyu Deluxe")
        let b2 = makeBurger(id: "2", name: "Classic Burger")
        let b3 = makeBurger(id: "3", name: "Wagyu Special")

        let vm = makeViewModel(burgers: [b1, b2, b3])
        vm.didTypeSearch(string: "Wagyu")

        #expect(vm.burgers.count == 2)
        #expect(vm.burgers.contains(where: { $0.id == "1" }))
        #expect(vm.burgers.contains(where: { $0.id == "3" }))
    }

    @Test @MainActor func searchFilterByVenue() {
        let b1 = makeBurger(id: "1", name: "Burger A", venue: "Cuba St Bar")
        let b2 = makeBurger(id: "2", name: "Burger B", venue: "Courtney Place")

        let vm = makeViewModel(burgers: [b1, b2])
        vm.didTypeSearch(string: "Cuba")

        #expect(vm.burgers.count == 1)
        #expect(vm.burgers.first?.id == "1")
    }

    @Test @MainActor func searchFilterClearsWhenEmpty() {
        let b1 = makeBurger(id: "1", name: "Wagyu Deluxe")
        let b2 = makeBurger(id: "2", name: "Classic Burger")

        let vm = makeViewModel(burgers: [b1, b2])
        vm.didTypeSearch(string: "Wagyu")
        #expect(vm.burgers.count == 1)

        vm.didTypeSearch(string: "")
        #expect(vm.burgers.count == 2)
    }

    // MARK: - Clear Filters

    @Test @MainActor func clearFilterRestoresAllBurgers() {
        let b1 = makeBurger(id: "1", sidesIncluded: true)
        let b2 = makeBurger(id: "2", sidesIncluded: false)

        let vm = makeViewModel(burgers: [b1, b2])
        vm.didTapSidesFilter()
        #expect(vm.burgers.count == 1)

        vm.clearFilters(for: .sidesIncluded)
        #expect(vm.burgers.count == 2)
    }

    @Test @MainActor func clearMultipleFiltersRestoresAllBurgers() {
        let b1 = makeBurger(id: "1", sidesIncluded: true, mainProtein: "Beef")
        let b2 = makeBurger(id: "2", sidesIncluded: false, mainProtein: "Chicken")

        let vm = makeViewModel(burgers: [b1, b2])
        vm.didTapSidesFilter()
        vm.didSelectFilterValues(values: ["Beef"], type: "protein")
        #expect(vm.burgers.count == 1)

        vm.clearFilters(for: [.sidesIncluded, .protein])
        #expect(vm.burgers.count == 2)
    }

    // MARK: - Combined Filters

    @Test @MainActor func combiningFiltersNarrowsResults() {
        let b1 = makeBurger(id: "1", price: 15.0, sidesIncluded: true)
        let b2 = makeBurger(id: "2", price: 25.0, sidesIncluded: true)
        let b3 = makeBurger(id: "3", price: 15.0, sidesIncluded: false)

        let vm = makeViewModel(burgers: [b1, b2, b3])
        vm.didTapSidesFilter()
        #expect(vm.burgers.count == 2)

        vm.didSelectPrice(20.0)
        #expect(vm.burgers.count == 1)
        #expect(vm.burgers.first?.id == "1")
    }

    @Test @MainActor func proteinPlusBeerFilterCombines() {
        let b1 = makeBurger(id: "1", beerMatch: "Pale Ale", mainProtein: "Beef")
        let b2 = makeBurger(id: "2", beerMatch: "IPA", mainProtein: "Beef")
        let b3 = makeBurger(id: "3", beerMatch: "Pale Ale", mainProtein: "Chicken")

        let vm = makeViewModel(burgers: [b1, b2, b3])
        vm.didSelectFilterValues(values: ["Beef"], type: "protein")
        vm.didSelectFilterValues(values: ["Pale Ale"], type: "beerMatches")

        #expect(vm.burgers.count == 1)
        #expect(vm.burgers.first?.id == "1")
    }

    @Test @MainActor func sidesPlusFavouritesFilterCombines() {
        let b1 = makeBurger(id: "1", sidesIncluded: true)
        let b2 = makeBurger(id: "2", sidesIncluded: true)
        let b3 = makeBurger(id: "3", sidesIncluded: false)

        let vm = makeViewModel(burgers: [b1, b2, b3])
        vm.didTapSidesFilter()
        vm.didTapFavouritesFilter(favourites: [b1])

        #expect(vm.burgers.count == 1)
        #expect(vm.burgers.first?.id == "1")
    }
}
