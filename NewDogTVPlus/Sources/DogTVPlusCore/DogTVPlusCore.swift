import Foundation
import Combine

/// DogTVPlusCore - Core business logic and services for DogTV+
/// A clean, simple implementation focused on canine entertainment
@available(iOS 17.0, tvOS 17.0, macOS 10.15, *)
@MainActor
public final class DogTVPlusCore: ObservableObject {
    
    // MARK: - Shared Instance
    public static let shared = DogTVPlusCore()
    
    // MARK: - Services
    public let contentService = ContentService()
    public let audioService = AudioService()
    public let settingsService = SettingsService()
    
    private init() {
        // Private initializer for singleton
    }
    
    // MARK: - Public Methods
    
    /// Initialize the core system
    public func initialize() async {
        do {
            // Load settings
            try await settingsService.loadSettings()
            
            // Load content
            contentService.loadScenes()
            
            // Apply audio settings
            try await audioService.updateAudioSettings(settingsService.audioSettings)
            
        } catch {
            print("Failed to initialize DogTVPlusCore: \(error)")
        }
    }
    
    /// Start a scene with audio
    public func startScene(_ scene: ContentScene) async throws {
        // Start content
        try await contentService.startScene(scene)
        
        // Start audio if enabled
        if settingsService.audioSettings.isEnabled {
            try await audioService.playAudio()
        }
        
        // Start visual rendering
        try await startVisualRendering(for: scene)
    }
    
    /// Stop current scene
    public func stopScene() async throws {
        try await contentService.stopCurrentScene()
        try await audioService.stopAudio()
    }
    
    // MARK: - Private Methods
    
    private func startVisualRendering(for scene: ContentScene) async throws {
        // Visual rendering will be handled by DogTVPlusVision module
    }
}
