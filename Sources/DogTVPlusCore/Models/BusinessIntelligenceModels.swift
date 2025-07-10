// swiftlint:disable import_organization mark_usage file_length
import Foundation
// swiftlint:enable import_organization

// MARK: - Business Intelligence Models

/// Comprehensive business metrics for DogTV+
public struct BusinessMetrics: Codable, Sendable {
    public let totalUsers: Int
    public let activeUsers: Int
    public let revenue: Double
    public let engagementRate: Double
    public let retentionRate: Double
    public let churnRate: Double
    public let conversionRate: Double
    public let averageSessionDuration: TimeInterval
    
    public static let `default` = BusinessMetrics(
        totalUsers: 0,
        activeUsers: 0,
        revenue: 0.0,
        engagementRate: 0.0,
        retentionRate: 0.0,
        churnRate: 0.0,
        conversionRate: 0.0,
        averageSessionDuration: 0.0
    )
    
    public init(totalUsers: Int, activeUsers: Int, revenue: Double, engagementRate: Double, retentionRate: Double, churnRate: Double, conversionRate: Double, averageSessionDuration: TimeInterval) {
        self.totalUsers = totalUsers
        self.activeUsers = activeUsers
        self.revenue = revenue
        self.engagementRate = engagementRate
        self.retentionRate = retentionRate
        self.churnRate = churnRate
        self.conversionRate = conversionRate
        self.averageSessionDuration = averageSessionDuration
    }
}

/// User engagement analytics
public struct UserEngagement: Codable, Sendable {
    public let totalSessions: Int
    public let uniqueUsers: Int
    public let averageSessionDuration: TimeInterval
    public let returningUserRate: Double
    public let engagementScore: Double
    
    public static let `default` = UserEngagement(
        totalSessions: 0,
        uniqueUsers: 0,
        averageSessionDuration: 0.0,
        returningUserRate: 0.0,
        engagementScore: 0.0
    )
    
    public init(totalSessions: Int, uniqueUsers: Int, averageSessionDuration: TimeInterval, returningUserRate: Double, engagementScore: Double) {
        self.totalSessions = totalSessions
        self.uniqueUsers = uniqueUsers
        self.averageSessionDuration = averageSessionDuration
        self.returningUserRate = returningUserRate
        self.engagementScore = engagementScore
    }
}

/// Content performance analytics
public struct ContentPerformance: Codable, Sendable {
    public let topPerformingScenes: [ScenePerformance]
    public let averageWatchTime: TimeInterval
    public let contentCompletionRate: Double
    
    public static let `default` = ContentPerformance(
        topPerformingScenes: [],
        averageWatchTime: 0.0,
        contentCompletionRate: 0.0
    )
    
    public init(topPerformingScenes: [ScenePerformance], averageWatchTime: TimeInterval, contentCompletionRate: Double) {
        self.topPerformingScenes = topPerformingScenes
        self.averageWatchTime = averageWatchTime
        self.contentCompletionRate = contentCompletionRate
    }
}

/// Scene performance metrics
public struct ScenePerformance: Codable, Sendable {
    public let sceneType: SceneType
    public let totalViews: Int
    public let totalDuration: TimeInterval
    public let averageEngagement: Double
    public let completionRate: Double
    
    public init(sceneType: SceneType, totalViews: Int, totalDuration: TimeInterval, averageEngagement: Double, completionRate: Double) {
        self.sceneType = sceneType
        self.totalViews = totalViews
        self.totalDuration = totalDuration
        self.averageEngagement = averageEngagement
        self.completionRate = completionRate
    }
}

/// Revenue analytics
public struct RevenueAnalytics: Codable, Sendable {
    public let monthlyRecurringRevenue: Double
    public let totalRevenue: Double
    public let averageRevenuePerUser: Double
    public let churnRate: Double
    public let conversionRate: Double
    
    public static let `default` = RevenueAnalytics(
        monthlyRecurringRevenue: 0.0,
        totalRevenue: 0.0,
        averageRevenuePerUser: 0.0,
        churnRate: 0.0,
        conversionRate: 0.0
    )
    
