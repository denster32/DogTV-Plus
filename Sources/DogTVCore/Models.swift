import Foundation

// MARK: - Scene Model
// public struct Scene: Identifiable, Codable {
//     public let id: UUID
//     public let name: String
//     public let type: SceneType
//     public let description: String
//     public let duration: TimeInterval
//     public let isActive: Bool

//     public init(id: UUID = UUID(), name: String, type: SceneType, description: String, duration: TimeInterval, isActive: Bool = true) {
//         self.id = id
//         self.name = name
//         self.type = type
//         self.description = description
//         self.duration = duration
//         self.isActive = isActive
//     }
// }

// MARK: - Scene Type
// public enum SceneType: String, Codable, CaseIterable {
//     case ocean = "ocean"
//     case forest = "forest"
//     case fireflies = "fireflies"
//     case rain = "rain"
//     case meadow = "meadow"
//     case birds = "birds"

//     public var displayName: String {
//         switch self {
//         case .ocean: return "Ocean Waves"
//         case .forest: return "Forest Canopy"
//         case .fireflies: return "Fireflies"
//         case .rain: return "Gentle Rain"
//         case .meadow: return "Meadow"
//         case .birds: return "Birds"
//         }
//     }
// }

// MARK: - Audio Settings Model
// public struct AudioSettings: Codable {
//     public var volume: Float
//     public var isEnabled: Bool
//     public var frequencyRange: FrequencyRange
//     public var includeNatureSounds: Bool

//     public init(volume: Float = 0.7, isEnabled: Bool = true, frequencyRange: FrequencyRange = .canineOptimized, includeNatureSounds: Bool = true) {
//         self.volume = volume
//         self.isEnabled = isEnabled
//         self.frequencyRange = frequencyRange
//         self.includeNatureSounds = includeNatureSounds
//     }

//     public static let `default` = AudioSettings()
// }

// MARK: - Frequency Range
// public enum FrequencyRange: String, Codable, CaseIterable {
//     case full = "full"
//     case canineOptimized = "canineOptimized"
//     case lowFrequency = "lowFrequency"
//     case midFrequency = "midFrequency"

//     public var displayName: String {
//         switch self {
//         case .full: return "Full Range"
//         case .canineOptimized: return "Canine Optimized"
//         case .lowFrequency: return "Low Frequency"
//         case .midFrequency: return "Mid Frequency"
//         }
//     }

//     public var frequencyRange: (min: Float, max: Float) {
//         switch self {
//         case .full: return (20, 20000)
//         case .canineOptimized: return (67, 45000)
//         case .lowFrequency: return (20, 250)
//         case .midFrequency: return (250, 2000)
//         }
//     }
// }

// MARK: - User Preferences Model
// public struct UserPreferences: Codable {
//     public var preferredScenes: [UUID]
//     public var autoPlay: Bool
//     public var sessionDuration: TimeInterval
//     public var notificationsEnabled: Bool

//     public init(preferredScenes: [UUID] = [], autoPlay: Bool = false, sessionDuration: TimeInterval = 1800, notificationsEnabled: Bool = true) {
//         self.preferredScenes = preferredScenes
//         self.autoPlay = autoPlay
//         self.sessionDuration = sessionDuration
//         self.notificationsEnabled = notificationsEnabled
//     }

//     public static let `default` = UserPreferences()
// }

// MARK: - App State Model
// public struct AppState: Codable {
//     public var currentScene: UUID?
//     public var isPlaying: Bool
//     public var sessionStartTime: Date?
//     public var totalUsageTime: TimeInterval

//     public init(currentScene: UUID? = nil, isPlaying: Bool = false, sessionStartTime: Date? = nil, totalUsageTime: TimeInterval = 0) {
//         self.currentScene = currentScene
//         self.isPlaying = isPlaying
//         self.sessionStartTime = sessionStartTime
//         self.totalUsageTime = totalUsageTime
//     }

//     public static let `default` = AppState()
// }

// MARK: - Default Scenes
// public extension Scene {
//     static let defaultScenes: [Scene] = [
//         Scene(
//             name: "Ocean Waves",
//             type: .ocean,
//             description: "Gentle ocean waves with soothing blue colors",
//             duration: 3600
//         ),
//         Scene(
//             name: "Forest Canopy",
//             type: .forest,
//             description: "Swaying trees with dappled sunlight",
//             duration: 3600
//         ),
//         Scene(
//             name: "Fireflies",
//             type: .fireflies,
//             description: "Magical fireflies dancing in the evening",
//             duration: 1800
//         ),
//         Scene(
//             name: "Gentle Rain",
//             type: .rain,
//             description: "Peaceful rain drops with soft sounds",
//             duration: 2700
//         ),
//         Scene(
//             name: "Meadow",
//             type: .meadow,
//             description: "Colorful meadow with gentle movement",
//             duration: 3600
//         ),
//         Scene(
//             name: "Birds",
//             type: .birds,
//             description: "Birds flying with natural sounds",
//             duration: 2400
//         )
//     ]
// }
