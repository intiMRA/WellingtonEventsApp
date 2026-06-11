import Testing
import Foundation
@testable import WellingtonEvents

actor StubEventsRepository: EventsRepository {
    func fetchEvents() async throws -> EventsResponse? { nil }
    func saveToFavorites(event: EventInfo) throws {}
    func retrieveFavorites() throws -> [EventInfo] { [] }
    func deleteFromFavorites(event: EventInfo) throws {}
    func deleteFromFavorites(eventIds: [String]) throws {}
    func didSaveToCalendar(event: EventInfo) throws {}
    func retrieveSavedToCalendar() throws -> [EventInfo] { [] }
    func didDeleteFromCalendar(event: EventInfo) throws {}
    func didDeleteFromCalendar(eventIds: [String]) throws {}
    func canFetchFromCache() -> Bool { false }
}

struct ListViewModelFilterTests {

    private func makeEvent(
        id: String = "event-1",
        name: String = "Test Event",
        venue: String = "Test Venue",
        dates: [Date] = [Date()],
        source: String = "TestSource",
        eventType: String = "Concert",
        location: Location? = nil
    ) -> EventInfo {
        EventInfo(
            id: id,
            name: name,
            description: "desc",
            imageUrl: nil,
            venue: venue,
            dates: dates,
            displayDate: "",
            url: "https://example.com",
            source: source,
            eventType: eventType,
            location: location
        )
    }

    @MainActor
    private func makeViewModel(events: [EventInfo]) -> ListViewModel {
        ListViewModel(
            allEvents: events,
            events: events,
            repository: StubEventsRepository()
        )
    }

    // MARK: - Date Filter

    @Test @MainActor func dateFilterShowsOnlyEventsInRange() {
        let today = Date()
        let tomorrow = today.addingTimeInterval(86400)
        let nextWeek = today.addingTimeInterval(86400 * 7)

        let e1 = makeEvent(id: "1", dates: [today])
        let e2 = makeEvent(id: "2", dates: [tomorrow])
        let e3 = makeEvent(id: "3", dates: [nextWeek])

        let vm = makeViewModel(events: [e1, e2, e3])
        vm.didSelectDates(today, tomorrow, nil)

        #expect(vm.events.count == 2)
        #expect(vm.events.contains(where: { $0.id == "1" }))
        #expect(vm.events.contains(where: { $0.id == "2" }))
        #expect(!vm.events.contains(where: { $0.id == "3" }))
    }

    @Test @MainActor func dateFilterShowsNoEventsWhenNoneMatch() {
        let nextMonth = Date().addingTimeInterval(86400 * 30)
        let e1 = makeEvent(id: "1", dates: [nextMonth])

        let vm = makeViewModel(events: [e1])
        let today = Date()
        vm.didSelectDates(today, today, nil)

        #expect(vm.events.isEmpty)
    }

    // MARK: - Quick Date Filter

    @Test @MainActor func quickDateTodayShowsOnlyTodaysEvents() {
        let today = Date()
        let nextWeek = today.addingTimeInterval(86400 * 7)

        let e1 = makeEvent(id: "1", dates: [today])
        let e2 = makeEvent(id: "2", dates: [nextWeek])

        let vm = makeViewModel(events: [e1, e2])
        vm.didSelectDates(today, today, .today)

        #expect(vm.events.count == 1)
        #expect(vm.events.first?.id == "1")
    }

    // MARK: - Event Types Filter

    @Test @MainActor func eventTypesFilterShowsMatchingTypes() {
        let e1 = makeEvent(id: "1", eventType: "Concert")
        let e2 = makeEvent(id: "2", eventType: "Comedy")
        let e3 = makeEvent(id: "3", eventType: "Concert")

        let vm = makeViewModel(events: [e1, e2, e3])
        vm.didSelectFilterValues(values: ["Concert"], type: "eventType")

        #expect(vm.events.count == 2)
        #expect(vm.events.contains(where: { $0.id == "1" }))
        #expect(vm.events.contains(where: { $0.id == "3" }))
        #expect(!vm.events.contains(where: { $0.id == "2" }))
    }

