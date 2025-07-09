import XCTest
@testable import DogTVPlusUI

final class DogTVPlusUITests: XCTestCase {
    
    func testUIModuleInitialization() {
        let uiModule = DogTVPlusUI()
        XCTAssertEqual(DogTVPlusUI.version, "1.0.0")
    }
}
