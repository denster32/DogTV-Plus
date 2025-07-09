import Foundation

/// A service for managing user settings, including audio and general preferences.
@MainActor
public class SettingsService: ObservableObject {
    // MARK: - Published Properties

    @Published public var audioSettings: AudioSettings
    @Published public var userPreferences: UserPreferences
    @Published public private(set) var error: Error?

    // MARK: - Private Properties

    private let audioSettingsKey = "audioSettings"
    private let userPreferencesKey = "userPreferences"
    private let userDefaults: UserDefaults
    private let audioSettingsCache = Cache<String, AudioSettings>()
    private let userPreferencesCache = Cache<String, UserPreferences>()
    private let analyticsService = AnalyticsService()

    // MARK: - Initialization

    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults

        // Load settings or use defaults
        self.audioSettings = SettingsService.load(forKey: audioSettingsKey, from: userDefaults) ?? .default
        self.userPreferences = SettingsService.load(forKey: userPreferencesKey, from: userDefaults) ?? .default
    }

    // MARK: - Public API

    /// Saves the current settings to UserDefaults.
    public func saveSettings() {
        do {
            try save(audioSettings, forKey: audioSettingsKey)
            try save(userPreferences, forKey: userPreferencesKey)

            // Update caches
            Task {
                await audioSettingsCache.insert(audioSettings, forKey: audioSettingsKey)
                await userPreferencesCache.insert(userPreferences, forKey: userPreferencesKey)
            }
            error = nil
            Task {
                await analyticsService.trackEvent(AnalyticsEvent(name: "settings_saved_successfully"))
            }
        } catch {
            self.error = error
            Task {
                await analyticsService.trackEvent(AnalyticsEvent(name: "settings_save_failed", parameters: ["error": error.localizedDescription]))
            }
        }
    }

    /// Resets all settings to their default values.
    public func resetSettings() {
        audioSettings = .default
        userPreferences = .default
        saveSettings()
        Task {
            await analyticsService.trackEvent(AnalyticsEvent(name: "settings_reset"))
        }
    }

    // MARK: - Audio Settings Management

    /// Updates the main volume.
    public func updateMainVolume(to volume: Float) {
        guard (0.0...1.0).contains(volume) else {
            self.error = SettingsError.validationFailed("Volume must be between 0.0 and 1.0.")
            return
        }
        audioSettings.volume = volume
        saveSettings()
        Task {
            await analyticsService.trackEvent(AnalyticsEvent(name: "master_volume_updated", parameters: ["volume": String(volume)]))
        }
    }

    /// Toggles the nature sounds on or off.
    public func toggleNatureSounds(on: Bool) {
        audioSettings.includeNatureSounds = on
        saveSettings()
        Task {
            await analyticsService.trackEvent(AnalyticsEvent(name: "nature_sounds_toggled", parameters: ["enabled": String(on)]))
        }
    }

    // MARK: - User Preferences Management

    /// Updates the color scheme for the app.
    public func updateColorScheme(to scheme: ColorScheme) {
        userPreferences.colorScheme = scheme
        saveSettings()
        Task {
            await analyticsService.trackEvent(AnalyticsEvent(name: "color_scheme_updated", parameters: ["scheme": scheme.rawValue]))
        }
    }

    /// Toggles high contrast mode on or off.
    public func toggleHighContrast(on: Bool) {
        userPreferences.isHighContrastEnabled = on
        saveSettings()
        Task {
            await analyticsService.trackEvent(AnalyticsEvent(name: "high_contrast_toggled", parameters: ["enabled": String(on)]))
        }
    }

    // MARK: - Caching

    /// Caches the current settings.
    private func cacheSettings() {
        Task {
            await audioSettingsCache.insert(audioSettings, forKey: audioSettingsKey)
            await userPreferencesCache.insert(userPreferences, forKey: userPreferencesKey)
        }
    }

    // MARK: - Persistence

    /// Saves a Codable object to UserDefaults.
    private func save<T: Codable>(_ object: T, forKey key: String) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(object)
        userDefaults.set(data, forKey: key)
    }

    /// Loads a Codable object from UserDefaults.
    private static func load<T: Codable>(forKey key: String, from userDefaults: UserDefaults) -> T? {
        guard let data = userDefaults.data(forKey: key) else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode(T.self, from: data)
    }
}

// MARK: - SettingsError

/// Custom errors for the SettingsService.
public enum SettingsError: Error, LocalizedError {
    case validationFailed(String)

    public var errorDescription: String? {
        switch self {
        case .validationFailed(let message):
            return message
        }
    }
}
