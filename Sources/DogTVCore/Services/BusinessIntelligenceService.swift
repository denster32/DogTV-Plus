// swiftlint:disable import_organization mark_usage file_length
import Foundation
import Combine
import Network
// swiftlint:enable import_organization

/// Advanced business intelligence and analytics service for DogTV+
/// Provides comprehensive user behavior tracking, business metrics, and AI-powered insights
@available(iOS 17.0, tvOS 17.0, macOS 10.15, *)
@MainActor
public final class BusinessIntelligenceService: ObservableObject {
    
    // MARK: - Shared Instance
    
    public static let shared = BusinessIntelligenceService()
    
    // MARK: - Published Properties
    
    @Published public private(set) var currentMetrics: BusinessMetrics = BusinessMetrics.default
    @Published public private(set) var userEngagement: UserEngagement = UserEngagement.default
    @Published public private(set) var contentPerformance: ContentPerformance = ContentPerformance.default
    @Published public private(set) var revenueAnalytics: RevenueAnalytics = RevenueAnalytics.default
    @Published public private(set) var isAnalyzing: Bool = false
    
    // MARK: - Private Properties
    
    private var cancellables = Set<AnyCancellable>()
    private let networkMonitor = NWPathMonitor()
    private let analyticsQueue = DispatchQueue(label: "com.dogtv.analytics", qos: .background)
    private var sessionStartTime: Date?
    private var currentSessionData: SessionData?
    
    // MARK: - Data Storage
    
    private var userSessions: [SessionData] = []
    private var contentInteractions: [ContentInteraction] = []
    private var businessEvents: [BusinessEvent] = []
    private var performanceMetrics: [PerformanceMetric] = []
    
    private init() {
        setupNetworkMonitoring()
        schedulePeriodicAnalysis()
    }
    
    // MARK: - Public API
    
    /// Start tracking a user session
    public func startSession(userID: String, deviceType: DeviceType = .appleTv) {
        let session = SessionData(
            sessionID: UUID(),
            userID: userID,
            startTime: Date(),
            deviceType: deviceType,
            platform: currentPlatform()
        )
        
        currentSessionData = session
        sessionStartTime = Date()
        
        trackEvent(.sessionStart(session))
        
        print("📊 [BI] Session started: \(session.sessionID)")
    }
    
    /// End the current session
    public func endSession() {
        guard let session = currentSessionData,
              let startTime = sessionStartTime else { return }
        
        let duration = Date().timeIntervalSince(startTime)
        let endedSession = SessionData(
            sessionID: session.sessionID,
            userID: session.userID,
            startTime: session.startTime,
            endTime: Date(),
            duration: duration,
            deviceType: session.deviceType,
            platform: session.platform,
            scenesWatched: session.scenesWatched,
            totalInteractions: session.totalInteractions
        )
        
        userSessions.append(endedSession)
        trackEvent(.sessionEnd(endedSession))
        
        currentSessionData = nil
        sessionStartTime = nil
        
        Task {
            await updateEngagementMetrics()
        }
        
        print("📊 [BI] Session ended: \(endedSession.sessionID) - Duration: \(duration)s")
    }
    
    /// Track content interaction
    public func trackContentInteraction(_ scene: Scene, action: ContentAction) {
        let interaction = ContentInteraction(
            id: UUID(),
            sessionID: currentSessionData?.sessionID,
            sceneID: scene.id,
            sceneName: scene.name,
            sceneType: scene.type,
            action: action,
            timestamp: Date(),
            duration: nil
        )
        
        contentInteractions.append(interaction)
        
        // Update current session
        currentSessionData?.addSceneInteraction(scene, action: action)
        
        trackEvent(.contentInteraction(interaction))
        
        Task {
            await updateContentPerformance()
        }
        
        print("📊 [BI] Content interaction: \(scene.name) - \(action)")
    }
    