    @Test @MainActor func eventTypesFilterMultipleTypesShowsAll() {
        let e1 = makeEvent(id: "1", eventType: "Concert")
        let e2 = makeEvent(id: "2", eventType: "Comedy")
        let e3 = makeEvent(id: "3", eventType: "Theatre")

        let vm = makeViewModel(events: [e1, e2, e3])
        vm.didSelectFilterValues(values: ["Concert", "Comedy"], type: "eventType")

        #expect(vm.events.count == 2)
        #expect(!vm.events.contains(where: { $0.id == "3" }))
    }

    // MARK: - Sources Filter

    @Test @MainActor func sourcesFilterShowsMatchingSources() {
        let e1 = makeEvent(id: "1", source: "Eventfinda")
        let e2 = makeEvent(id: "2", source: "Humanitix")
        let e3 = makeEvent(id: "3", source: "Eventfinda")

        let vm = makeViewModel(events: [e1, e2, e3])
        vm.didSelectFilterValues(values: ["Eventfinda"], type: "source")

        #expect(vm.events.count == 2)
        #expect(!vm.events.contains(where: { $0.id == "2" }))
    }

    // MARK: - One Of Filter

    @Test @MainActor func oneOfFilterShowsSingleDateEventsOnly() {
        let e1 = makeEvent(id: "1", dates: [Date()])
        let e2 = makeEvent(id: "2", dates: [Date(), Date().addingTimeInterval(86400)])
        let e3 = makeEvent(id: "3", dates: [Date()])

        let vm = makeViewModel(events: [e1, e2, e3])
        vm.didTapOneOfFilter()

        #expect(vm.events.count == 2)
        #expect(vm.events.contains(where: { $0.id == "1" }))
        #expect(vm.events.contains(where: { $0.id == "3" }))
        #expect(!vm.events.contains(where: { $0.id == "2" }))
    }

    @Test @MainActor func oneOfFilterTogglesOff() {
        let e1 = makeEvent(id: "1", dates: [Date()])
        let e2 = makeEvent(id: "2", dates: [Date(), Date().addingTimeInterval(86400)])

        let vm = makeViewModel(events: [e1, e2])
        vm.didTapOneOfFilter()
        #expect(vm.events.count == 1)

        vm.didTapOneOfFilter()
        #expect(vm.events.count == 2)
    }

    // MARK: - Multiple Dates Filter

    @Test @MainActor func multipleDatesFilterShowsMultiDateEventsOnly() {
        let e1 = makeEvent(id: "1", dates: [Date()])
        let e2 = makeEvent(id: "2", dates: [Date(), Date().addingTimeInterval(86400)])

        let vm = makeViewModel(events: [e1, e2])
        vm.didTapMultipleDatesFilter()

        #expect(vm.events.count == 1)
        #expect(vm.events.first?.id == "2")
    }

    @Test @MainActor func multipleDatesFilterTogglesOff() {
        let e1 = makeEvent(id: "1", dates: [Date()])
        let e2 = makeEvent(id: "2", dates: [Date(), Date().addingTimeInterval(86400)])

        let vm = makeViewModel(events: [e1, e2])
        vm.didTapMultipleDatesFilter()
        #expect(vm.events.count == 1)

        vm.didTapMultipleDatesFilter()
        #expect(vm.events.count == 2)
    }

    // MARK: - Favourites Filter

    @Test @MainActor func favouritesFilterShowsOnlyFavourites() {
        let e1 = makeEvent(id: "1")
        let e2 = makeEvent(id: "2")
        let e3 = makeEvent(id: "3")

        let vm = makeViewModel(events: [e1, e2, e3])
        vm.didTapFavouritesFilter(favourites: [e1, e3])

        #expect(vm.events.count == 2)
        #expect(vm.events.contains(where: { $0.id == "1" }))
        #expect(vm.events.contains(where: { $0.id == "3" }))
        #expect(!vm.events.contains(where: { $0.id == "2" }))
    }

    @Test @MainActor func favouritesFilterTogglesOff() {
        let e1 = makeEvent(id: "1")
        let e2 = makeEvent(id: "2")

        let vm = makeViewModel(events: [e1, e2])
        vm.didTapFavouritesFilter(favourites: [e1])
        #expect(vm.events.count == 1)

        vm.didTapFavouritesFilter(favourites: [e1])
        #expect(vm.events.count == 2)
    }

