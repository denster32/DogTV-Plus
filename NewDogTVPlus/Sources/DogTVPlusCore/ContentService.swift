import Foundation
import Combine

/// Content service for managing scenes and playback
@available(iOS 17.0, tvOS 17.0, macOS 10.15, *)
@MainActor
public class ContentService: ObservableObject {
    @Published public var currentScene: ContentScene?
    @Published public var availableScenes: [ContentScene] = []
    @Published public var contentState: ContentState = .idle
    @Published public var isLoading: Bool = false
    @Published public var error: ContentError?
    
    private var cancellables = Set<AnyCancellable>()
    
    public init() {
        loadScenes()
    }
    
    // MARK: - Public Methods
    
    /// Load available scenes
    public func loadScenes() {
        isLoading = true
        error = nil
        contentState = .loading
        
        // Simulate async loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.availableScenes = ContentScene.defaultScenes
            self.isLoading = false
            self.contentState = .idle
        }
    }
    
    /// Start playing a scene
    public func startScene(_ scene: ContentScene) async throws {
        do {
            isLoading = true
            error = nil
            contentState = .loading
            
            // Validate scene
            guard availableScenes.contains(where: { $0.id == scene.id }) else {
                throw ContentError.sceneNotFound
            }
            
            // Stop current scene if playing
            if currentScene != nil {
                try await stopCurrentScene()
            }
            
            // Start new scene
            currentScene = scene
            contentState = .playing(scene)
            
            // Simulate scene loading
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            
            isLoading = false
            
        } catch {
            isLoading = false
            contentState = .error(error.localizedDescription)
            self.error = error as? ContentError ?? .unknown
            throw error
        }
    }
    
    /// Stop current scene
    public func stopCurrentScene() async throws {
        currentScene = nil
        contentState = .stopped
    }
    
    /// Pause current scene
    public func pauseCurrentScene() async throws {
        guard let scene = currentScene else { return }
        contentState = .paused(scene)
    }
    
    /// Resume current scene
    public func resumeCurrentScene() async throws {
        guard let scene = currentScene else { return }
        contentState = .playing(scene)
    }
}

// MARK: - Content Error
public enum ContentError: Error, LocalizedError {
    case sceneNotFound
    case loadingFailed
    case playbackFailed
    case unknown
    
    public var errorDescription: String? {
        switch self {
        case .sceneNotFound:
            return "Scene not found"
        case .loadingFailed:
            return "Failed to load content"
        case .playbackFailed:
            return "Playback failed"
        case .unknown:
            return "Unknown error occurred"
        }
    }
}

// MARK: - Default Scenes
extension ContentScene {
    public static let defaultScenes: [ContentScene] = [
        ContentScene(
            name: "Ocean Waves",
            type: .ocean,
            description: "Calming ocean waves for relaxation",
            duration: 300
        ),
        ContentScene(
            name: "Forest Sounds",
            type: .forest,
            description: "Peaceful forest ambiance",
            duration: 300
        ),
        ContentScene(
            name: "Gentle Rain",
            type: .rain,
            description: "Soothing rain sounds",
            duration: 300
        ),
        ContentScene(
            name: "Meadow Breeze",
            type: .meadow,
            description: "Gentle meadow sounds",
            duration: 300
        ),
        ContentScene(
            name: "Bird Songs",
            type: .birds,
            description: "Natural bird songs",
            duration: 300
        ),
        ContentScene(
            name: "Fireflies",
            type: .fireflies,
            description: "Magical firefly ambiance",
            duration: 300
        )
    ]
}