    public init(monthlyRecurringRevenue: Double, totalRevenue: Double, averageRevenuePerUser: Double, churnRate: Double, conversionRate: Double) {
        self.monthlyRecurringRevenue = monthlyRecurringRevenue
        self.totalRevenue = totalRevenue
        self.averageRevenuePerUser = averageRevenuePerUser
        self.churnRate = churnRate
        self.conversionRate = conversionRate
    }
}

/// Session tracking data
public struct SessionData: Codable, Identifiable, Sendable {
    public let id = UUID()
    public let sessionID: UUID
    public let userID: String
    public let startTime: Date
    public let endTime: Date?
    public let duration: TimeInterval?
    public let deviceType: DeviceType
    public let platform: Platform
    public var scenesWatched: Set<UUID>
    public var totalInteractions: Int
    
    public init(sessionID: UUID, userID: String, startTime: Date, endTime: Date? = nil, duration: TimeInterval? = nil, deviceType: DeviceType, platform: Platform, scenesWatched: Set<UUID> = [], totalInteractions: Int = 0) {
        self.sessionID = sessionID
        self.userID = userID
        self.startTime = startTime
        self.endTime = endTime
        self.duration = duration
        self.deviceType = deviceType
        self.platform = platform
        self.scenesWatched = scenesWatched
        self.totalInteractions = totalInteractions
    }
}

/// Content interaction tracking
public struct ContentInteraction: Codable, Identifiable, Sendable {
    public let id: UUID
    public let sessionID: UUID?
    public let sceneID: UUID
    public let sceneName: String
    public let sceneType: SceneType
    public let action: ContentAction
    public let timestamp: Date
    public let duration: TimeInterval?
    
    public init(id: UUID, sessionID: UUID?, sceneID: UUID, sceneName: String, sceneType: SceneType, action: ContentAction, timestamp: Date, duration: TimeInterval?) {
        self.id = id
        self.sessionID = sessionID
        self.sceneID = sceneID
        self.sceneName = sceneName
        self.sceneType = sceneType
        self.action = action
        self.timestamp = timestamp
        self.duration = duration
    }
}

/// Business event tracking
public struct BusinessEvent: Codable, Identifiable, Sendable {
    public let id: UUID
    public let type: BusinessEventType
    public let timestamp: Date
    public let sessionID: UUID?
    public let metadata: [String: AnyHashable]
    
    public init(id: UUID, type: BusinessEventType, timestamp: Date, sessionID: UUID?, metadata: [String: Any]) {
        self.id = id
        self.type = type
        self.timestamp = timestamp
        self.sessionID = sessionID
        // Convert [String: Any] to [String: AnyHashable] for Codable compliance
        self.metadata = metadata.compactMapValues { $0 as? AnyHashable }
    }
}

/// Performance metric tracking
public struct PerformanceMetric: Codable, Identifiable, Sendable {
    public let id = UUID()
    public let type: PerformanceMetricType
    public let value: Double
    public let timestamp: Date
    public let sessionID: UUID?
    
    public init(type: PerformanceMetricType, value: Double, timestamp: Date, sessionID: UUID?) {
        self.type = type
        self.value = value
        self.timestamp = timestamp
        self.sessionID = sessionID
    }
}

/// Analytics dashboard data
public struct AnalyticsDashboard: Codable, Sendable {
    public let activeUsers: Int
    public let currentSessions: Int
    public let popularScenes: [PopularScene]
    public let revenueToday: Double
    public let engagementRate: Double
    public let retentionRate: Double
    public let churnRisk: [ChurnRiskUser]
    
    public init(activeUsers: Int, currentSessions: Int, popularScenes: [PopularScene], revenueToday: Double, engagementRate: Double, retentionRate: Double, churnRisk: [ChurnRiskUser]) {
        self.activeUsers = activeUsers
        self.currentSessions = currentSessions
        self.popularScenes = popularScenes
        self.revenueToday = revenueToday
        self.engagementRate = engagementRate
        self.retentionRate = retentionRate
        self.churnRisk = churnRisk
    }
}