    // MARK: - Search Filter

    @Test @MainActor func searchFilterByNamePrefix() {
        let e1 = makeEvent(id: "1", name: "Jazz Night")
        let e2 = makeEvent(id: "2", name: "Rock Show")
        let e3 = makeEvent(id: "3", name: "Jazz Festival")

        let vm = makeViewModel(events: [e1, e2, e3])
        vm.didTypeSearch(string: "Jazz")

        #expect(vm.events.count == 2)
        #expect(vm.events.contains(where: { $0.id == "1" }))
        #expect(vm.events.contains(where: { $0.id == "3" }))
    }

    @Test @MainActor func searchFilterByVenue() {
        let e1 = makeEvent(id: "1", name: "Event A", venue: "Cuba St Bar")
        let e2 = makeEvent(id: "2", name: "Event B", venue: "Courtney Place")

        let vm = makeViewModel(events: [e1, e2])
        vm.didTypeSearch(string: "Cuba")

        #expect(vm.events.count == 1)
        #expect(vm.events.first?.id == "1")
    }

    @Test @MainActor func searchFilterClearsWhenEmpty() {
        let e1 = makeEvent(id: "1", name: "Jazz Night")
        let e2 = makeEvent(id: "2", name: "Rock Show")

        let vm = makeViewModel(events: [e1, e2])
        vm.didTypeSearch(string: "Jazz")
        #expect(vm.events.count == 1)

        vm.didTypeSearch(string: "")
        #expect(vm.events.count == 2)
    }

    // MARK: - Clear Filters

    @Test @MainActor func clearFilterRestoresAllEvents() {
        let e1 = makeEvent(id: "1", eventType: "Concert")
        let e2 = makeEvent(id: "2", eventType: "Comedy")

        let vm = makeViewModel(events: [e1, e2])
        vm.didSelectFilterValues(values: ["Concert"], type: "eventType")
        #expect(vm.events.count == 1)

        vm.clearFilters(for: .eventType)
        #expect(vm.events.count == 2)
    }

    @Test @MainActor func clearAllFiltersRestoresAllEvents() {
        let e1 = makeEvent(id: "1", eventType: "Concert", source: "Eventfinda")
        let e2 = makeEvent(id: "2", eventType: "Comedy", source: "Humanitix")

        let vm = makeViewModel(events: [e1, e2])
        vm.didSelectFilterValues(values: ["Concert"], type: "eventType")
        vm.didSelectFilterValues(values: ["Eventfinda"], type: "source")
        #expect(vm.events.count == 1)

        vm.clearFilters(for: [.eventType, .source])
        #expect(vm.events.count == 2)
    }

    // MARK: - Combined Filters

    @Test @MainActor func combiningFiltersNarrowsResults() {
        let e1 = makeEvent(id: "1", eventType: "Concert", source: "Eventfinda")
        let e2 = makeEvent(id: "2", eventType: "Concert", source: "Humanitix")
        let e3 = makeEvent(id: "3", eventType: "Comedy", source: "Eventfinda")

        let vm = makeViewModel(events: [e1, e2, e3])
        vm.didSelectFilterValues(values: ["Concert"], type: "eventType")
        #expect(vm.events.count == 2)

        vm.didSelectFilterValues(values: ["Eventfinda"], type: "source")
        #expect(vm.events.count == 1)
        #expect(vm.events.first?.id == "1")
    }

    @Test @MainActor func oneOfPlusEventTypeFilterCombines() {
        let e1 = makeEvent(id: "1", dates: [Date()], eventType: "Concert")
        let e2 = makeEvent(id: "2", dates: [Date(), Date().addingTimeInterval(86400)], eventType: "Concert")
        let e3 = makeEvent(id: "3", dates: [Date()], eventType: "Comedy")

        let vm = makeViewModel(events: [e1, e2, e3])
        vm.didTapOneOfFilter()
        vm.didSelectFilterValues(values: ["Concert"], type: "eventType")

        #expect(vm.events.count == 1)
        #expect(vm.events.first?.id == "1")
    }
}
