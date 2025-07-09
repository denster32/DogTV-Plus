// swiftlint:disable import_organization mark_usage
import Foundation
// swiftlint:enable import_organization

/// Manages the lifecycle of scenes, including loading, playing, and transitioning.
@MainActor
public class ContentService: ObservableObject {

    // MARK: - Published Properties

    @Published public private(set) var currentScene: Scene?
    @Published public private(set) var availableScenes: [Scene] = []
    @Published public private(set) var isPlaying: Bool = false
    @Published public private(set) var error: DogTVError?

    // MARK: - Private Properties

    private var sceneLoader: SceneLoading

    // MARK: - Initialization

    public init(sceneLoader: SceneLoading = DefaultSceneLoader()) {
        self.sceneLoader = sceneLoader
    }

    // MARK: - Public API

    /// Loads all available scenes from the scene loader.
    public func loadScenes() async {
        do {
            self.availableScenes = try await sceneLoader.loadScenes()
            self.error = nil
        } catch let error as DogTVError {
            self.error = error
        } catch {
            self.error = .sceneLoadFailed(underlyingError: error)
        }
    }

    /// Starts playing a specified scene.
    /// - Parameter scene: The scene to start.
    public func startScene(_ scene: Scene) async throws {
        try validateScene(scene)
        transitionTo(scene: scene)
        self.error = nil
    }

    /// Stops the currently playing scene.
    public func stopScene() async throws {
        currentScene = nil
        isPlaying = false
    }

    /// Pauses the currently playing scene.
    public func pauseScene() {
        guard isPlaying else { return }
        isPlaying = false
    }

    /// Resumes the currently paused scene.
    public func resumeScene() {
        guard !isPlaying, currentScene != nil else { return }
        isPlaying = true
    }

    // MARK: - Business Logic

    /// Selects the next scene based on user preferences and recommendations.
    /// - Returns: The recommended `Scene` to play next, or `nil` if none is available.
    public func recommendNextScene(userPreferences: UserPreferences) -> Scene? {
        let preferredScenes = availableScenes.filter { userPreferences.preferredScenes.contains($0.id) }

        if let nextPreferred = preferredScenes.first(where: { $0.id != currentScene?.id }) {
            return nextPreferred
        }

        // Simple rotation if no preferred scenes are next
        if let currentIndex = availableScenes.firstIndex(where: { $0.id == currentScene?.id }) {
            let nextIndex = (currentIndex + 1) % availableScenes.count
            return availableScenes[nextIndex]
        }

        return availableScenes.first
    }

    /// Schedules scenes to play based on the time of day.
    /// - Returns: A `Scene` appropriate for the current time, or `nil`.
    public func scheduleSceneForCurrentTime() -> Scene? {
        let hour = Calendar.current.component(.hour, from: Date())

        switch hour {
        case 6...11: // Morning
            return availableScenes.first { $0.type == .forest || $0.type == .ocean }
        case 12...17: // Afternoon
            return availableScenes.first { $0.type == .rain || $0.type == .sunset }
        case 18...22: // Evening
            return availableScenes.first { $0.type == .fireflies }
        default: // Night
            return availableScenes.first { $0.type == .stars }
        }
    }

    // MARK: - Scene Management Logic

    /// Validates a scene to ensure it can be played.
    /// - Parameter scene: The scene to validate.
    private func validateScene(_ scene: Scene) throws {
        guard availableScenes.contains(where: { $0.id == scene.id }) else {
            throw DogTVError.sceneNotFound(scene.id)
        }

        guard scene.isActive else {
            throw DogTVError.invalidSceneData("Scene is not active.")
        }
    }

    /// Handles the transition to a new scene.
    /// - Parameter scene: The new scene to transition to.
    private func transitionTo(scene: Scene) {
        // In a real app, this could involve complex animations or preloading.
        let fromSceneId = currentScene?.id
        currentScene = scene
        isPlaying = true

        // Log metadata
        print("Transitioned from scene \(fromSceneId?.uuidString ?? "None") to \(scene.id.uuidString)")
        print("Scene metadata: Author - \(scene.metadata.author), Created - \(scene.metadata.creationDate)")
    }
}

// MARK: - Scene State Management
public extension ContentService {
    /// Updates the state of the service based on the current scene.
    func updateState() {
        guard let currentScene = currentScene else {
            isPlaying = false
            return
        }

        if !currentScene.isActive {
            Task {
                try? await stopScene()
            }
        }
    }
}

// MARK: - Scene Loading Protocol

/// A protocol for objects that can load scenes.
public protocol SceneLoading: Sendable {
    func loadScenes() async throws -> [Scene]
}

// MARK: - Default Scene Loader

/// A default implementation of `SceneLoading` that loads scenes from a local JSON file.
public actor DefaultSceneLoader: SceneLoading {
    private let fileStorage = FileStorage(directoryName: "SceneData")
    private let scenesFileName = "scenes.json"
    private let cache = Cache<String, [Scene]>()

    public init() {} // Public initializer

    public func loadScenes() async throws -> [Scene] {
        // Check cache first
        if let cachedScenes = await cache.value(forKey: scenesFileName) {
            print("Loaded scenes from cache.")
            return cachedScenes
        }

        do {
            if let scenes: [Scene] = try await fileStorage.load(from: scenesFileName) {
                print("Loaded scenes from file.")
                // Validate scenes after loading
                try scenes.forEach { try $0.validate() }
                // Store in cache
                await cache.insert(scenes, forKey: scenesFileName)
                return scenes
            } else {
                print("No scenes file found. Loading mock scenes and saving to file.")
                let scenes = try mockScenes()
                try await fileStorage.save(scenes, to: scenesFileName)
                // Store in cache
                await cache.insert(scenes, forKey: scenesFileName)
                return scenes
            }
        } catch {
            throw DogTVError.sceneLoadFailed(underlyingError: error)
        }
    }

    private func mockScenes() throws -> [Scene] {
        let metadata = SceneMetadata(author: "DogTV", creationDate: Date())
        return [
            try Scene(name: "Ocean Calm", type: .ocean, description: "Gentle waves on a sunny beach.", duration: 1800, isActive: true, metadata: metadata),
            try Scene(name: "Forest Whispers", type: .forest, description: "A peaceful walk through a lush forest.", duration: 2400, isActive: true, metadata: metadata),
            try Scene(name: "Firefly Dance", type: .fireflies, description: "A magical night with dancing fireflies.", duration: 1200, isActive: true, metadata: metadata),
            try Scene(name: "Rainy Day", type: .rain, description: "Cozy up to the sound of gentle rain.", duration: 3600, isActive: true, metadata: metadata),
            try Scene(name: "Golden Sunset", type: .sunset, description: "Watch the sun dip below the horizon.", duration: 1500, isActive: true, metadata: metadata),
            try Scene(name: "Starry Night", type: .stars, description: "A clear night sky full of twinkling stars.", duration: 4800, isActive: true, metadata: metadata)
        ]
    }

    // MARK: - Data Management

    /// Migrates scene data if needed.
    public func migrate() async throws {
        // In a real app, check a version number and perform migration.
        print("Checking for scene data migrations...")
        // For now, we just reload and re-save.
        let scenes = try await loadScenes()
        try await fileStorage.save(scenes, to: scenesFileName)
        // Invalidate cache after migration
        await cache.removeValue(forKey: scenesFileName)
        print("Scene data migration complete.")
    }

    /// Backs up the scenes file.
    public func backup() async {
        _ = await fileStorage.backup(file: scenesFileName)
    }
}
// swiftlint:enable mark_usage
