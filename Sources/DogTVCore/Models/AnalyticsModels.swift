import Foundation

// MARK: - AnalyticsEvent

/// Represents a single analytics event to be tracked.
public enum AnalyticsEvent: Equatable {
    case sessionStart(attributes: [String: AnyEquatable])
    case sessionEnd(attributes: [String: AnyEquatable])
    case event(name: String, attributes: [String: AnyEquatable]?)

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
