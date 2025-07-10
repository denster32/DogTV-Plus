// swiftlint:disable import_organization mark_usage
import Foundation
// swiftlint:enable import_organization

// MARK: - App State Model
public struct AppState: Codable {
    public var currentScene: UUID?
    public var isPlaying: Bool
    public var sessionStartTime: Date?
    public var totalUsageTime: TimeInterval

    public init(currentScene: UUID? = nil, isPlaying: Bool = false, sessionStartTime: Date? = nil, totalUsageTime: TimeInterval = 0) {
        self.currentScene = currentScene
        self.isPlaying = isPlaying
        self.sessionStartTime = sessionStartTime
        self.totalUsageTime = totalUsageTime
    }

    @MainActor public static let `default` = AppState()
}

// MARK: - Scene Model
public struct Scene: Codable, Identifiable, Hashable, Sendable {
    public let id: UUID
    public let name: String
    public let description: String
    public let type: SceneType
    public let metadata: SceneMetadata
    public let duration: TimeInterval
    public let isActive: Bool

    public init(id: UUID = UUID(), name: String, description: String, type: SceneType, metadata: SceneMetadata, duration: TimeInterval, isActive: Bool = true) throws {
        self.id = id
        self.name = name
        self.description = description
        self.type = type
        self.metadata = metadata
        self.duration = duration
        self.isActive = isActive

        try self.validate()
    }

    public func validate() throws {
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw ValidationError.emptyOrWhitespace("name")
        }
        if description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw ValidationError.emptyOrWhitespace("description")
        }
        if duration <= 0 {
            throw ValidationError.invalidValue("duration", "must be greater than 0")
        }
    }

    public static let example = try! Scene(
        name: "Forest Walk",
        description: "A peaceful walk through a serene forest with gentle nature sounds",
        type: .forest,
        metadata: SceneMetadata(
            audioFile: "forest_ambience",
            visualIntensity: 0.3,
            audioIntensity: 0.4,
            recommendedDuration: 1800
        ),
        duration: 1800
    )
}

// MARK: - Scene Type
public enum SceneType: String, Codable, CaseIterable, Sendable {
    case forest
    case ocean
    case rain
    case fireflies
    case stars
    case sunset
    case custom
}

// MARK: - Scene Metadata
public struct SceneMetadata: Codable, Sendable, Hashable {
    public let audioFile: String
    public let visualIntensity: Double
    public let audioIntensity: Double
    public let recommendedDuration: TimeInterval

    public init(audioFile: String, visualIntensity: Double, audioIntensity: Double, recommendedDuration: TimeInterval) throws {
        self.audioFile = audioFile
        self.visualIntensity = visualIntensity
        self.audioIntensity = audioIntensity
        self.recommendedDuration = recommendedDuration

        try self.validate()
    }

    public func validate() throws {
        if audioFile.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw ValidationError.emptyOrWhitespace("audioFile")
        }
        if !(0.0...1.0).contains(visualIntensity) {
            throw ValidationError.invalidValue("visualIntensity", "must be between 0.0 and 1.0")
        }
        if !(0.0...1.0).contains(audioIntensity) {
            throw ValidationError.invalidValue("audioIntensity", "must be between 0.0 and 1.0")
        }
        if recommendedDuration <= 0 {
            throw ValidationError.invalidValue("recommendedDuration", "must be greater than 0")
        }
    }
}

// MARK: - ColorScheme
public enum ColorScheme: String, Codable, CaseIterable, Sendable {
    case light
    case dark
    case system
}

// MARK: - AccessibilitySettings
public struct AccessibilitySettings: Codable, Sendable, Hashable {
    public var highContrastEnabled: Bool
    public var reduceMotionEnabled: Bool
    public var fontScale: Double

    public static let `default`: AccessibilitySettings = {
        try! AccessibilitySettings(
            highContrastEnabled: false,
            reduceMotionEnabled: false,
            fontScale: 1.0
        )
    }()

    public init(highContrastEnabled: Bool, reduceMotionEnabled: Bool, fontScale: Double) throws {
        self.highContrastEnabled = highContrastEnabled
        self.reduceMotionEnabled = reduceMotionEnabled
        self.fontScale = fontScale
        try self.validate()
    }

    public func validate() throws {
        if !(0.5...2.0).contains(fontScale) {
            throw ValidationError.invalidValue("fontScale", "must be between 0.5 and 2.0")
        }
    }
}

// MARK: - UserPreferences
public struct UserPreferences: Codable, Sendable, Hashable {
    public var preferredScenes: [UUID]
    public var autoPlay: Bool
    public var sessionDuration: TimeInterval
    public var notificationsEnabled: Bool
    public var accessibilitySettings: AccessibilitySettings
    public var colorScheme: ColorScheme
    public var isHighContrastEnabled: Bool

    public static let `default` = try! UserPreferences(
        preferredScenes: [],
        autoPlay: true,
        sessionDuration: 3600,
        notificationsEnabled: true,
        accessibilitySettings: .default,
        colorScheme: .system,
        isHighContrastEnabled: false
    )

