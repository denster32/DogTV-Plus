import XCTest
@testable import DogTVPlusVision

final class DogTVPlusVisionTests: XCTestCase {
    
    func testVisionModuleInitialization() {
        let visionModule = DogTVPlusVision()
        XCTAssertEqual(DogTVPlusVision.version, "1.0.0")
    }
}
