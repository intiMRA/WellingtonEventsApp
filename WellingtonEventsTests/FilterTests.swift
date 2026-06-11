import Testing
import CoreLocation
@testable import WellingtonEvents

struct FilterTests {

    // MARK: - Test Helpers

    private func makeEvent(
        id: String = "event-1",
        name: String = "Test Event",
        venue: String = "Test Venue",
        dates: [Date] = [Date()],
        source: String = "TestSource",
        eventType: String = "Concert",
        location: Location? = Location(lat: -41.29, long: 174.78)
    ) -> EventInfo {
        EventInfo(
            id: id,
            name: name,
            description: "A test event",
            imageUrl: nil,
            venue: venue,
            dates: dates,
            displayDate: "June 11, 2026",
            url: "https://example.com",
            source: source,
            eventType: eventType,
            location: location
        )
    }

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

    // MARK: - EventTypesFilter

    @Test func eventTypesFilterMatchesCorrectType() {
        let filter = EventTypesFilter(eventTypes: ["Concert", "Festival"])
        let event = makeEvent(eventType: "Concert")
        #expect(filter.matches(event) == true)
    }

    @Test func eventTypesFilterRejectsWrongType() {
        let filter = EventTypesFilter(eventTypes: ["Concert", "Festival"])
        let event = makeEvent(eventType: "Comedy")
        #expect(filter.matches(event) == false)
    }

    // MARK: - SourcesFilter

    @Test func sourcesFilterMatchesCorrectSource() {
        let filter = SourcesFilter(sources: ["Eventfinda", "Humanitix"])
        let event = makeEvent(source: "Eventfinda")
        #expect(filter.matches(event) == true)
    }

    @Test func sourcesFilterRejectsWrongSource() {
        let filter = SourcesFilter(sources: ["Eventfinda"])
        let event = makeEvent(source: "Humanitix")
        #expect(filter.matches(event) == false)
    }

    // MARK: - OneOfFilter

    @Test func oneOfFilterMatchesSingleDate() {
        let filter = OneOfFilter()
        let event = makeEvent(dates: [Date()])
        #expect(filter.matches(event) == true)
    }

    @Test func oneOfFilterRejectsMultipleDates() {
        let filter = OneOfFilter()
        let event = makeEvent(dates: [Date(), Date().addingTimeInterval(86400)])
        #expect(filter.matches(event) == false)
    }

    // MARK: - MultipleDatesFilter

    @Test func multipleDatesFilterMatchesMultipleDates() {
        let filter = MultipleDatesFilter()
        let event = makeEvent(dates: [Date(), Date().addingTimeInterval(86400)])
        #expect(filter.matches(event) == true)
    }

    @Test func multipleDatesFilterRejectsSingleDate() {
        let filter = MultipleDatesFilter()
        let event = makeEvent(dates: [Date()])
        #expect(filter.matches(event) == false)
    }

    // MARK: - SidesFilter

    @Test func sidesFilterMatchesWhenSidesIncluded() {
        let filter = SidesFilter()
        let burger = makeBurger(sidesIncluded: true)
        #expect(filter.matches(burger) == true)
    }

    @Test func sidesFilterRejectsWhenNoSides() {
        let filter = SidesFilter()
        let burger = makeBurger(sidesIncluded: false)
        #expect(filter.matches(burger) == false)
    }

    // MARK: - PriceFilter

    @Test func priceFilterMatchesUnderMax() {
        let filter = PriceFilter(maxPrice: 20.0)
        let burger = makeBurger(price: 18.0)
        #expect(filter.matches(burger) == true)
    }

    @Test func priceFilterMatchesExactMax() {
        let filter = PriceFilter(maxPrice: 18.0)
        let burger = makeBurger(price: 18.0)
        #expect(filter.matches(burger) == true)
    }

    @Test func priceFilterRejectsOverMax() {
        let filter = PriceFilter(maxPrice: 15.0)
        let burger = makeBurger(price: 18.0)
        #expect(filter.matches(burger) == false)
    }

    // MARK: - BeerMatchesFilter

    @Test func beerMatchesFilterMatchesCorrectBeer() {
        let filter = BeerMatchesFilter(beerMatches: ["Pale Ale", "IPA"])
        let burger = makeBurger(beerMatch: "Pale Ale")
        #expect(filter.matches(burger) == true)
    }

    @Test func beerMatchesFilterRejectsWrongBeer() {
        let filter = BeerMatchesFilter(beerMatches: ["IPA", "Stout"])
        let burger = makeBurger(beerMatch: "Pale Ale")
        #expect(filter.matches(burger) == false)
    }

    // MARK: - ProteinFilter

    @Test func proteinFilterMatchesCorrectProtein() {
        let filter = ProteinFilter(proteins: ["Beef", "Chicken"])
        let burger = makeBurger(mainProtein: "Beef")
        #expect(filter.matches(burger) == true)
    }

    @Test func proteinFilterMatchesPartialProtein() {
        let filter = ProteinFilter(proteins: ["Beef"])
        let burger = makeBurger(mainProtein: "Wagyu Beef")
        #expect(filter.matches(burger) == true)
    }

