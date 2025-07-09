import Foundation

// MARK: - Content Error
public enum ContentError: Error, LocalizedError {
    case sceneNotFound(UUID)
    case sceneLoadFailed(String)
    case invalidSceneData
    case sceneTransitionFailed

    public var errorDescription: String? {
        switch self {
        case .sceneNotFound(let id):
            return "Content Error: A scene with ID '\(id)' could not be found."
        case .sceneLoadFailed(let reason):
            return "Content Error: Failed to load scene assets. Reason: \(reason)"
        case .invalidSceneData:
            return "Content Error: Scene data is invalid."
        case .sceneTransitionFailed:
            return "Content Error: Failed to transition between scenes."
        }
    }
}

// MARK: - Audio Error
public enum AudioError: Error, LocalizedError {
    case audioEngineFailed(underlyingError: Error? = nil)
    case fileNotFound(String)
    case playbackFailed(underlyingError: Error? = nil)
    case settingsInvalid(String)

    public var errorDescription: String? {
        switch self {
        case .audioEngineFailed:
            return "Audio Error: The audio engine failed."
        case .fileNotFound(let fileName):
            return "Audio Error: The audio file '\(fileName)' was not found."
        case .playbackFailed:
            return "Audio Error: Audio playback failed unexpectedly."
        case .settingsInvalid(let reason):
            return "Audio Error: The provided audio settings are invalid. \(reason)"
        }
    }
}

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

    public var errorDescription: String? {
        switch self {
        // Content Errors
        case .sceneNotFound(let id):
            return "Content Error: A scene with ID '\(id)' could not be found."
        case .sceneLoadFailed:
            return "Content Error: Failed to load scene assets."
        case .invalidSceneData(let reason):
            return "Content Error: Scene data is invalid. \(reason)"
        case .sceneTransitionFailed(let (from, to)):
            return "Content Error: Failed to transition from scene \(from?.uuidString ?? "None") to \(to)."

        // Audio Errors
        case .audioEngineFailed(let reason):
            return "Audio Error: The audio engine failed. Reason: \(reason)"
        case .audioFileNotFound(let fileName):
            return "Audio Error: The audio file '\(fileName)' was not found."
        case .audioPlaybackFailed:
            return "Audio Error: Audio playback failed unexpectedly."
        case .invalidAudioSettings(let reason):
            return "Audio Error: The provided audio settings are invalid. \(reason)"

        // Data Persistence Errors
        case .settingsSaveFailed:
            return "Persistence Error: Could not save settings."
        case .settingsLoadFailed:
            return "Persistence Error: Could not load settings."
        case .preferencesSaveFailed:
            return "Persistence Error: Could not save user preferences."
        case .preferencesLoadFailed:
            return "Persistence Error: Could not load user preferences."
        case .fileStorageError(let description):
            return "Persistence Error: A file storage operation failed. \(description)"

        // Analytics Errors
        case .analyticsEventFailed(let eventName, _):
            return "Analytics Error: Failed to log the event '\(eventName)'."

        // Generic Errors
        case .validationError(let validationError):
            return validationError.localizedDescription
        case .unknown:
            return "An unknown error occurred."
        }
    }

    public static func == (lhs: DogTVError, rhs: DogTVError) -> Bool {
        lhs.localizedDescription == rhs.localizedDescription
    }
}
