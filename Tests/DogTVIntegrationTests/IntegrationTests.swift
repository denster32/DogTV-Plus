import XCTest
@testable import DogTVCore
@testable import DogTVData

@MainActor
final class IntegrationTests: XCTestCase {

    var contentService: ContentService!
    var audioService: AudioService!
    var settingsService: SettingsService!
    var analyticsService: AnalyticsService!
    var mockUserDefaults: UserDefaults!

    override func setUp() {
        super.setUp()

        // Use a mock UserDefaults to avoid interfering with actual app settings
        mockUserDefaults = UserDefaults(suiteName: #file)
        mockUserDefaults.removePersistentDomain(forName: #file)

        // Initialize services
        let mockLoader = MockSceneLoader()
        let testScene = try! Scene(name: "Integration Test Scene", type: .forest, description: "A scene for testing", duration: 120, isActive: true, metadata: .init(author: "tester", creationDate: Date()))
        mockLoader.scenesToLoad = [testScene]

        contentService = ContentService(sceneLoader: mockLoader)
        settingsService = SettingsService(userDefaults: mockUserDefaults)
        audioService = AudioService(settings: settingsService.audioSettings)
        analyticsService = AnalyticsService()
    }

    override func tearDown() {
        contentService = nil
        audioService = nil
        settingsService = nil
        analyticsService = nil
        mockUserDefaults.removePersistentDomain(forName: #file)
        mockUserDefaults = nil
        super.tearDown()
    }

    func testScenePlaybackAffectsAnalytics() async {
        // 1. Load scenes
        await contentService.loadScenes()
        guard let scene = contentService.availableScenes.first else {
            XCTFail("Should have loaded a scene")
            return
        }

        // 2. Start a session
        analyticsService.startSession(userID: "integration_test_user")

        // 3. Start a scene
        contentService.startScene(scene)

        // 4. Track scene usage in analytics
        analyticsService.trackSceneUsage(sceneType: scene.type)

        // 5. Verify analytics were updated
        XCTAssertEqual(analyticsService.usageStatistics.sceneUsageCounts[scene.type.rawValue], 1)
    }

    func testSettingsChangeAffectsAudioService() async {
        // 1. Change a setting
        var newSettings = settingsService.audioSettings
        newSettings.volume = 0.123
        settingsService.audioSettings = newSettings
        settingsService.saveSettings()

        // 2. Update AudioService with the new settings
        await audioService.updateAudioSettings(settingsService.audioSettings)

        // 3. Verify AudioService has the new setting
        XCTAssertEqual(audioService.volume, 0.123)
    }

    func testContentAndSettingsIntegration() async {
        // 1. Load scenes
        await contentService.loadScenes()
        guard let scene = contentService.availableScenes.first else {
            XCTFail("Should have loaded a scene")
            return
        }

        // 2. Set a preferred scene in settings
        var prefs = settingsService.userPreferences
        prefs.preferredScenes.append(scene.id)
        settingsService.userPreferences = prefs
        settingsService.saveSettings()

        // 3. Use ContentService's business logic to recommend a scene
        let recommendedScene = contentService.recommendNextScene(userPreferences: settingsService.userPreferences)

        // 4. Verify the recommended scene is the one from settings
        XCTAssertEqual(recommendedScene?.id, scene.id)
    }
}
