import Foundation
import Combine

/// DogTVCore - Core business logic and services for DogTV+
/// A clean, simple implementation focused on canine entertainment
@available(iOS 17.0, tvOS 17.0, macOS 10.15, *)
@MainActor
public final class DogTVCore: ObservableObject {
// MARK: - Shared Instance

    public static let shared = DogTVCore()

// MARK: - Services

    public let contentService = ContentService()
    public let audioService = AudioService()
    public let settingsService = SettingsService()
    public let analyticsService = AnalyticsService()

    private init() {
        // Private initializer for singleton
    }

// MARK: - Public Methods

    /// Initialize the core system
    public func initialize() async {
        // Load content
        await contentService.loadScenes()

        // Apply audio settings
        audioService.updateAudioSettings(settingsService.audioSettings)
    }

    /// Start a scene with audio
    public func startScene(_ scene: Scene) async throws {
        // Start content
        try await contentService.startScene(scene)

        // Start audio if enabled
        if settingsService.audioSettings.isEnabled, let audioURL = scene.metadata.highQualityAudioURL {
            audioService.playAudio(from: audioURL)
        }

        // Update session state - use scene ID as session identifier
        analyticsService.startSession(userID: scene.id.uuidString)
    }

    /// Stop current scene
    public func stopScene() async throws {
        // Stop audio
        audioService.stopAudio()

        // Stop content
        try await contentService.stopScene()

        // End session
        analyticsService.endSession()
    }

    /// Get current playing scene
    public var currentScene: Scene? {
        contentService.currentScene
    }

    /// Check if playing
    public var isPlaying: Bool {
        audioService.isPlaying && contentService.currentScene != nil
    }
}