    public init(preferredScenes: [UUID], autoPlay: Bool, sessionDuration: TimeInterval, notificationsEnabled: Bool, accessibilitySettings: AccessibilitySettings, colorScheme: ColorScheme = .system, isHighContrastEnabled: Bool = false) throws {
        self.preferredScenes = preferredScenes
        self.autoPlay = autoPlay
        self.sessionDuration = sessionDuration
        self.notificationsEnabled = notificationsEnabled
        self.accessibilitySettings = accessibilitySettings
        self.colorScheme = colorScheme
        self.isHighContrastEnabled = isHighContrastEnabled

        try self.validate()
    }

    public func validate() throws {
        if sessionDuration < 300 {
            throw ValidationError.invalidValue("sessionDuration", "must be at least 300 seconds")
        }
        try accessibilitySettings.validate()
    }
}

// MARK: - Validation Error
public enum ValidationError: Error, LocalizedError, Equatable {
    case emptyOrWhitespace(String)
    case invalidValue(String, String)

    public var errorDescription: String? {
        switch self {
        case .emptyOrWhitespace(let field):
            return "Validation Error: The field '\(field)' cannot be empty or contain only whitespace."
        case .invalidValue(let field, let reason):
            return "Validation Error: The field '\(field)' has an invalid value. Reason: \(reason)."
        }
    }
}

// MARK: - Analytics Models (migrated from AnalyticsModels.swift)

public enum AnalyticsEvent: Equatable {
    case sessionStart(attributes: [AnyEquatable])
    case sessionEnd(attributes: [AnyEquatable])
    case event(name: String, attributes: [AnyEquatable]?)

    public static func == (lhs: AnalyticsEvent, rhs: AnalyticsEvent) -> Bool {
        switch (lhs, rhs) {
        case let (.sessionStart(a1), .sessionStart(a2)):
            return a1 == a2
        case let (.sessionEnd(a1), .sessionEnd(a2)):
            return a1 == a2
        case let (.event(n1, a1), .event(n2, a2)):
            return n1 == n2 && a1 == a2
        default:
            return false
        }
    }
}

public struct AnyEquatable: Equatable {
    private let value: Any
    private let equals: (Any) -> Bool

    public init<T: Equatable>(_ value: T) {
        self.value = value
        self.equals = { other in
            if let otherValue = other as? T {
                return value == otherValue
            }
            return false
        }
    }

    public static func == (lhs: AnyEquatable, rhs: AnyEquatable) -> Bool {
        lhs.equals(rhs.value)
    }
}

public struct SessionData: Codable, Sendable, Hashable {
    public let sessionID: UUID
    public let userID: String
    public let startTime: Date
    public var endTime: Date?
    public var duration: TimeInterval {
        guard let endTime = endTime else {
            return Date().timeIntervalSince(startTime)
        }
        return endTime.timeIntervalSince(startTime)
    }

    public init(userID: String, sessionID: UUID = UUID(), startTime: Date = Date()) {
        self.sessionID = sessionID
        self.userID = userID
        self.startTime = startTime
    }
}

public struct UsageStatistics: Codable, Sendable, Hashable {
    public var totalSessions: Int
    public var totalDuration: TimeInterval
    public var sceneUsageCounts: [String: Int] // SceneType.rawValue : Count

    public init(totalSessions: Int = 0, totalDuration: TimeInterval = 0, sceneUsageCounts: [String: Int] = [:]) {
        self.totalSessions = totalSessions
        self.totalDuration = totalDuration
        self.sceneUsageCounts = sceneUsageCounts
    }
}

// MARK: - Error Models (migrated from ErrorModels.swift)

public enum DogTVError: Error, LocalizedError, Equatable {
    // MARK: - Content Errors
    case sceneNotFound(UUID)
    case sceneLoadFailed(underlyingError: Error?)
    case invalidSceneData(String)
    case sceneTransitionFailed(from: UUID?, to: UUID)

    // MARK: - Audio Errors
    case audioEngineFailed(reason: String)
    case audioFileNotFound(String)
    case audioPlaybackFailed(Error?)
    case invalidAudioSettings(String)

    // MARK: - Data Persistence Errors
    case settingsSaveFailed(Error)
    case settingsLoadFailed(Error)
    case preferencesSaveFailed(Error)
    case preferencesLoadFailed(Error)
    case fileStorageError(description: String)

    // MARK: - Analytics Errors
    case analyticsEventFailed(String, Error?)

    // MARK: - Generic Errors
    case validationError(ValidationError)
    case unknown(Error?)

