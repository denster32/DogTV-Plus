import Foundation

// MARK: - AnalyticsEvent

/// Represents a single analytics event to be tracked.
public struct AnalyticsEvent: Codable, Sendable, Hashable {
    public let name: String
    public let parameters: [String: String]
    public let timestamp: Date

    public init(name: String, parameters: [String: String] = [:], timestamp: Date = Date()) {
        self.name = name
        self.parameters = parameters
        self.timestamp = timestamp
    }
}

// MARK: - SessionData

/// Encapsulates data related to a user session.
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

// MARK: - UsageStatistics

/// Contains aggregated usage statistics.
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
