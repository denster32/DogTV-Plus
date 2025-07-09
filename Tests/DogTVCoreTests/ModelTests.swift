import Foundation
import XCTest

@testable import DogTVCore

final class ModelTests: XCTestCase {

    // MARK: - Scene Model Tests

    func testSceneCodable() throws {
        let metadata = SceneMetadata(author: "Test Author", creationDate: Date())
        let scene = try Scene(id: UUID(), name: "Test Scene", type: .ocean, description: "A test scene", duration: 60, isActive: true, metadata: metadata)

        let encodedData = try JSONEncoder().encode(scene)
        let decodedScene = try JSONDecoder().decode(Scene.self, from: encodedData)

        XCTAssertEqual(scene.id, decodedScene.id)
        XCTAssertEqual(scene.name, decodedScene.name)
        XCTAssertEqual(scene.type, decodedScene.type)
    }

    func testSceneValidation() {
        let validMetadata = SceneMetadata(author: "Author", creationDate: Date())
        // Test valid scene
        XCTAssertNoThrow(try Scene(name: "Valid Scene", type: .rain, description: "Valid desc", duration: 1, isActive: true, metadata: validMetadata))

        // Test invalid name (empty)
        XCTAssertThrowsError(try Scene(name: "", type: .rain, description: "desc", duration: 1, isActive: true, metadata: validMetadata))

        // Test invalid description (empty)
        XCTAssertThrowsError(try Scene(name: "Name", type: .rain, description: "", duration: 1, isActive: true, metadata: validMetadata))

        // Test invalid duration (zero)
        XCTAssertThrowsError(try Scene(name: "Name", type: .rain, description: "desc", duration: 0, isActive: true, metadata: validMetadata))
    }

    // MARK: - AudioSettings Model Tests

    func testAudioSettingsCodable() throws {
        let settings = try AudioSettings(volume: 0.5, isEnabled: true, frequencyRange: .high, includeNatureSounds: true, equalizerSettings: .default)

        let encodedData = try JSONEncoder().encode(settings)
        let decodedSettings = try JSONDecoder().decode(AudioSettings.self, from: encodedData)

        XCTAssertEqual(settings.volume, decodedSettings.volume)
        XCTAssertEqual(settings.frequencyRange, decodedSettings.frequencyRange)
    }

    func testAudioSettingsValidation() {
        // Test valid settings
        XCTAssertNoThrow(try AudioSettings.default)

        // Test invalid volume
        XCTAssertThrowsError(try AudioSettings(volume: -0.1, isEnabled: true, frequencyRange: .low, includeNatureSounds: false, equalizerSettings: .default))
        XCTAssertThrowsError(try AudioSettings(volume: 1.1, isEnabled: true, frequencyRange: .low, includeNatureSounds: false, equalizerSettings: .default))

        // Test invalid equalizer settings
        if let invalidEQ = try? EqualizerSettings(lowGain: 20.0, midGain: 0, highGain: 0) {
            XCTAssertThrowsError(try AudioSettings(volume: 0.5, isEnabled: true, frequencyRange: .low, includeNatureSounds: false, equalizerSettings: invalidEQ))
        } else {
            XCTFail("Failed to create invalid EqualizerSettings for testing.")
        }
    }

    // MARK: - UserPreferences Model Tests

    func testUserPreferencesCodable() throws {
        let preferences = try UserPreferences(preferredScenes: [UUID(), UUID()], autoPlay: true, sessionDuration: 3600, notificationsEnabled: false, accessibilitySettings: .default)

        let encodedData = try JSONEncoder().encode(preferences)
        let decodedPreferences = try JSONDecoder().decode(UserPreferences.self, from: encodedData)

        XCTAssertEqual(preferences.autoPlay, decodedPreferences.autoPlay)
        XCTAssertEqual(preferences.sessionDuration, decodedPreferences.sessionDuration)
    }

    func testUserPreferencesValidation() {
        // Test valid preferences
        XCTAssertNoThrow(try UserPreferences.default)

        // Test invalid session duration
        XCTAssertThrowsError(try UserPreferences(preferredScenes: [], autoPlay: true, sessionDuration: -100, notificationsEnabled: true, accessibilitySettings: .default))
    }

    // MARK: - AnalyticsModels Tests

    func testAnalyticsEventCodable() throws {
        let event = AnalyticsEvent(name: "test_event", timestamp: Date(), parameters: ["key": "value"])

        let encodedData = try JSONEncoder().encode(event)
        let decodedEvent = try JSONDecoder().decode(AnalyticsEvent.self, from: encodedData)

        XCTAssertEqual(event.name, decodedEvent.name)
        XCTAssertEqual(event.parameters["key"], decodedEvent.parameters["key"])
    }

    func testSessionDataCodable() throws {
        let session = SessionData(id: UUID(), userID: "test_user", startTime: Date(), endTime: Date())

        let encodedData = try JSONEncoder().encode(session)
        let decodedSession = try JSONDecoder().decode(SessionData.self, from: encodedData)

        XCTAssertEqual(session.id, decodedSession.id)
        XCTAssertEqual(session.userID, decodedSession.userID)
    }
}