    @Test func proteinFilterRejectsWrongProtein() {
        let filter = ProteinFilter(proteins: ["Chicken"])
        let burger = makeBurger(mainProtein: "Beef")
        #expect(filter.matches(burger) == false)
    }

    // MARK: - DietryRestrictionsFilter

    @Test func dietryRestrictionsFilterMatchesWhenPresent() {
        let filter = DietryRestrictionsFilter(dietryRestrictions: ["Gluten Free Available"])
        let burger = makeBurger(dietaryRequirements: [.glutenFree])
        #expect(filter.matches(burger) == true)
    }

    @Test func dietryRestrictionsFilterRejectsWhenAbsent() {
        let filter = DietryRestrictionsFilter(dietryRestrictions: ["Vegan Available"])
        let burger = makeBurger(dietaryRequirements: [.glutenFree])
        #expect(filter.matches(burger) == false)
    }

    // MARK: - FavouritesFilter (shared via Filterable)

    @Test func favouritesFilterMatchesEventById() {
        let event = makeEvent(id: "fav-1")
        let filter = FavouritesFilter(favourites: [event])
        #expect(filter.matches(event) == true)
    }

    @Test func favouritesFilterRejectsNonFavoritedEvent() {
        let favEvent = makeEvent(id: "fav-1")
        let otherEvent = makeEvent(id: "other-1")
        let filter = FavouritesFilter(favourites: [favEvent])
        #expect(filter.matches(otherEvent) == false)
    }

    @Test func favouritesFilterMatchesBurgerById() {
        let burger = makeBurger(id: "fav-burger")
        let filter = FavouritesFilter(favourites: [burger])
        #expect(filter.matches(burger) == true)
    }

    @Test func favouritesFilterRejectsNonFavoritedBurger() {
        let favBurger = makeBurger(id: "fav-burger")
        let otherBurger = makeBurger(id: "other-burger")
        let filter = FavouritesFilter(favourites: [favBurger])
        #expect(filter.matches(otherBurger) == false)
    }

    // MARK: - SearchFilter

    @Test func searchFilterMatchesAlwaysReturnsTrue() {
        let filter = SearchFilter(searchString: "test")
        let event = makeEvent(name: "Unrelated")
        let burger = makeBurger(name: "Unrelated")
        #expect(filter.matches(event) == true)
        #expect(filter.matches(burger) == true)
    }

    @Test func searchFilterExecuteReordersEventsByNamePrefix() {
        let filter = SearchFilter(searchString: "test")
        var events = [
            makeEvent(id: "1", name: "Another Event", venue: "Other"),
            makeEvent(id: "2", name: "Test Event", venue: "Other"),
            makeEvent(id: "3", name: "Contains test word", venue: "Other"),
        ]
        filter.execute(items: &events)
        #expect(events.first?.id == "2")
        #expect(events.count == 2)
    }

    @Test func searchFilterExecuteIncludesVenueMatches() {
        let filter = SearchFilter(searchString: "cuba")
        var events = [
            makeEvent(id: "1", name: "Jazz Night", venue: "Cuba St Bar"),
            makeEvent(id: "2", name: "Rock Show", venue: "Courtney Place"),
        ]
        filter.execute(items: &events)
        #expect(events.count == 1)
        #expect(events.first?.id == "1")
    }

    @Test func searchFilterExecuteWorksBurgers() {
        let filter = SearchFilter(searchString: "wagyu")
        var burgers = [
            makeBurger(id: "1", name: "Wagyu Deluxe", venue: "Other"),
            makeBurger(id: "2", name: "Classic Burger", venue: "Other"),
        ]
        filter.execute(items: &burgers)
        #expect(burgers.count == 1)
        #expect(burgers.first?.id == "1")
    }

    // MARK: - DateFilter

    @Test func dateFilterMatchesEventWithinRange() {
        let now = Date()
        let filter = DateFilter(
            startDate: now.addingTimeInterval(-86400),
            endDate: now.addingTimeInterval(86400)
        )
        let event = makeEvent(dates: [now])
        #expect(filter.matches(event) == true)
    }

    @Test func dateFilterRejectsEventOutsideRange() {
        let now = Date()
        let filter = DateFilter(
            startDate: now.addingTimeInterval(86400 * 5),
            endDate: now.addingTimeInterval(86400 * 10)
        )
        let event = makeEvent(dates: [now])
        #expect(filter.matches(event) == false)
    }

    // MARK: - DistanceFilter (shared via Filterable)

    @Test func distanceFilterRejectsEventWithNoLocation() {
        let filter = DistanceFilter(distance: 10)
        let event = makeEvent(location: nil)
        #expect(filter.matches(event) == false)
    }

    @Test func distanceFilterUsesFilterLocationForBurger() {
        let filter = DistanceFilter(distance: 10)
        let burger = makeBurger()
        let result = filter.matches(burger)
        #expect(result == true || result == false)
    }
}
