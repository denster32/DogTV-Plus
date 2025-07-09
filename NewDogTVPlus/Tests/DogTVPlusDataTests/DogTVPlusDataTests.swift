import XCTest
@testable import DogTVPlusData

final class DogTVPlusDataTests: XCTestCase {
    
    func testDataModuleInitialization() {
        let dataModule = DogTVPlusData()
        XCTAssertEqual(DogTVPlusData.version, "1.0.0")
    }
}
