// swiftlint:disable import_organization mark_usage file_length
import Foundation
import SwiftUI
import AVFoundation
// swiftlint:enable import_organization

// MARK: - Core Data Models

/// Main scene model for DogTV+ content
public struct Scene: Identifiable, Codable, Sendable {
    public let id: UUID
    public let name: String
    public let description: String
    public let type: SceneType
    public let metadata: SceneMetadata
    public let tags: Set<String>
    public let duration: TimeInterval
    public let isActive: Bool
    
    public init(id: UUID = UUID(), name: String, description: String, type: SceneType, metadata: SceneMetadata, tags: Set<String> = [], duration: TimeInterval = 300.0, isActive: Bool = true) {
        self.id = id
        self.name = name
        self.description = description
        self.type = type
        self.metadata = metadata
        self.tags = tags
        self.duration = duration
        self.isActive = isActive
    }
    
    // Safe example creation without force unwrap
    public static let example: Scene = {
        let metadata = SceneMetadata(
            visualIntensity: 0.7,
            audioIntensity: 0.5,
            audioFile: "forest_ambience.mp3",
            colorPalette: ["#2E8B57", "#228B22", "#32CD32"],
            motionLevel: 0.3,
            complexity: 0.6
        )
        
        return Scene(
            name: "Forest Walk",
            description: "A peaceful walk through a serene forest",
            type: .relaxation,
            metadata: metadata,
            tags: ["nature", "forest", "relaxing"],
            duration: 300.0
        )
    }()
}

/// Scene type classification
public enum SceneType: String, CaseIterable, Codable, Sendable {
    case relaxation = "relaxation"
    case stimulation = "stimulation"
    case sleep = "sleep"
    case exercise = "exercise"
    case training = "training"
    case therapy = "therapy"
    
    public var displayName: String {
        switch self {
        case .relaxation: return "Relaxation"
        case .stimulation: return "Stimulation"
        case .sleep: return "Sleep"
        case .exercise: return "Exercise"
        case .training: return "Training"
        case .therapy: return "Therapy"
        }
    }
}

/// Scene metadata for configuration
public struct SceneMetadata: Codable, Sendable {
    public let visualIntensity: Double
    public let audioIntensity: Double
    public let audioFile: String
    public let colorPalette: [String]
    public let motionLevel: Double
    public let complexity: Double
    
    public init(visualIntensity: Double, audioIntensity: Double, audioFile: String, colorPalette: [String], motionLevel: Double, complexity: Double) {
        // Validate input ranges
        self.visualIntensity = max(0.0, min(1.0, visualIntensity))
        self.audioIntensity = max(0.0, min(1.0, audioIntensity))
        self.audioFile = audioFile
        self.colorPalette = colorPalette
        self.motionLevel = max(0.0, min(1.0, motionLevel))
        self.complexity = max(0.0, min(1.0, complexity))
    }
}

/// Accessibility settings for inclusive design
public struct AccessibilitySettings: Codable, Sendable {
    public let fontScale: Double
    public let highContrast: Bool
    public let reduceMotion: Bool
    public let voiceOverEnabled: Bool
    public let switchControlEnabled: Bool
    
    public init(fontScale: Double = 1.0, highContrast: Bool = false, reduceMotion: Bool = false, voiceOverEnabled: Bool = false, switchControlEnabled: Bool = false) {
        // Validate font scale range
        self.fontScale = max(0.5, min(2.0, fontScale))
        self.highContrast = highContrast
        self.reduceMotion = reduceMotion
        self.voiceOverEnabled = voiceOverEnabled
        self.switchControlEnabled = switchControlEnabled
    }
    
    // Safe default creation
    public static let `default` = AccessibilitySettings()
}

/// User preferences and settings
public struct UserPreferences: Codable, Sendable {
    public let preferredScenes: [UUID]
    public let accessibilitySettings: AccessibilitySettings
    public let audioSettings: AudioSettings
    public let notificationSettings: NotificationSettings
    public let privacySettings: PrivacySettings
    
    public init(preferredScenes: [UUID] = [], accessibilitySettings: AccessibilitySettings = .default, audioSettings: AudioSettings = .default, notificationSettings: NotificationSettings = .default, privacySettings: PrivacySettings = .default) {
        self.preferredScenes = preferredScenes
        self.accessibilitySettings = accessibilitySettings
        self.audioSettings = audioSettings
        self.notificationSettings = notificationSettings
        self.privacySettings = privacySettings
    }
    
    // Safe default creation
    public static let `default` = UserPreferences()
}

/// Audio settings configuration
public struct AudioSettings: Codable, Sendable {
    public let isEnabled: Bool
    public let volume: Float
    public let equalizerSettings: EqualizerSettings
    public let spatialAudioEnabled: Bool
    public let canineOptimizationEnabled: Bool
    
    public init(isEnabled: Bool = true, volume: Float = 0.7, equalizerSettings: EqualizerSettings = .default, spatialAudioEnabled: Bool = true, canineOptimizationEnabled: Bool = true) {
        self.isEnabled = isEnabled
        self.volume = max(0.0, min(1.0, volume))
        self.equalizerSettings = equalizerSettings
        self.spatialAudioEnabled = spatialAudioEnabled
        self.canineOptimizationEnabled = canineOptimizationEnabled
    }
    
    public static let `default` = AudioSettings()
}

/// Equalizer settings for audio processing
public struct EqualizerSettings: Codable, Sendable {
    public let lowGain: Float
    public let midGain: Float
    public let highGain: Float
    public let bassBoost: Float
    public let trebleBoost: Float
    
