import Testing
import CoreLocation
@testable import WellingtonEvents

struct EventDetailsViewModelTests {

    private func makeEvent(
        lat: Double? = nil,
        long: Double? = nil,
        venue: String = "Test Venue, Wellington"
    ) -> EventInfo {
        let location: Location? = if let lat, let long {
            Location(lat: lat, long: long)
        } else {
            nil
        }
        return EventInfo(
            id: "event-1",
            name: "Test Event",
            description: "A test event description",
            imageUrl: nil,
            venue: venue,
            dates: [Date()],
            displayDate: "June 11, 2026",
            url: "https://example.com/event",
            source: "TestSource",
            eventType: "Concert",
            location: location
        )
    }

    @Test @MainActor func generateSnapshotSetsLocationFromCoordinates() async {
        let event = makeEvent(lat: -41.29, long: 174.78)
        let viewModel = EventDetailsViewModel(event: event, repository: nil)

        await viewModel.generateSnapshot()

        #expect(viewModel.location != nil)
        #expect(viewModel.location?.latitude == -41.29)
        #expect(viewModel.location?.longitude == 174.78)
    }

    @Test @MainActor func generateSnapshotSetsImage() async {
        let event = makeEvent(lat: -41.2865, long: 174.7762)
        let viewModel = EventDetailsViewModel(event: event, repository: nil)

        await viewModel.generateSnapshot()

        #expect(viewModel.image != nil)
    }

    @Test @MainActor func generateSnapshotTogglesLoadingFlag() async {
        let event = makeEvent(lat: -41.2865, long: 174.7762)
        let viewModel = EventDetailsViewModel(event: event, repository: nil)

        #expect(viewModel.loadingImage == false)
        await viewModel.generateSnapshot()
        #expect(viewModel.loadingImage == false)
    }

    @Test @MainActor func showWebViewSetsRoute() {
        let event = makeEvent()
        let viewModel = EventDetailsViewModel(event: event, repository: nil)

        viewModel.showWebView()

        if case .webView(let url) = viewModel.route {
            #expect(url.absoluteString == "https://example.com/event")
        } else {
            Issue.record("Expected webView route")
        }
    }

    @Test @MainActor func resetRouteClearsRoute() {
        let event = makeEvent()
        let viewModel = EventDetailsViewModel(event: event, repository: nil)
        viewModel.showWebView()
        #expect(viewModel.route != nil)

        viewModel.resetRoute()
        #expect(viewModel.route == nil)
    }

    @Test @MainActor func showErrorAlertSetsAlertRoute() {
        let event = makeEvent()
        let viewModel = EventDetailsViewModel(event: event, repository: nil)

        viewModel.showErrorAlert("Error", "Details here")

        if case .alert(let style) = viewModel.route {
            if case .error(let title, let message) = style {
                #expect(title == "Error")
                #expect(message == "Details here")
            } else {
                Issue.record("Expected error toast style")
            }
        } else {
            Issue.record("Expected alert route")
        }
    }
}
