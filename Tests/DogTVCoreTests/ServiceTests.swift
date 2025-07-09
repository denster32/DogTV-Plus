import XCTest
import Combine
@testable import DogTVCore
@testable import DogTVData

// Mock Scene Loader for testing ContentService
class MockSceneLoader: SceneLoading {
    var scenesToLoad: [Scene]?
    var errorToThrow: Error?

    func loadScenes() async throws -> [Scene] {
        if let error = errorToThrow {
            throw error
        }
        return scenesToLoad ?? []
    }
}

@MainActor
final class ServiceTests: XCTestCase {

    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        cancellables = []
    }

    // MARK: - ContentService Tests

    func testContentServiceLoadScenes() async {
        let mockLoader = MockSceneLoader()
        let testScene = try! Scene(name: "Test", type: .ocean, description: "Desc", duration: 10, isActive: true, metadata: .init(author: "a", creationDate: Date()))
        mockLoader.scenesToLoad = [testScene]

        let contentService = ContentService(sceneLoader: mockLoader)
        await contentService.loadScenes()

        XCTAssertEqual(contentService.availableScenes.count, 1)
        XCTAssertEqual(contentService.availableScenes.first?.name, "Test")
        XCTAssertNil(contentService.error)
    }

    func testContentServiceStartAndStopScene() async {
        let mockLoader = MockSceneLoader()
        let testScene = try! Scene(name: "Test", type: .ocean, description: "Desc", duration: 10, isActive: true, metadata: .init(author: "a", creationDate: Date()))
        mockLoader.scenesToLoad = [testScene]

        let contentService = ContentService(sceneLoader: mockLoader)
        await contentService.loadScenes()

        contentService.startScene(testScene)
        XCTAssertTrue(contentService.isPlaying)
        XCTAssertEqual(contentService.currentScene?.id, testScene.id)

        contentService.stopScene()
        XCTAssertFalse(contentService.isPlaying)
        XCTAssertNil(contentService.currentScene)
    }

    // MARK: - AudioService Tests

    func testAudioServicePlayAndStop() {
        let audioService = AudioService()

        // We can't easily test AVAudioEngine in unit tests without a host app.
        // So we'll test the state changes.
        let expectation = XCTestExpectation(description: "Audio starts playing")

        audioService.$isPlaying
            .dropFirst()
            .sink { isPlaying in
                if isPlaying {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // A dummy URL is needed, but it won't actually play.
        let dummyURL = URL(fileURLWithPath: "/dev/null")
        audioService.playAudio(from: dummyURL)

        // The state should reflect trying to play, even if it fails immediately.
        XCTAssertTrue(audioService.isPlaying)

        audioService.stopAudio()
        XCTAssertFalse(audioService.isPlaying)
    }

    // MARK: - SettingsService Tests

    func testSettingsServiceSaveAndLoad() {
        let mockUserDefaults = UserDefaults(suiteName: #file)!
        mockUserDefaults.removePersistentDomain(forName: #file)

        let settingsService = SettingsService(userDefaults: mockUserDefaults)

        let newVolume: Float = 0.25
        settingsService.audioSettings.volume = newVolume
        settingsService.saveSettings()

        // Create a new service to ensure it loads from our mock UserDefaults
        let newSettingsService = SettingsService(userDefaults: mockUserDefaults)
        XCTAssertEqual(newSettingsService.audioSettings.volume, newVolume)
    }

    // MARK: - AnalyticsService Tests

    func testAnalyticsServiceTrackEvent() async {
        let analyticsService = AnalyticsService()
        let event = AnalyticsEvent(name: "test_event", parameters: [:])

        await analyticsService.trackEvent(event)

        XCTAssertEqual(analyticsService.events.count, 1)
        XCTAssertEqual(analyticsService.events.first?.name, "test_event")
    }

    func testAnalyticsServiceSession() {
        let analyticsService = AnalyticsService()

        analyticsService.startSession(userID: "test_user")
        XCTAssertNotNil(analyticsService.currentSession)
        XCTAssertEqual(analyticsService.usageStatistics.totalSessions, 1)

        analyticsService.endSession()
        XCTAssertNil(analyticsService.currentSession)
    }
}