    public init(lowGain: Float = 0.0, midGain: Float = 0.0, highGain: Float = 0.0, bassBoost: Float = 0.0, trebleBoost: Float = 0.0) {
        let gainRange: ClosedRange<Float> = -12.0...12.0
        self.lowGain = max(gainRange.lowerBound, min(gainRange.upperBound, lowGain))
        self.midGain = max(gainRange.lowerBound, min(gainRange.upperBound, midGain))
        self.highGain = max(gainRange.lowerBound, min(gainRange.upperBound, highGain))
        self.bassBoost = max(0.0, min(12.0, bassBoost))
        self.trebleBoost = max(0.0, min(12.0, trebleBoost))
    }
    
    public static let `default` = EqualizerSettings()
}

/// Notification settings
public struct NotificationSettings: Codable, Sendable {
    public let pushNotificationsEnabled: Bool
    public let emailNotificationsEnabled: Bool
    public let reminderNotificationsEnabled: Bool
    public let marketingNotificationsEnabled: Bool
    
    public init(pushNotificationsEnabled: Bool = true, emailNotificationsEnabled: Bool = false, reminderNotificationsEnabled: Bool = true, marketingNotificationsEnabled: Bool = false) {
        self.pushNotificationsEnabled = pushNotificationsEnabled
        self.emailNotificationsEnabled = emailNotificationsEnabled
        self.reminderNotificationsEnabled = reminderNotificationsEnabled
        self.marketingNotificationsEnabled = marketingNotificationsEnabled
    }
    
    public static let `default` = NotificationSettings()
}

/// Privacy settings for data protection
public struct PrivacySettings: Codable, Sendable {
    public let analyticsEnabled: Bool
    public let crashReportingEnabled: Bool
    public let personalizedContentEnabled: Bool
    public let dataSharingEnabled: Bool
    
    public init(analyticsEnabled: Bool = true, crashReportingEnabled: Bool = true, personalizedContentEnabled: Bool = true, dataSharingEnabled: Bool = false) {
        self.analyticsEnabled = analyticsEnabled
        self.crashReportingEnabled = crashReportingEnabled
        self.personalizedContentEnabled = personalizedContentEnabled
        self.dataSharingEnabled = dataSharingEnabled
    }
    
    public static let `default` = PrivacySettings()
}

// MARK: - Device and Platform Models

/// Device type enumeration
public enum DeviceType: String, CaseIterable, Codable, Sendable {
    case iPhone = "iPhone"
    case iPad = "iPad"
    case appleTV = "Apple TV"
    case mac = "Mac"
    case appleWatch = "Apple Watch"
    case visionPro = "Vision Pro"
    
    public var displayName: String {
        switch self {
        case .iPhone: return "iPhone"
        case .iPad: return "iPad"
        case .appleTV: return "Apple TV"
        case .mac: return "Mac"
        case .appleWatch: return "Apple Watch"
        case .visionPro: return "Vision Pro"
        }
    }
}

/// Platform enumeration
public enum Platform: String, CaseIterable, Codable, Sendable {
    case iOS = "iOS"
    case tvOS = "tvOS"
    case macOS = "macOS"
    case watchOS = "watchOS"
    case visionOS = "visionOS"
    
    public var displayName: String {
        switch self {
        case .iOS: return "iOS"
        case .tvOS: return "tvOS"
        case .macOS: return "macOS"
        case .watchOS: return "watchOS"
        case .visionOS: return "visionOS"
        }
    }
}

// MARK: - Content Action Models

/// Content interaction actions
public enum ContentAction: String, CaseIterable, Codable, Sendable {
    case play = "play"
    case pause = "pause"
    case stop = "stop"
    case complete = "complete"
    case favorite = "favorite"
    case share = "share"
    case skip = "skip"
    case rewind = "rewind"
    case fastForward = "fast_forward"
    
    public var displayName: String {
        switch self {
        case .play: return "Play"
        case .pause: return "Pause"
        case .stop: return "Stop"
        case .complete: return "Complete"
        case .favorite: return "Favorite"
        case .share: return "Share"
        case .skip: return "Skip"
        case .rewind: return "Rewind"
        case .fastForward: return "Fast Forward"
        }
    }
}

/// Business event types
public enum BusinessEventType: String, CaseIterable, Codable, Sendable {
    case appLaunch = "app_launch"
    case appBackground = "app_background"
    case subscription = "subscription"
    case purchase = "purchase"
    case settingsChanged = "settings_changed"
    case securityStatusChanged = "security_status_changed"
    case complianceStatusChanged = "compliance_status_changed"
    case localeChanged = "locale_changed"
    
    public var displayName: String {
        switch self {
        case .appLaunch: return "App Launch"
        case .appBackground: return "App Background"
        case .subscription: return "Subscription"
        case .purchase: return "Purchase"
        case .settingsChanged: return "Settings Changed"
        case .securityStatusChanged: return "Security Status Changed"
        case .complianceStatusChanged: return "Compliance Status Changed"
        case .localeChanged: return "Locale Changed"
        }
    }
}

/// Performance metric types
public enum PerformanceMetricType: String, CaseIterable, Codable, Sendable {
    case frameRate = "frame_rate"
    case audioLatency = "audio_latency"
    case loadTime = "load_time"
    case memoryUsage = "memory_usage"
    case batteryUsage = "battery_usage"
    case networkLatency = "network_latency"
    
    public var displayName: String {
        switch self {
        case .frameRate: return "Frame Rate"
        case .audioLatency: return "Audio Latency"
        case .loadTime: return "Load Time"
        case .memoryUsage: return "Memory Usage"
        case .batteryUsage: return "Battery Usage"
        case .networkLatency: return "Network Latency"
        }
    }
} 