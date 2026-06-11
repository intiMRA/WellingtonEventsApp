import Foundation

protocol Filterable: Identifiable where ID == String {
    var name: String { get }
    var venue: String { get }
    var filterLocation: Location? { get }
}