/// Popular scene data
public struct PopularScene: Codable, Sendable {
    public let sceneType: SceneType
    public let viewCount: Int
    public let averageDuration: TimeInterval
    
    public init(sceneType: SceneType, viewCount: Int, averageDuration: TimeInterval) {
        self.sceneType = sceneType
        self.viewCount = viewCount
        self.averageDuration = averageDuration
    }
}

/// Churn risk user identification
public struct ChurnRiskUser: Codable, Sendable {
    public let userID: String
    public let riskScore: Double
    public let lastActiveDate: Date
    public let reason: String
    
    public init(userID: String, riskScore: Double, lastActiveDate: Date, reason: String) {
        self.userID = userID
        self.riskScore = riskScore
        self.lastActiveDate = lastActiveDate
        self.reason = reason
    }
}

/// Comprehensive business report
public struct BusinessReport: Codable, Sendable {
    public let generatedAt: Date
    public let timeframe: ReportTimeframe
    public let userMetrics: UserMetrics
    public let contentMetrics: ContentMetrics
    public let revenueMetrics: RevenueMetrics
    public let engagementMetrics: EngagementMetrics
    public let retentionMetrics: RetentionMetrics
    public let recommendations: [BusinessRecommendation]
    
    public init(generatedAt: Date, timeframe: ReportTimeframe, userMetrics: UserMetrics, contentMetrics: ContentMetrics, revenueMetrics: RevenueMetrics, engagementMetrics: EngagementMetrics, retentionMetrics: RetentionMetrics, recommendations: [BusinessRecommendation]) {
        self.generatedAt = generatedAt
        self.timeframe = timeframe
        self.userMetrics = userMetrics
        self.contentMetrics = contentMetrics
        self.revenueMetrics = revenueMetrics
        self.engagementMetrics = engagementMetrics
        self.retentionMetrics = retentionMetrics
        self.recommendations = recommendations
    }
}

/// User metrics for reporting
public struct UserMetrics: Codable, Sendable {
    public let totalUsers: Int
    public let activeUsers: Int
    public let newUsers: Int
    public let returningUsers: Int
    
    public init(totalUsers: Int, activeUsers: Int, newUsers: Int, returningUsers: Int) {
        self.totalUsers = totalUsers
        self.activeUsers = activeUsers
        self.newUsers = newUsers
        self.returningUsers = returningUsers
    }
}

/// Content metrics for reporting
public struct ContentMetrics: Codable, Sendable {
    public let totalContentViews: Int
    public let averageViewDuration: TimeInterval
    public let contentCompletionRate: Double
    public let topContent: [PopularScene]
    
    public init(totalContentViews: Int, averageViewDuration: TimeInterval, contentCompletionRate: Double, topContent: [PopularScene]) {
        self.totalContentViews = totalContentViews
        self.averageViewDuration = averageViewDuration
        self.contentCompletionRate = contentCompletionRate
        self.topContent = topContent
    }
}

/// Revenue metrics for reporting
public struct RevenueMetrics: Codable, Sendable {
    public let totalRevenue: Double
    public let monthlyRecurringRevenue: Double
    public let averageRevenuePerUser: Double
    public let conversionRate: Double
    
    public init(totalRevenue: Double, monthlyRecurringRevenue: Double, averageRevenuePerUser: Double, conversionRate: Double) {
        self.totalRevenue = totalRevenue
        self.monthlyRecurringRevenue = monthlyRecurringRevenue
        self.averageRevenuePerUser = averageRevenuePerUser
        self.conversionRate = conversionRate
    }
}

/// Engagement metrics for reporting
public struct EngagementMetrics: Codable, Sendable {
    public let engagementRate: Double
    public let averageSessionDuration: TimeInterval
    public let interactionsPerSession: Double
    public let retentionRate: Double
    
