import XCTest
@testable import DogTVPlusAudio

final class DogTVPlusAudioTests: XCTestCase {
    
    func testAudioModuleInitialization() {
        let audioModule = DogTVPlusAudio()
        XCTAssertEqual(DogTVPlusAudio.version, "1.0.0")
    }
}
