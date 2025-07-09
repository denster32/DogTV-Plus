import Foundation

// MARK: - Comprehensive Error Types

/// A centralized enumeration for all potential errors within the DogTV+ application.
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
