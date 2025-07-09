import XCTest
@testable import DogTVPlusCore

final class DogTVPlusCoreTests: XCTestCase {
    
    @MainActor func testCoreInitialization() async {
        let core = DogTVPlusCore.shared
        XCTAssertNotNil(core)
        XCTAssertNotNil(core.contentService)
        XCTAssertNotNil(core.audioService)
        XCTAssertNotNil(core.settingsService)
    }
    
    func testContentSceneCreation() {
        let scene = ContentScene(
            name: "Test Scene",
            type: .ocean,
            description: "Test Description",
            duration: 300
        )
        
        XCTAssertEqual(scene.name, "Test Scene")
        XCTAssertEqual(scene.type, .ocean)
        XCTAssertEqual(scene.duration, 300)
        XCTAssertTrue(scene.isActive)
    }
    
    func testAudioSettings() {
        let settings = AudioSettings()
        
        XCTAssertEqual(settings.volume, 0.7)
        XCTAssertTrue(settings.isEnabled)
        XCTAssertEqual(settings.frequencyRange, .canineOptimized)
        XCTAssertTrue(settings.includeNatureSounds)
    }
}