    /// Track business event
    public func trackBusinessEvent(_ eventType: BusinessEventType, metadata: [String: Any] = [:]) {
        let event = BusinessEvent(
            id: UUID(),
            type: eventType,
            timestamp: Date(),
            sessionID: currentSessionData?.sessionID,
            metadata: metadata
        )
        
        businessEvents.append(event)
        trackEvent(.businessEvent(event))
        
        Task {
            await updateRevenueMetrics()
        }
        
        print("📊 [BI] Business event: \(eventType)")
    }
    
    /// Generate comprehensive business report
    public func generateBusinessReport() async -> BusinessReport {
        isAnalyzing = true
        defer { isAnalyzing = false }
        
        let report = BusinessReport(
            generatedAt: Date(),
            timeframe: .last30Days,
            userMetrics: await calculateUserMetrics(),
            contentMetrics: await calculateContentMetrics(),
            revenueMetrics: await calculateRevenueMetrics(),
            engagementMetrics: await calculateEngagementMetrics(),
            retentionMetrics: await calculateRetentionMetrics(),
            recommendations: await generateRecommendations()
        )
        
        print("📊 [BI] Business report generated")
        return report
    }
    
    /// Get real-time analytics dashboard data
    public func getDashboardData() async -> AnalyticsDashboard {
        let dashboard = AnalyticsDashboard(
            activeUsers: calculateActiveUsers(),
            currentSessions: userSessions.filter { $0.endTime == nil }.count,
            popularScenes: await getMostPopularScenes(),
            revenueToday: await getTodayRevenue(),
            engagementRate: calculateEngagementRate(),
            retentionRate: await calculateRetentionRate(),
            churnRisk: await identifyChurnRisk()
        )
        
        return dashboard
    }
    
    // MARK: - Private Methods
    
