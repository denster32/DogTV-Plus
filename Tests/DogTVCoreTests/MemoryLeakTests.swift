import XCTest
import SwiftUI
@testable import DogTVPlus

class MemoryLeakTests: XCTestCase {
    /// Measures memory usage for content loading to detect leaks or excessive consumption.
    func testContentLibraryMemoryUsage() {
        measure(metrics: [XCTMemoryMetric()]) {
            // Simulate heavy content library load
            let manager = ContentLibrarySystem()
            let contents = manager.fetchAllContent() // assume synchronous fetch for test
            XCTAssertNotNil(contents)
        }
    }
}