    public init(engagementRate: Double, averageSessionDuration: TimeInterval, interactionsPerSession: Double, retentionRate: Double) {
        self.engagementRate = engagementRate
        self.averageSessionDuration = averageSessionDuration
        self.interactionsPerSession = interactionsPerSession
        self.retentionRate = retentionRate
    }
}

/// Retention metrics for reporting
public struct RetentionMetrics: Codable, Sendable {
    public let day1Retention: Double
    public let day7Retention: Double
    public let day30Retention: Double
    public let churnRate: Double
    
    public init(day1Retention: Double, day7Retention: Double, day30Retention: Double, churnRate: Double) {
        self.day1Retention = day1Retention
        self.day7Retention = day7Retention
        self.day30Retention = day30Retention
        self.churnRate = churnRate
    }
}

/// Business recommendation
public struct BusinessRecommendation: Codable, Sendable {
    public let type: RecommendationType
    public let title: String
    public let description: String
    public let priority: RecommendationPriority
    public let estimatedImpact: String
    
    public init(type: RecommendationType, title: String, description: String, priority: RecommendationPriority, estimatedImpact: String) {
        self.type = type
        self.title = title
        self.description = description
        self.priority = priority
        self.estimatedImpact = estimatedImpact
    }
}

// MARK: - Enums

/// Device type classification
public enum DeviceType: String, Codable, CaseIterable, Sendable {
    case appleTv = "apple_tv"
    case iPhone = "iphone"
    case iPad = "ipad"
    case mac = "mac"
    case unknown = "unknown"
}

/// Platform classification
public enum Platform: String, Codable, CaseIterable, Sendable {
    case tvOS = "tvos"
    case iOS = "ios"
    case macOS = "macos"
    case unknown = "unknown"
}

/// Content action types
public enum ContentAction: String, Codable, CaseIterable, Sendable {
    case play = "play"
    case pause = "pause"
    case stop = "stop"
    case skip = "skip"
    case complete = "complete"
    case favorite = "favorite"
    case share = "share"
}

/// Business event types
public enum BusinessEventType: String, Codable, CaseIterable, Sendable {
    case appLaunch = "app_launch"
    case appBackground = "app_background"
    case subscription = "subscription"
    case purchase = "purchase"
    case trialStart = "trial_start"
    case trialEnd = "trial_end"
    case userRegistration = "user_registration"
    case userLogin = "user_login"
    case userLogout = "user_logout"
    case settingsChanged = "settings_changed"
    case errorOccurred = "error_occurred"
    case featureUsed = "feature_used"
}

/// Performance metric types
public enum PerformanceMetricType: String, Codable, CaseIterable, Sendable {
    case appStartTime = "app_start_time"
    case sceneLoadTime = "scene_load_time"
    case audioLatency = "audio_latency"
    case frameRate = "frame_rate"
    case memoryUsage = "memory_usage"
    case cpuUsage = "cpu_usage"
    case networkLatency = "network_latency"
    case batterUsage = "battery_usage"
}

/// Analytics event types
public enum AnalyticsEvent: Sendable {
    case sessionStart(SessionData)
    case sessionEnd(SessionData)
    case contentInteraction(ContentInteraction)
    case businessEvent(BusinessEvent)
    case performanceMetric(PerformanceMetric)
    case networkStatus(Bool)
}

/// Report timeframe
public enum ReportTimeframe: String, Codable, CaseIterable, Sendable {
    case last24Hours = "last_24_hours"
    case last7Days = "last_7_days"
    case last30Days = "last_30_days"
    case last90Days = "last_90_days"
    case lastYear = "last_year"
    case allTime = "all_time"
}

/// Recommendation types
public enum RecommendationType: String, Codable, CaseIterable, Sendable {
    case engagement = "engagement"
    case content = "content"
    case revenue = "revenue"
    case performance = "performance"
    case retention = "retention"
    case acquisition = "acquisition"
}

/// Recommendation priority
public enum RecommendationPriority: String, Codable, CaseIterable, Sendable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case critical = "critical"
}
// swiftlint:enable import_organization mark_usage file_length
