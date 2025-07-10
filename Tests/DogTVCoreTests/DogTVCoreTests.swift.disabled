import XCTest
@testable import DogTVCore

final class DogTVCoreTests: XCTestCase {

    func testDogTVCoreInitialization() {
        let core = DogTVCore.shared
        XCTAssertNotNil(core)
    }

    func testContentServiceInitialization() async {
        let core = DogTVCore.shared
        await core.initialize()
        XCTAssertNotNil(core.contentService)
    }

    func testAudioServiceInitialization() async {
        let core = DogTVCore.shared
        await core.initialize()
        XCTAssertNotNil(core.audioService)
    }

    func testSettingsServiceInitialization() async {
        let core = DogTVCore.shared
        await core.initialize()
        XCTAssertNotNil(core.settingsService)
    }

    func testSceneModel() {
        let scene = Scene(
            id: "test-scene",
            name: "Test Scene",
            description: "A test scene",
            duration: 300,
            visualEffects: [],
            audioEffects: [],
            difficulty: .beginner
        )

        XCTAssertEqual(scene.id, "test-scene")
        XCTAssertEqual(scene.name, "Test Scene")
        XCTAssertEqual(scene.duration, 300)
        XCTAssertEqual(scene.difficulty, .beginner)
    }

    func testAudioSettingsModel() {
        var audioSettings = AudioSettings()
        audioSettings.volume = 0.8
        audioSettings.frequencyRange = .canineOptimized
        audioSettings.enableSpatialAudio = true

        XCTAssertEqual(audioSettings.volume, 0.8)
        XCTAssertEqual(audioSettings.frequencyRange, .canineOptimized)
        XCTAssertTrue(audioSettings.enableSpatialAudio)
    }

    func testUserPreferencesModel() {
        var preferences = UserPreferences()
        preferences.preferredDifficulty = .intermediate
        preferences.enableNotifications = false
        preferences.autoPlayNextScene = true

        XCTAssertEqual(preferences.preferredDifficulty, .intermediate)
        XCTAssertFalse(preferences.enableNotifications)
        XCTAssertTrue(preferences.autoPlayNextScene)
    }
}
