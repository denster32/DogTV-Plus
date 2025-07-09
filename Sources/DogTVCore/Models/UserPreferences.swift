// swiftlint:disable import_organization mark_usage
import Foundation
// swiftlint:enable import_organization

// MARK: - ColorScheme

/// Defines the color scheme options for the app.
public enum ColorScheme: String, Codable, CaseIterable, Sendable {
    case light
    case dark
    case system
}

// MARK: - AccessibilitySettings

/// Defines settings related to accessibility features.
public struct AccessibilitySettings: Codable, Sendable, Hashable {
    /// Enables high-contrast UI elements.
    public var highContrastEnabled: Bool

    /// Reduces motion and animations.
    public var reduceMotionEnabled: Bool

    /// Font size scaling factor.
    public var fontScale: Double

    /// Default accessibility settings.
    public static let `default`: AccessibilitySettings = {
        // Using a throwing initializer in a context that doesn't handle errors,
        // so we use a non-throwing approach or handle the error gracefully.
        // For default values, we assume they are always valid.
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

/// Encapsulates user-specific preferences for the application.
public struct UserPreferences: Codable, Sendable, Hashable {
    public var preferredScenes: [UUID]
    public var autoPlay: Bool
    public var sessionDuration: TimeInterval // in seconds
    public var notificationsEnabled: Bool
    public var accessibilitySettings: AccessibilitySettings
    public var colorScheme: ColorScheme
    public var isHighContrastEnabled: Bool

    /// Default user preferences.
    public static let `default` = try! UserPreferences(
        preferredScenes: [],
        autoPlay: true,
        sessionDuration: 3600, // 1 hour
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
        if sessionDuration < 300 { // Minimum 5 minutes
            throw ValidationError.invalidValue("sessionDuration", "must be at least 300 seconds")
        }
        try accessibilitySettings.validate()
    }
}
// swiftlint:enable mark_usage
