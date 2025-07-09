import Foundation

// MARK: - Content Scene Model (Renamed to avoid conflict with SwiftUI.Scene)
public struct ContentScene: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public let name: String
    public let type: SceneType
    public let description: String
    public let duration: TimeInterval
    public let isActive: Bool
    
    public init(id: UUID = UUID(), name: String, type: SceneType, description: String, duration: TimeInterval, isActive: Bool = true) {
        self.id = id
        self.name = name
        self.type = type
        self.description = description
        self.duration = duration
        self.isActive = isActive
    }
}

// MARK: - Scene Type
public enum SceneType: String, Codable, CaseIterable, Sendable {
    case ocean = "ocean"
    case forest = "forest"
    case fireflies = "fireflies"
    case rain = "rain"
    case meadow = "meadow"
    case birds = "birds"
    
    public var displayName: String {
        switch self {
        case .ocean: return "Ocean Waves"
        case .forest: return "Forest Canopy"
        case .fireflies: return "Fireflies"
        case .rain: return "Gentle Rain"
        case .meadow: return "Meadow"
        case .birds: return "Birds"
        }
    }
}

// MARK: - Audio Settings Model
public struct AudioSettings: Codable, Sendable {
    public var volume: Float
    public var isEnabled: Bool
    public var frequencyRange: FrequencyRange
    public var includeNatureSounds: Bool
    
    public init(volume: Float = 0.7, isEnabled: Bool = true, frequencyRange: FrequencyRange = .canineOptimized, includeNatureSounds: Bool = true) {
        self.volume = volume
        self.isEnabled = isEnabled
        self.frequencyRange = frequencyRange
        self.includeNatureSounds = includeNatureSounds
    }
    
    public static let `default` = AudioSettings()
}

// MARK: - Frequency Range
public enum FrequencyRange: String, Codable, CaseIterable, Sendable {
    case full = "full"
    case canineOptimized = "canineOptimized"
    case lowFrequency = "lowFrequency"
    case midFrequency = "midFrequency"
    
    public var displayName: String {
        switch self {
        case .full: return "Full Range"
        case .canineOptimized: return "Canine Optimized"
        case .lowFrequency: return "Low Frequency"
        case .midFrequency: return "Mid Frequency"
        }
    }
    
    public var frequencyRange: (min: Float, max: Float) {
        switch self {
        case .full: return (20, 20000)
        case .canineOptimized: return (67, 45000)
        case .lowFrequency: return (20, 250)
        case .midFrequency: return (250, 4000)
        }
    }
}

// MARK: - App Settings Model
public struct AppSettings: Codable, Sendable {
    public var audioSettings: AudioSettings
    public var autoPlay: Bool
    public var sceneDuration: TimeInterval
    public var preferredSceneTypes: [SceneType]
    
    public init(audioSettings: AudioSettings = .default, autoPlay: Bool = true, sceneDuration: TimeInterval = 300, preferredSceneTypes: [SceneType] = [.ocean, .forest]) {
        self.audioSettings = audioSettings
        self.autoPlay = autoPlay
        self.sceneDuration = sceneDuration
        self.preferredSceneTypes = preferredSceneTypes
    }
    
    public static let `default` = AppSettings()
}

// MARK: - Content State
public enum ContentState: Equatable {
    case idle
    case loading
    case playing(ContentScene)
    case paused(ContentScene)
    case stopped
    case error(String)
    
    public var isPlaying: Bool {
        if case .playing = self { return true }
        return false
    }
    
    public var currentScene: ContentScene? {
        switch self {
        case .playing(let scene), .paused(let scene):
            return scene
        default:
            return nil
        }
    }
}
