import Testing
import CoreLocation
@testable import WellingtonEvents

struct BurgerDetailsViewModelTests {

    private func makeBurger(
        lat: Double = -41.2865,
        long: Double = 174.7762,
        name: String = "Test Burger",
        venue: String = "Test Venue"
    ) -> BurgerModel {
        BurgerModel(
            id: "burger-1",
            name: name,
            image: "https://example.com/image.jpg",
            description: "A delicious test burger",
            price: 18.0,
            beerMatchPrice: nil,
            mealAvailable: "Lunch & Dinner",
            beerMatch: "",
            venue: venue,
            coordinates: Location(lat: lat, long: long),
            sidesIncluded: false,
            mainProtein: "Beef",
            dietaryRequirements: [],
            url: "https://example.com/burger"
        )
    }

    @Test @MainActor func generateSnapshotSetsLocationFromCoordinates() async {
        let burger = makeBurger(lat: -41.29, long: 174.78)
        let viewModel = BurgerDetailsViewModel(burgerModel: burger)

        await viewModel.generateSnapshot()

        #expect(viewModel.location != nil)
        #expect(viewModel.location?.latitude == -41.29)
        #expect(viewModel.location?.longitude == 174.78)
    }

    @Test @MainActor func generateSnapshotSetsMapImage() async {
        let viewModel = BurgerDetailsViewModel(burgerModel: makeBurger())

        await viewModel.generateSnapshot()

        #expect(viewModel.mapImage != nil)
    }

    @Test @MainActor func generateSnapshotTogglesLoadingFlag() async {
        let viewModel = BurgerDetailsViewModel(burgerModel: makeBurger())

        #expect(viewModel.loadingImage == false)
        await viewModel.generateSnapshot()
        #expect(viewModel.loadingImage == false)
    }

    @Test @MainActor func showWebViewSetsRoute() {
        let burger = makeBurger()
        let viewModel = BurgerDetailsViewModel(burgerModel: burger)

        viewModel.showWebView()

        if case .webView(let url) = viewModel.route {
            #expect(url.absoluteString == "https://example.com/burger")
        } else {
            Issue.record("Expected webView route")
        }
    }

    @Test @MainActor func resetRouteClearsRoute() {
        let viewModel = BurgerDetailsViewModel(burgerModel: makeBurger())
        viewModel.showWebView()
        #expect(viewModel.route != nil)

        viewModel.resetRoute()
        #expect(viewModel.route == nil)
    }

    @Test @MainActor func showErrorAlertSetsAlertRoute() {
        let viewModel = BurgerDetailsViewModel(burgerModel: makeBurger())

        viewModel.showErrorAlert("Error Title", "Something went wrong")

        if case .alert(let style) = viewModel.route {
            if case .error(let title, let message) = style {
                #expect(title == "Error Title")
                #expect(message == "Something went wrong")
            } else {
                Issue.record("Expected error toast style")
            }
        } else {
            Issue.record("Expected alert route")
        }
    }
}