    private func setupNetworkMonitoring() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                self?.trackEvent(.networkStatus(path.status == .satisfied))
            }
        }
        
        let queue = DispatchQueue(label: "NetworkMonitor")
        networkMonitor.start(queue: queue)
    }
    
    private func schedulePeriodicAnalysis() {
        Timer.publish(every: 300, on: .main, in: .common) // Every 5 minutes
            .autoconnect()
            .sink { [weak self] _ in
                Task {
                    await self?.performPeriodicAnalysis()
                }
            }
            .store(in: &cancellables)
    }
    
    private func performPeriodicAnalysis() async {
        await updateEngagementMetrics()
        await updateContentPerformance()
        await updateRevenueMetrics()
    }
    
    private func trackEvent(_ event: AnalyticsEvent) {
        analyticsQueue.async {
            // In a real implementation, this would send to analytics service
            print("🔍 [Analytics] Event: \(event)")
        }
    }
    
    private func currentPlatform() -> Platform {
        #if os(tvOS)
        return .tvOS
        #elseif os(iOS)
        return .iOS
        #elseif os(macOS)
        return .macOS
        #else
        return .unknown
        #endif
    }
    
    // MARK: - Metrics Calculation
    
    private func updateEngagementMetrics() async {
        let totalSessions = userSessions.count
        let totalDuration = userSessions.compactMap { $0.duration }.reduce(0, +)
        let averageSessionDuration = totalSessions > 0 ? totalDuration / Double(totalSessions) : 0
        
        let uniqueUsers = Set(userSessions.map { $0.userID }).count
        let returningUsers = calculateReturningUsers()
        
        userEngagement = UserEngagement(
            totalSessions: totalSessions,
            uniqueUsers: uniqueUsers,
            averageSessionDuration: averageSessionDuration,
            returningUserRate: Double(returningUsers) / Double(max(uniqueUsers, 1)),
            engagementScore: calculateEngagementScore()
        )
    }
    
    private func updateContentPerformance() async {
        let scenePerformance = Dictionary(grouping: contentInteractions, by: { $0.sceneType })
            .mapValues { interactions in
                ScenePerformance(
                    sceneType: interactions.first?.sceneType ?? .ocean,
                    totalViews: interactions.filter { $0.action == .play }.count,
                    totalDuration: interactions.compactMap { $0.duration }.reduce(0, +),
                    averageEngagement: calculateSceneEngagement(interactions),
                    completionRate: calculateCompletionRate(interactions)
                )
            }
        
        contentPerformance = ContentPerformance(
            topPerformingScenes: Array(scenePerformance.values.sorted { $0.totalViews > $1.totalViews }.prefix(5)),
            averageWatchTime: scenePerformance.values.map { $0.averageEngagement }.reduce(0, +) / Double(max(scenePerformance.count, 1)),
            contentCompletionRate: scenePerformance.values.map { $0.completionRate }.reduce(0, +) / Double(max(scenePerformance.count, 1))
        )
    }
    
    private func updateRevenueMetrics() async {
        // Calculate revenue metrics from business events
        let subscriptionEvents = businessEvents.filter {
            if case .subscription = $0.type { return true }
            return false
        }
        
        let purchaseEvents = businessEvents.filter {
            if case .purchase = $0.type { return true }
            return false
        }
        
        let mrr = calculateMonthlyRecurringRevenue(from: subscriptionEvents)
        let totalRevenue = calculateTotalRevenue(from: purchaseEvents + subscriptionEvents)
        
        revenueAnalytics = RevenueAnalytics(
            monthlyRecurringRevenue: mrr,
            totalRevenue: totalRevenue,
            averageRevenuePerUser: totalRevenue / Double(max(Set(userSessions.map { $0.userID }).count, 1)),
            churnRate: await calculateChurnRate(),
            conversionRate: calculateConversionRate()
        )
    }
    
    // MARK: - Helper Methods
    
    private func calculateActiveUsers() -> Int {
        let last24Hours = Date().addingTimeInterval(-24 * 60 * 60)
        return Set(userSessions.filter { $0.startTime > last24Hours }.map { $0.userID }).count
    }
    
    private func calculateReturningUsers() -> Int {
        let userSessionCounts = Dictionary(grouping: userSessions, by: { $0.userID })
        return userSessionCounts.values.filter { $0.count > 1 }.count
    }
    
    private func calculateEngagementScore() -> Double {
        // Sophisticated engagement scoring algorithm
        let sessionScore = min(userEngagement.averageSessionDuration / 1800, 1.0) * 0.4 // Up to 30 min
        let retentionScore = userEngagement.returningUserRate * 0.3
        let interactionScore = Double(contentInteractions.count) / Double(max(userSessions.count, 1)) * 0.3
        
        return sessionScore + retentionScore + interactionScore
    }
    
    private func calculateSceneEngagement(_ interactions: [ContentInteraction]) -> Double {
        let playEvents = interactions.filter { $0.action == .play }
        let totalDuration = interactions.compactMap { $0.duration }.reduce(0, +)
        return totalDuration / Double(max(playEvents.count, 1))
    }
    
    private func calculateCompletionRate(_ interactions: [ContentInteraction]) -> Double {
        let playEvents = interactions.filter { $0.action == .play }
        let completeEvents = interactions.filter { $0.action == .complete }
        return Double(completeEvents.count) / Double(max(playEvents.count, 1))
    }
    
    private func calculateMonthlyRecurringRevenue(from events: [BusinessEvent]) -> Double {
        // Simplified MRR calculation
        return Double(events.count) * 9.99 // Assuming $9.99/month subscription
    }
    
    private func calculateTotalRevenue(from events: [BusinessEvent]) -> Double {
        return events.compactMap { event in
            event.metadata["amount"] as? Double
        }.reduce(0, +)
    }
    
    private func calculateChurnRate() async -> Double {
        // Simplified churn calculation
        let last30Days = Date().addingTimeInterval(-30 * 24 * 60 * 60)
        let activeUsersLast30Days = Set(userSessions.filter { $0.startTime > last30Days }.map { $0.userID })
        let allUsers = Set(userSessions.map { $0.userID })
        
        let churnedUsers = allUsers.subtracting(activeUsersLast30Days)
        return Double(churnedUsers.count) / Double(max(allUsers.count, 1))
    }
    
    private func calculateConversionRate() -> Double {
        let trialUsers = businessEvents.filter {
            if case .trialStart = $0.type { return true }
            return false
        }.count
        
        let paidUsers = businessEvents.filter {
            if case .subscription = $0.type { return true }
            return false
        }.count
        
        return Double(paidUsers) / Double(max(trialUsers, 1))
    }
    
    private func calculateRetentionRate() async -> Double {
        // 7-day retention rate
        let sevenDaysAgo = Date().addingTimeInterval(-7 * 24 * 60 * 60)
        let newUsers = Set(userSessions.filter { $0.startTime < sevenDaysAgo }.map { $0.userID })
        let returningUsers = Set(userSessions.filter { $0.startTime > sevenDaysAgo }.map { $0.userID })
        
        let retainedUsers = newUsers.intersection(returningUsers)
        return Double(retainedUsers.count) / Double(max(newUsers.count, 1))
    }
    
    private func getMostPopularScenes() async -> [PopularScene] {
        let sceneInteractions = Dictionary(grouping: contentInteractions, by: { $0.sceneType })
        
        return sceneInteractions.map { (sceneType, interactions) in
            PopularScene(
                sceneType: sceneType,
                viewCount: interactions.filter { $0.action == .play }.count,
                averageDuration: interactions.compactMap { $0.duration }.reduce(0, +) / Double(max(interactions.count, 1))
            )
        }.sorted { $0.viewCount > $1.viewCount }
    }
    
    private func getTodayRevenue() async -> Double {
        let today = Calendar.current.startOfDay(for: Date())
        // Calculate tomorrow's date safely
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today) ?? today.addingTimeInterval(86400)
        
        return businessEvents
            .filter { $0.timestamp >= today && $0.timestamp < tomorrow }
            .compactMap { $0.metadata["amount"] as? Double }
            .reduce(0, +)
    }
    
    private func calculateEngagementRate() -> Double {
        let totalSessions = userSessions.count
        let engagedSessions = userSessions.filter { 
            ($0.duration ?? 0) > 300 && // More than 5 minutes
            $0.totalInteractions > 2 // At least 3 interactions
        }.count
        
        return Double(engagedSessions) / Double(max(totalSessions, 1))
    }
    
    private func identifyChurnRisk() async -> [ChurnRiskUser] {
        // Identify users at risk of churning based on behavior patterns
        let userBehavior = Dictionary(grouping: userSessions, by: { $0.userID })
        
        return userBehavior.compactMap { (userID, sessions) in
            let recentSessions = sessions.filter { 
                $0.startTime > Date().addingTimeInterval(-14 * 24 * 60 * 60) 
            }
            
            if recentSessions.isEmpty && sessions.count > 2 {
                return ChurnRiskUser(
                    userID: userID,
                    riskScore: 0.8,
                    lastActiveDate: sessions.max(by: { $0.startTime < $1.startTime })?.startTime ?? Date(),
                    reason: "No activity in last 14 days"
                )
            }
            
            return nil
        }.sorted { $0.riskScore > $1.riskScore }
    }
    
    // MARK: - Advanced Analytics
    
    private func calculateUserMetrics() async -> UserMetrics {
        return UserMetrics(
            totalUsers: Set(userSessions.map { $0.userID }).count,
            activeUsers: calculateActiveUsers(),
            newUsers: calculateNewUsers(),
            returningUsers: calculateReturningUsers()
        )
    }
    
    private func calculateContentMetrics() async -> ContentMetrics {
        return ContentMetrics(
            totalContentViews: contentInteractions.filter { $0.action == .play }.count,
            averageViewDuration: contentInteractions.compactMap { $0.duration }.reduce(0, +) / Double(max(contentInteractions.count, 1)),
            contentCompletionRate: contentPerformance.contentCompletionRate,
            topContent: await getMostPopularScenes()
        )
    }
    
    private func calculateRevenueMetrics() async -> RevenueMetrics {
        return RevenueMetrics(
            totalRevenue: revenueAnalytics.totalRevenue,
            monthlyRecurringRevenue: revenueAnalytics.monthlyRecurringRevenue,
            averageRevenuePerUser: revenueAnalytics.averageRevenuePerUser,
            conversionRate: revenueAnalytics.conversionRate
        )
    }
    
    private func calculateEngagementMetrics() async -> EngagementMetrics {
        return EngagementMetrics(
            engagementRate: calculateEngagementRate(),
            averageSessionDuration: userEngagement.averageSessionDuration,
            interactionsPerSession: Double(contentInteractions.count) / Double(max(userSessions.count, 1)),
            retentionRate: await calculateRetentionRate()
        )
    }
    
    private func calculateRetentionMetrics() async -> RetentionMetrics {
        let day1Retention = await calculateRetentionForPeriod(days: 1)
        let day7Retention = await calculateRetentionForPeriod(days: 7)
        let day30Retention = await calculateRetentionForPeriod(days: 30)
        
        return RetentionMetrics(
            day1Retention: day1Retention,
            day7Retention: day7Retention,
            day30Retention: day30Retention,
            churnRate: await calculateChurnRate()
        )
    }
    
    private func calculateRetentionForPeriod(days: Int) async -> Double {
        let targetDate = Date().addingTimeInterval(-Double(days) * 24 * 60 * 60)
        let cohortUsers = Set(userSessions.filter { $0.startTime < targetDate }.map { $0.userID })
        let returningUsers = Set(userSessions.filter { $0.startTime > targetDate }.map { $0.userID })
        
        let retainedUsers = cohortUsers.intersection(returningUsers)
        return Double(retainedUsers.count) / Double(max(cohortUsers.count, 1))
    }
    
    private func generateRecommendations() async -> [BusinessRecommendation] {
        var recommendations: [BusinessRecommendation] = []
        
        // Engagement recommendations
        if userEngagement.engagementScore < 0.5 {
            recommendations.append(BusinessRecommendation(
                type: .engagement,
                title: "Improve User Engagement",
                description: "Current engagement score is below target. Consider adding more interactive features or improving content quality.",
                priority: .high,
                estimatedImpact: "15-25% increase in retention"
            ))
        }
        
        // Content recommendations
        let topScene = await getMostPopularScenes().first
        if let topScene = topScene {
            recommendations.append(BusinessRecommendation(
                type: .content,
                title: "Expand Popular Content",
                description: "Scene type '\(topScene.sceneType.rawValue)' is very popular. Consider creating more similar content.",
                priority: .medium,
                estimatedImpact: "10-15% increase in user satisfaction"
            ))
        }
        
        // Revenue recommendations
        if revenueAnalytics.conversionRate < 0.3 {
            recommendations.append(BusinessRecommendation(
                type: .revenue,
                title: "Optimize Conversion Funnel",
                description: "Conversion rate is below industry average. Review onboarding process and value proposition.",
                priority: .high,
                estimatedImpact: "20-30% increase in revenue"
            ))
        }
        
        return recommendations
    }
    
    private func calculateNewUsers() -> Int {
        let last30Days = Date().addingTimeInterval(-30 * 24 * 60 * 60)
        return Set(userSessions.filter { $0.startTime > last30Days }.map { $0.userID }).count
    }
}

// MARK: - Supporting Extensions

extension SessionData {
    mutating func addSceneInteraction(_ scene: Scene, action: ContentAction) {
        if action == .play {
            scenesWatched.insert(scene.id)
        }
        totalInteractions += 1
    }
}
// swiftlint:enable import_organization mark_usage file_length
