import Testing
import CoreLocation
@testable import WellingtonEvents

struct MapSnapshotGeneratorTests {

    @Test func snapshotSizeHasCorrectRatio() {
        let size = MapSnapshotGenerator.snapshotSize
        let expectedRatio = size.width / size.height
        #expect(MapSnapshotGenerator.ratio == expectedRatio)
    }

    @Test func snapshotSizeDimensionsArePositive() {
        #expect(MapSnapshotGenerator.snapshotSize.width > 0)
        #expect(MapSnapshotGenerator.snapshotSize.height > 0)
    }

    @Test func generateSnapshotReturnsImageForValidLocation() async {
        let wellington = CLLocationCoordinate2D(latitude: -41.2865, longitude: 174.7762)
        let image = await MapSnapshotGenerator.generateSnapshot(for: wellington)
        #expect(image != nil)
    }
}