    public static func == (lhs: DogTVError, rhs: DogTVError) -> Bool {
        switch (lhs, rhs) {
        case let (.sceneNotFound(id1), .sceneNotFound(id2)):
            return id1 == id2
        case (.sceneLoadFailed, .sceneLoadFailed):
            return true // Consider comparing underlying errors if they are Equatable
        case let (.invalidSceneData(s1), .invalidSceneData(s2)):
            return s1 == s2
        case let (.sceneTransitionFailed(f1, t1), .sceneTransitionFailed(f2, t2)):
            return f1 == f2 && t1 == t2
        case let (.audioEngineFailed(r1), .audioEngineFailed(r2)):
            return r1 == r2
        case let (.audioFileNotFound(f1), .audioFileNotFound(f2)):
            return f1 == f2
        case (.audioPlaybackFailed, .audioPlaybackFailed):
            return true
        case let (.invalidAudioSettings(s1), .invalidAudioSettings(s2)):
            return s1 == s2
        case (.settingsSaveFailed, .settingsSaveFailed):
            return true
        case (.settingsLoadFailed, .settingsLoadFailed):
            return true
        case (.preferencesSaveFailed, .preferencesSaveFailed):
            return true
        case (.preferencesLoadFailed, .preferencesLoadFailed):
            return true
        case let (.fileStorageError(d1), .fileStorageError(d2)):
            return d1 == d2
        case let (.analyticsEventFailed(s1, _), .analyticsEventFailed(s2, _)):
            return s1 == s2
        case let (.validationError(v1), .validationError(v2)):
            return v1 == v2
        case (.unknown, .unknown):
            return true
        default:
            return false
        }
    }

    public var errorDescription: String? {
        switch self {
        // Content Errors
        case .sceneNotFound(let id):
            return contentErrorDescription(for: .sceneNotFound(id))
        case .sceneLoadFailed(let error):
            return contentErrorDescription(for: .sceneLoadFailed(underlyingError: error))
        case .invalidSceneData(let details):
            return contentErrorDescription(for: .invalidSceneData(details))
        case .sceneTransitionFailed(let from, let to):
            return contentErrorDescription(for: .sceneTransitionFailed(from: from, to: to))

        // Audio Errors
        case .audioEngineFailed(let reason):
            return audioErrorDescription(for: .audioEngineFailed(reason: reason))
        case .audioFileNotFound(let fileName):
            return audioErrorDescription(for: .audioFileNotFound(fileName))
        case .audioPlaybackFailed(let error):
            return audioErrorDescription(for: .audioPlaybackFailed(error))
        case .invalidAudioSettings(let reason):
            return audioErrorDescription(for: .invalidAudioSettings(reason))

        // Data Persistence & Analytics Errors
        case .settingsSaveFailed, .settingsLoadFailed, .preferencesSaveFailed, .preferencesLoadFailed, .fileStorageError, .analyticsEventFailed:
            return systemErrorDescription(for: self)

        // Generic Errors
        case .validationError(let validationError):
            return "Validation Error: \(validationError.localizedDescription)"
        case .unknown(let error):
            let reason = error?.localizedDescription ?? "An unknown error occurred."
            return "Unknown Error: \(reason)"
        }
    }

    private func contentErrorDescription(for error: DogTVError) -> String {
        switch error {
        case .sceneNotFound(let id):
            return "Content Error: A scene with ID '\(id)' could not be found."
        case .sceneLoadFailed(let error):
            let reason = error?.localizedDescription ?? "No specific reason provided."
            return "Content Error: Failed to load scene assets. Reason: \(reason)"
        case .invalidSceneData(let details):
            return "Content Error: Scene data is invalid. Details: \(details)"
        case .sceneTransitionFailed(let from, let to):
            let fromScene = from?.uuidString ?? "None"
            return "Content Error: Failed to transition from scene \(fromScene) to \(to.uuidString)."
        default:
            return "Unknown content error"
        }
    }

    private func audioErrorDescription(for error: DogTVError) -> String {
        switch error {
        case .audioEngineFailed(let reason):
            return "Audio Error: The audio engine failed. Reason: \(reason)"
        case .audioFileNotFound(let fileName):
            return "Audio Error: The audio file '\(fileName)' was not found."
        case .audioPlaybackFailed(let error):
            let reason = error?.localizedDescription ?? "No specific reason provided."
            return "Audio Error: Audio playback failed unexpectedly. Reason: \(reason)"
        case .invalidAudioSettings(let reason):
            return "Audio Error: The provided audio settings are invalid. \(reason)"
        default:
            return "Unknown audio error"
        }
    }

    private func systemErrorDescription(for error: DogTVError) -> String {
        switch error {
        case .settingsSaveFailed(let error):
            return "Data Persistence Error: Failed to save settings. Error: \(error.localizedDescription)"
        case .settingsLoadFailed(let error):
            return "Data Persistence Error: Failed to load settings. Error: \(error.localizedDescription)"
        case .preferencesSaveFailed(let error):
            return "Data Persistence Error: Failed to save preferences. Error: \(error.localizedDescription)"
        case .preferencesLoadFailed(let error):
            return "Data Persistence Error: Failed to load preferences. Error: \(error.localizedDescription)"
        case .fileStorageError(let description):
            return "File Storage Error: \(description)"
        case let (.analyticsEventFailed(event, error)):
            let reason = error?.localizedDescription ?? "No specific reason provided."
            return "Analytics Error: Failed to log event '\(event)'. Reason: \(reason)"
        default:
            return "Unknown system error"
        }
    }
}
// swiftlint:enable mark_usage 