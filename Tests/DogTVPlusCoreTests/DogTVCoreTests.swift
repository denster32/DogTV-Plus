import XCTest
@testable import DogTVCore

@MainActor
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

    func testSceneModel() throws {
        let metadata = try SceneMetadata(
            audioFile: "test_audio",
            visualIntensity: 0.5,
            audioIntensity: 0.7,
            recommendedDuration: 300
        )
        
        let scene = try Scene(
            name: "Test Scene",
            description: "A test scene",
            type: .ocean,
            metadata: metadata,
            duration: 300,
            isActive: true
        )

        XCTAssertEqual(scene.name, "Test Scene")
        XCTAssertEqual(scene.duration, 300)
        XCTAssertEqual(scene.type, .ocean)
        XCTAssertEqual(scene.metadata.audioFile, "test_audio")
        XCTAssertEqual(scene.metadata.visualIntensity, 0.5)
        XCTAssertEqual(scene.metadata.audioIntensity, 0.7)
        XCTAssertEqual(scene.metadata.recommendedDuration, 300)
    }

    func testAudioSettingsModel() {
        var audioSettings = AudioSettings()
        audioSettings.volume = 0.8
        audioSettings.frequencyRange = .high
        audioSettings.includeNatureSounds = true

        XCTAssertEqual(audioSettings.volume, 0.8)
        XCTAssertEqual(audioSettings.frequencyRange, .high)
        XCTAssertTrue(audioSettings.includeNatureSounds)
    }

    func testUserPreferencesModel() throws {
        let preferences = try UserPreferences(
            preferredScenes: [],
            autoPlay: true,
            sessionDuration: 3600,
            notificationsEnabled: false,
            accessibilitySettings: AccessibilitySettings.default
        )

        XCTAssertTrue(preferences.autoPlay)
        XCTAssertEqual(preferences.sessionDuration, 3600)
        XCTAssertFalse(preferences.notificationsEnabled)
    }
}
