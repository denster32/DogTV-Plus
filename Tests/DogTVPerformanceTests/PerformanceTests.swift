import XCTest
@testable import DogTVCore
@testable import DogTVAudio
@testable import DogTVVision

final class DogTVPerformanceTests: XCTestCase {
    func testPerformanceExample() {
        // Example performance benchmark placeholder
        measure {
            // Call a simple DogTVCore function to benchmark
            _ = DogTVCore.Constants.platformName
        }
    }
}
