import Testing
import EventKit
@testable import WellingtonEvents

struct CalendarManagerTests {

    private func makeBurger() -> BurgerModel {
        BurgerModel(
            id: "burger-1",
            name: "Wellington Wagyu",
            image: "https://example.com/image.jpg",
            description: "Premium wagyu burger with truffle mayo",
            price: 25.0,
            beerMatchPrice: 32.0,
            mealAvailable: "Lunch & Dinner",
            beerMatch: "Pale Ale",
            venue: "The Burger Joint, Cuba St",
            coordinates: Location(lat: -41.2865, long: 174.7762),
            sidesIncluded: true,
            mainProtein: "Beef",
            dietaryRequirements: [],
            url: "https://example.com/burger"
        )
    }

    @Test func ekEventSetsCorrectFieldsFromBurgerModel() async {
        let burger = makeBurger()
        let ekEvent = await CalendarManager.ekEvent(for: burger)

        #expect(ekEvent.title == "Wellington Wagyu")
        #expect(ekEvent.notes == "Premium wagyu burger with truffle mayo")
        #expect(ekEvent.location == "The Burger Joint, Cuba St")
        #expect(ekEvent.url?.absoluteString == "https://example.com/burger")
    }
}
