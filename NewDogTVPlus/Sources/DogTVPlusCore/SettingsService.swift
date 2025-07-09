import Foundation
import Combine

/// Settings service for managing user preferences and app settings
@available(iOS 17.0, tvOS 17.0, macOS 10.15, *)
@MainActor
public class SettingsService: ObservableObject {
    @Published public var audioSettings: AudioSettings = .default
    @Published public var appSettings: AppSettings = .default
    @Published public var error: SettingsError?
    
    private let userDefaults = UserDefaults.standard
    private var cancellables = Set<AnyCancellable>()
    
    // UserDefaults keys
    private enum Keys {
        static let audioSettings = "audioSettings"
        static let appSettings = "appSettings"
    }
    
    public init() {
        Task {
            try? await loadSettings()
        }
    }
    
    // MARK: - Public Methods
    
    /// Load settings from UserDefaults
    public func loadSettings() async throws {
        do {
            error = nil
            
            // Load audio settings
            if let audioData = userDefaults.data(forKey: Keys.audioSettings) {
                audioSettings = try JSONDecoder().decode(AudioSettings.self, from: audioData)
            } else {
                audioSettings = .default
            }
            
            // Load app settings
            if let appData = userDefaults.data(forKey: Keys.appSettings) {
                appSettings = try JSONDecoder().decode(AppSettings.self, from: appData)
            } else {
                appSettings = .default
            }
            
        } catch {
            self.error = .loadingFailed
            throw SettingsError.loadingFailed
        }
    }
    
    /// Save settings to UserDefaults
    public func saveSettings() async throws {
        do {
            error = nil
            
            // Save audio settings
            let audioData = try JSONEncoder().encode(audioSettings)
            userDefaults.set(audioData, forKey: Keys.audioSettings)
            
            // Save app settings
            let appData = try JSONEncoder().encode(appSettings)
            userDefaults.set(appData, forKey: Keys.appSettings)
            
        } catch {
            self.error = .savingFailed
            throw SettingsError.savingFailed
        }
    }
    
    /// Update audio settings
    public func updateAudioSettings(_ newSettings: AudioSettings) async throws {
        audioSettings = newSettings
        appSettings.audioSettings = newSettings
        try await saveSettings()
    }
    
    /// Update app settings
    public func updateAppSettings(_ newSettings: AppSettings) async throws {
        appSettings = newSettings
        audioSettings = newSettings.audioSettings
        try await saveSettings()
    }
    
    /// Reset to defaults
    public func resetToDefaults() async throws {
        audioSettings = .default
        appSettings = .default
        try await saveSettings()
    }
}

// MARK: - Settings Error
public enum SettingsError: Error, LocalizedError {
    case loadingFailed
    case savingFailed
    case invalidData
    case unknown
    
    public var errorDescription: String? {
        switch self {
        case .loadingFailed:
            return "Failed to load settings"
        case .savingFailed:
            return "Failed to save settings"
        case .invalidData:
            return "Invalid settings data"
        case .unknown:
            return "Unknown settings error"
        }
    }
}
