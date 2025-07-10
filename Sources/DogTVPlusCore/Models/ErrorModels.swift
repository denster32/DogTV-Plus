// swiftlint:disable import_organization mark_usage
import Foundation
// swiftlint:enable import_organization

/// Comprehensive error types for DogTV+
public enum DogTVError: Error, LocalizedError, Equatable {
    case sceneLoadFailed(underlyingError: Error)
    case sceneNotFound(String)
    case playbackFailed(underlyingError: Error)
    case audioInitializationFailed(underlyingError: Error)
    case premiumContentRequiresSubscription
    case subscriptionExpired
    case networkConnectionFailed
    case invalidUserData(String)
    case settingsValidationFailed(String)
    case cacheError(underlyingError: Error)
    case analyticsError(String)
    case unknown(underlyingError: Error)
    
    public var errorDescription: String? {
        switch self {
        case .sceneLoadFailed(let error):
            return "Failed to load scene: \(error.localizedDescription)"
        case .sceneNotFound(let sceneID):
            return "Scene not found: \(sceneID)"
        case .playbackFailed(let error):
            return "Playback failed: \(error.localizedDescription)"
        case .audioInitializationFailed(let error):
            return "Audio initialization failed: \(error.localizedDescription)"
        case .premiumContentRequiresSubscription:
            return "This premium content requires an active subscription"
        case .subscriptionExpired:
            return "Your subscription has expired. Please renew to continue"
        case .networkConnectionFailed:
            return "Network connection failed. Please check your internet connection"
        case .invalidUserData(let details):
            return "Invalid user data: \(details)"
        case .settingsValidationFailed(let details):
            return "Settings validation failed: \(details)"
        case .cacheError(let error):
            return "Cache error: \(error.localizedDescription)"
        case .analyticsError(let details):
            return "Analytics error: \(details)"
        case .unknown(let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }
    
    public static func == (lhs: DogTVError, rhs: DogTVError) -> Bool {
        switch (lhs, rhs) {
        case (.sceneNotFound(let lhsID), .sceneNotFound(let rhsID)):
            return lhsID == rhsID
        case (.premiumContentRequiresSubscription, .premiumContentRequiresSubscription):
            return true
        case (.subscriptionExpired, .subscriptionExpired):
            return true
        case (.networkConnectionFailed, .networkConnectionFailed):
            return true
        case (.invalidUserData(let lhsDetails), .invalidUserData(let rhsDetails)):
            return lhsDetails == rhsDetails
        case (.settingsValidationFailed(let lhsDetails), .settingsValidationFailed(let rhsDetails)):
            return lhsDetails == rhsDetails
        case (.analyticsError(let lhsDetails), .analyticsError(let rhsDetails)):
            return lhsDetails == rhsDetails
        default:
            return false
        }
    }
}

