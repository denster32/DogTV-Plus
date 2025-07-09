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
// swiftlint:enable mark_usage
