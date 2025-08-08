//
//  BurgerDetailsViewModel.swift
//  WellingtonEvents
//
//  Created by Inti Albuquerque on 07/08/2025.
//

import Foundation
@preconcurrency import MapKit
import CasePaths
import DesignLibrary

@Observable
@MainActor
class BurgerDetailsViewModel {
    
    @CasePathable
    enum Destination: Hashable {
        case webView(url: URL)
        case alert(ToastStyle)
    }
    
    static let snapshorSize = CGSize(width: UITraitCollection.current.horizontalSizeClass == .regular ? 800 : 400, height: UITraitCollection.current.horizontalSizeClass == .regular ? 400 : 200)
    static let ratio = snapshorSize.width / snapshorSize.height
    var mapImage: UIImage?
    var location: CLLocationCoordinate2D?
    var loadingImage: Bool = false
    
    var route: Destination?
    
    let burgerModel: BurgerModel
    let repository: BurgerRepositoryProtocol = BurgerRepository()
    let isFavorite: (BurgerModel) -> Bool
    let didTapFavorite: (BurgerModel) -> Void
    
    init(burgerModel: BurgerModel, isFavorite: @escaping (BurgerModel) -> Bool, didTapFavorite: @escaping (BurgerModel) -> Void) {
        self.burgerModel = burgerModel
        self.isFavorite = isFavorite
        self.didTapFavorite = didTapFavorite
    }
    
    func generateSnapshot() async {
        loadingImage = true
        defer {
            loadingImage = false
        }
        let lat = burgerModel.coordinates.lat
        let long = burgerModel.coordinates.long
        let location = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
        self.location = location
        let mapOptions = MKMapSnapshotter.Options()
        mapOptions.region = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapOptions.size = EventDetailsViewModel.snapshorSize
        mapOptions.showsBuildings = true
        mapOptions.pointOfInterestFilter = .includingAll
        let snapshotter = MKMapSnapshotter(options: mapOptions)
        do {
            let snapshot = try await snapshotter.start()
            
            let pinImage = UIImage(resource: .location) // Your pin image
            var finalImage: UIImage?
            let mapImage = snapshot.image
            
            UIGraphicsBeginImageContextWithOptions(mapImage.size, true, mapImage.scale)
            mapImage.draw(at: .zero)
            
            let pointOnImage = snapshot.point(for: location)
            let pinRect = CGRect(
                x: pointOnImage.x - 20,
                y: pointOnImage.y - 43,
                width: 40,
                height: 43
            )
            pinImage.draw(in: pinRect)
            
            finalImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            self.mapImage = finalImage ?? mapImage
        }
        catch {
            print("Error creating snapshot: \(error.localizedDescription)")
        }
    }
    
    func showWebView() {
        guard let url = URL(string: burgerModel.url) else { return }
        route = .webView(url: url)
    }
    
    func resetRoute() {
        route = nil
    }
    
    func showErrorAlert(_ title: String? = nil, _ message: String) {
        route = .alert(.error(title: title, message: message))
    }
}
