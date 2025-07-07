import Foundation
import SwiftUI
import UserNotifications
import Combine

/**
 * Notification System for DogTV+
 * 
 * Comprehensive notification and communication system
 * Handles all types of notifications, alerts, and user communication
 * 
 * Features:
 * - Push notifications
 * - In-app notifications
 * - Email notifications
 * - SMS notifications
 * - Smart notification scheduling
 * - Notification personalization
 * - Notification analytics
 * - A/B testing for notifications
 * - Notification preferences management
 * - Rich media notifications
 * - Interactive notifications
 * - Notification templates
 * - Multi-language support
 * - Accessibility notifications
 * 
 * Notification Types:
 * - Content recommendations
 * - System updates
 * - User engagement
 * - Social interactions
 * - Reminders and alerts
 * - Achievement notifications
 * - Live event notifications
 * - Personalized content alerts
 */
public class NotificationSystem: ObservableObject {
    
    // MARK: - Published Properties
    @Published public var notificationCenter: NotificationCenter = NotificationCenter()
    @Published public var notificationPreferences: NotificationPreferences = NotificationPreferences()
    @Published public var notificationHistory: NotificationHistory = NotificationHistory()
    @Published public var notificationAnalytics: NotificationAnalytics = NotificationAnalytics()
    @Published public var notificationTemplates: NotificationTemplates = NotificationTemplates()
    
    // MARK: - System Components
    private let pushNotificationManager = PushNotificationManager()
    private let inAppNotificationManager = InAppNotificationManager()
    private let emailNotificationManager = EmailNotificationManager()
    private let smsNotificationManager = SMSNotificationManager()
    private let notificationScheduler = NotificationScheduler()
    private let notificationPersonalizer = NotificationPersonalizer()
    private let notificationAnalyticsEngine = NotificationAnalyticsEngine()
    private let notificationTemplateEngine = NotificationTemplateEngine()
    
    // MARK: - Configuration
    private var notificationConfig: NotificationConfiguration
    private var personalizationConfig: PersonalizationConfiguration
    private var analyticsConfig: AnalyticsConfiguration
    
    // MARK: - Data Structures
    
    public struct NotificationCenter: Codable {
        var activeNotifications: [NotificationItem] = []
        var pendingNotifications: [NotificationItem] = []
        var notificationQueue: [NotificationItem] = []
        var lastUpdated: Date = Date()
    }
    
    public struct NotificationItem: Codable, Identifiable {
        public let id = UUID()
        var title: String
        var message: String
        var type: NotificationType
        var category: NotificationCategory
        var priority: NotificationPriority
        var targetAudience: [String]
        var deliveryChannels: [DeliveryChannel]
        var scheduledTime: Date?
        var expirationTime: Date?
        var isInteractive: Bool
        var actionButtons: [NotificationAction]
        var richMedia: RichMediaContent?
        var metadata: NotificationMetadata
        var status: NotificationStatus
        var createdAt: Date
        var sentAt: Date?
        var deliveredAt: Date?
        var openedAt: Date?
    }
    
    public enum NotificationType: String, CaseIterable, Codable {
        case contentRecommendation = "Content Recommendation"
        case systemUpdate = "System Update"
        case userEngagement = "User Engagement"
        case socialInteraction = "Social Interaction"
        case reminder = "Reminder"
        case achievement = "Achievement"
        case liveEvent = "Live Event"
        case personalizedContent = "Personalized Content"
        case marketing = "Marketing"
        case security = "Security"
        case maintenance = "Maintenance"
        
        var icon: String {
            switch self {
            case .contentRecommendation: return "tv"
            case .systemUpdate: return "gear"
            case .userEngagement: return "heart"
            case .socialInteraction: return "person.2"
            case .reminder: return "bell"
            case .achievement: return "trophy"
            case .liveEvent: return "antenna.radiowaves.left.and.right"
            case .personalizedContent: return "person.crop.circle"
            case .marketing: return "megaphone"
            case .security: return "lock.shield"
            case .maintenance: return "wrench.and.screwdriver"
            }
        }
    }
    
    public enum NotificationCategory: String, CaseIterable, Codable {
        case content = "Content"
        case system = "System"
        case social = "Social"
        case achievement = "Achievement"
        case reminder = "Reminder"
        case marketing = "Marketing"
        case security = "Security"
        case maintenance = "Maintenance"
    }
    
    public enum NotificationPriority: String, CaseIterable, Codable {
        case low = "Low"
        case normal = "Normal"
        case high = "High"
        case urgent = "Urgent"
        case critical = "Critical"
        
        var color: String {
            switch self {
            case .low: return "gray"
            case .normal: return "blue"
            case .high: return "orange"
            case .urgent: return "red"
            case .critical: return "purple"
            }
        }
    }
    
    public enum DeliveryChannel: String, CaseIterable, Codable {
        case push = "Push"
        case inApp = "In-App"
        case email = "Email"
        case sms = "SMS"
        case webhook = "Webhook"
        case social = "Social"
    }
    
    public struct NotificationAction: Codable, Identifiable {
        public let id = UUID()
        var title: String
        var actionType: ActionType
        var url: String?
        var data: [String: String]
        var isPrimary: Bool
    }
    
    public enum ActionType: String, CaseIterable, Codable {
        case open = "Open"
        case dismiss = "Dismiss"
        case share = "Share"
        case like = "Like"
        case comment = "Comment"
        case subscribe = "Subscribe"
        case purchase = "Purchase"
        case custom = "Custom"
    }
    
    public struct RichMediaContent: Codable {
        var imageURL: String?
        var videoURL: String?
        var audioURL: String?
        var gifURL: String?
        var attachmentURL: String?
        var mediaType: MediaType
        var thumbnailURL: String?
    }
    
    public enum MediaType: String, CaseIterable, Codable {
        case image = "Image"
        case video = "Video"
        case audio = "Audio"
        case gif = "GIF"
        case attachment = "Attachment"
    }
    
    public struct NotificationMetadata: Codable {
        var campaignId: String?
        var userId: String?
        var contentId: String?
        var sessionId: String?
        var deviceInfo: DeviceInfo
        var locationInfo: LocationInfo?
        var customData: [String: String]
    }
    
    public struct DeviceInfo: Codable {
        var platform: String
        var version: String
        var deviceModel: String
        var screenSize: String
        var timezone: String
    }
    
    public struct LocationInfo: Codable {
        var latitude: Double
        var longitude: Double
        var city: String?
        var country: String?
        var timezone: String
    }
    
    public enum NotificationStatus: String, CaseIterable, Codable {
        case draft = "Draft"
        case scheduled = "Scheduled"
        case sent = "Sent"
        case delivered = "Delivered"
        case opened = "Opened"
        case failed = "Failed"
        case cancelled = "Cancelled"
    }
    
    public struct NotificationPreferences: Codable {
        var globalEnabled: Bool = true
        var channelPreferences: [DeliveryChannel: Bool] = [:]
        var categoryPreferences: [NotificationCategory: Bool] = [:]
        var quietHours: QuietHours = QuietHours()
        var frequencyLimits: FrequencyLimits = FrequencyLimits()
        var language: String = "en"
        var accessibility: AccessibilityPreferences = AccessibilityPreferences()
        var lastUpdated: Date = Date()
    }
    
    public struct QuietHours: Codable {
        var enabled: Bool = false
        var startTime: Date = Calendar.current.date(from: DateComponents(hour: 22, minute: 0)) ?? Date()
        var endTime: Date = Calendar.current.date(from: DateComponents(hour: 8, minute: 0)) ?? Date()
        var timezone: String = "UTC"
        var daysOfWeek: [Int] = [1, 2, 3, 4, 5, 6, 7] // All days
    }
    
    public struct FrequencyLimits: Codable {
        var maxDailyNotifications: Int = 10
        var maxHourlyNotifications: Int = 3
        var cooldownPeriod: TimeInterval = 300 // 5 minutes
        var burstLimit: Int = 5
    }
    
    public struct AccessibilityPreferences: Codable {
        var screenReaderCompatible: Bool = true
        var highContrastMode: Bool = false
        var largeTextMode: Bool = false
        var reducedMotion: Bool = false
        var audioDescriptions: Bool = false
    }
    
    public struct NotificationHistory: Codable {
        var sentNotifications: [NotificationItem] = []
        var openedNotifications: [NotificationItem] = []
        var dismissedNotifications: [NotificationItem] = []
        var failedNotifications: [NotificationItem] = []
        var lastUpdated: Date = Date()
    }
    
    public struct NotificationAnalytics: Codable {
        var deliveryMetrics: DeliveryMetrics = DeliveryMetrics()
        var engagementMetrics: EngagementMetrics = EngagementMetrics()
        var performanceMetrics: PerformanceMetrics = PerformanceMetrics()
        var userBehavior: UserBehavior = UserBehavior()
        var lastUpdated: Date = Date()
    }
    
    public struct DeliveryMetrics: Codable {
        var totalSent: Int
        var totalDelivered: Int
        var deliveryRate: Float
        var failedDeliveries: Int
        var averageDeliveryTime: TimeInterval
        var channelPerformance: [DeliveryChannel: ChannelMetrics]
    }
    
    public struct ChannelMetrics: Codable {
        var sent: Int
        var delivered: Int
        var failed: Int
        var deliveryRate: Float
        var averageDeliveryTime: TimeInterval
    }
    
    public struct EngagementMetrics: Codable {
        var totalOpened: Int
        var openRate: Float
        var averageOpenTime: TimeInterval
        var actionClicks: Int
        var actionRate: Float
        var dismissRate: Float
    }
    
    public struct PerformanceMetrics: Codable {
        var responseTime: TimeInterval
        var errorRate: Float
        var systemLoad: Float
        var memoryUsage: Float
        var batteryImpact: Float
    }
    
    public struct UserBehavior: Codable {
        var preferredChannels: [DeliveryChannel: Float]
        var preferredCategories: [NotificationCategory: Float]
        var preferredTimes: [Int: Float] // Hour of day
        var interactionPatterns: [String: Int]
        var optOutRates: [NotificationCategory: Float]
    }
    
    public struct NotificationTemplates: Codable {
        var contentRecommendationTemplates: [NotificationTemplate] = []
        var systemUpdateTemplates: [NotificationTemplate] = []
        var userEngagementTemplates: [NotificationTemplate] = []
        var achievementTemplates: [NotificationTemplate] = []
        var reminderTemplates: [NotificationTemplate] = []
        var marketingTemplates: [NotificationTemplate] = []
        var lastUpdated: Date = Date()
    }
    
    public struct NotificationTemplate: Codable, Identifiable {
        public let id = UUID()
        var name: String
        var type: NotificationType
        var titleTemplate: String
        var messageTemplate: String
        var variables: [String]
        var defaultPriority: NotificationPriority
        var defaultChannels: [DeliveryChannel]
        var isActive: Bool
        var createdAt: Date
        var updatedAt: Date
    }
    
    // MARK: - Initialization
    
    public init() {
        self.notificationConfig = NotificationConfiguration()
        self.personalizationConfig = PersonalizationConfiguration()
        self.analyticsConfig = AnalyticsConfiguration()
        
        setupNotificationSystem()
        print("NotificationSystem initialized")
    }
    
    // MARK: - Public Methods
    
    /// Send notification
    public func sendNotification(_ notification: NotificationItem) async throws {
        // Personalize notification
        let personalizedNotification = await notificationPersonalizer.personalizeNotification(notification)
        
        // Schedule notification
        try await notificationScheduler.scheduleNotification(personalizedNotification)
        
        // Update notification center
        await updateNotificationCenter()
        
        print("Notification scheduled: \(notification.title)")
    }
    
    /// Send immediate notification
    public func sendImmediateNotification(_ notification: NotificationItem) async throws {
        // Personalize notification
        let personalizedNotification = await notificationPersonalizer.personalizeNotification(notification)
        
        // Send through all channels
        for channel in personalizedNotification.deliveryChannels {
            try await sendNotificationToChannel(personalizedNotification, channel: channel)
        }
        
        // Update analytics
        await updateNotificationAnalytics()
        
        print("Immediate notification sent: \(notification.title)")
    }
    
    /// Schedule notification
    public func scheduleNotification(_ notification: NotificationItem, at date: Date) async throws {
        var scheduledNotification = notification
        scheduledNotification.scheduledTime = date
        scheduledNotification.status = .scheduled
        
        try await notificationScheduler.scheduleNotification(scheduledNotification)
        
        // Update notification center
        await updateNotificationCenter()
        
        print("Notification scheduled for: \(date)")
    }
    
    /// Cancel notification
    public func cancelNotification(_ notificationId: String) async throws {
        try await notificationScheduler.cancelNotification(notificationId)
        
        // Update notification center
        await updateNotificationCenter()
        
        print("Notification cancelled: \(notificationId)")
    }
    
    /// Update notification preferences
    public func updatePreferences(_ preferences: NotificationPreferences) async {
        await MainActor.run {
            notificationPreferences = preferences
        }
        
        // Save preferences
        await saveNotificationPreferences(preferences)
        
        print("Notification preferences updated")
    }
    
    /// Get notification history
    public func getNotificationHistory() async -> NotificationHistory {
        let history = await loadNotificationHistory()
        
        await MainActor.run {
            notificationHistory = history
        }
        
        print("Notification history loaded")
        
        return history
    }
    
    /// Get notification analytics
    public func getNotificationAnalytics() async -> NotificationAnalytics {
        let analytics = await notificationAnalyticsEngine.getAnalytics()
        
        await MainActor.run {
            notificationAnalytics = analytics
        }
        
        print("Notification analytics loaded")
        
        return analytics
    }
    
    /// Create notification template
    public func createNotificationTemplate(_ template: NotificationTemplate) async throws {
        try await notificationTemplateEngine.createTemplate(template)
        
        // Update templates
        await loadNotificationTemplates()
        
        print("Notification template created: \(template.name)")
    }
    
    /// Send notification using template
    public func sendNotificationWithTemplate(_ templateName: String, variables: [String: String]) async throws {
        let template = await notificationTemplateEngine.getTemplate(templateName)
        let notification = await notificationTemplateEngine.createNotificationFromTemplate(template, variables: variables)
        
        try await sendNotification(notification)
        
        print("Notification sent using template: \(templateName)")
    }
    
    /// A/B test notifications
    public func runNotificationABTest(_ testConfig: NotificationABTest) async -> ABTestResult {
        let result = await notificationAnalyticsEngine.runABTest(testConfig)
        
        print("Notification A/B test completed")
        
        return result
    }
    
    /// Get notification recommendations
    public func getNotificationRecommendations(for userId: String) async -> [NotificationRecommendation] {
        let recommendations = await notificationPersonalizer.getRecommendations(for: userId)
        
        print("Notification recommendations generated for user: \(userId)")
        
        return recommendations
    }
    
    /// Mark notification as opened
    public func markNotificationAsOpened(_ notificationId: String) async {
        await notificationAnalyticsEngine.trackNotificationOpen(notificationId)
        
        // Update history
        await updateNotificationHistory()
        
        print("Notification marked as opened: \(notificationId)")
    }
    
    /// Track notification action
    public func trackNotificationAction(_ notificationId: String, action: NotificationAction) async {
        await notificationAnalyticsEngine.trackNotificationAction(notificationId, action: action)
        
        print("Notification action tracked: \(action.title)")
    }
    
    /// Export notification data
    public func exportNotificationData(_ format: ExportFormat, dateRange: DateRange) async throws -> Data {
        let data = try await notificationAnalyticsEngine.exportData(format: format, dateRange: dateRange)
        
        print("Notification data exported in \(format.rawValue) format")
        
        return data
    }
    
    // MARK: - Private Methods
    
    private func setupNotificationSystem() {
        // Configure system components
        pushNotificationManager.configure(notificationConfig)
        inAppNotificationManager.configure(notificationConfig)
        emailNotificationManager.configure(notificationConfig)
        smsNotificationManager.configure(notificationConfig)
        notificationScheduler.configure(notificationConfig)
        notificationPersonalizer.configure(personalizationConfig)
        notificationAnalyticsEngine.configure(analyticsConfig)
        notificationTemplateEngine.configure(notificationConfig)
        
        // Setup monitoring
        setupNotificationMonitoring()
        
        // Request notification permissions
        requestNotificationPermissions()
    }
    
    private func setupNotificationMonitoring() {
        // Notification center updates
        Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self?.updateNotificationCenter()
        }
        
        // Analytics updates
        Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
            self?.updateNotificationAnalytics()
        }
        
        // History updates
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.updateNotificationHistory()
        }
    }
    
    private func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permissions granted")
            } else {
                print("Notification permissions denied")
            }
        }
    }
    
    private func sendNotificationToChannel(_ notification: NotificationItem, channel: DeliveryChannel) async throws {
        switch channel {
        case .push:
            try await pushNotificationManager.sendNotification(notification)
        case .inApp:
            try await inAppNotificationManager.showNotification(notification)
        case .email:
            try await emailNotificationManager.sendNotification(notification)
        case .sms:
            try await smsNotificationManager.sendNotification(notification)
        case .webhook:
            try await sendWebhookNotification(notification)
        case .social:
            try await sendSocialNotification(notification)
        }
    }
    
    private func sendWebhookNotification(_ notification: NotificationItem) async throws {
        // Simulate webhook notification
    }
    
    private func sendSocialNotification(_ notification: NotificationItem) async throws {
        // Simulate social notification
    }
    
    private func updateNotificationCenter() {
        Task {
            let center = await notificationScheduler.getNotificationCenter()
            await MainActor.run {
                notificationCenter = center
            }
        }
    }
    
    private func updateNotificationAnalytics() {
        Task {
            let analytics = await notificationAnalyticsEngine.getAnalytics()
            await MainActor.run {
                notificationAnalytics = analytics
            }
        }
    }
    
    private func updateNotificationHistory() {
        Task {
            let history = await loadNotificationHistory()
            await MainActor.run {
                notificationHistory = history
            }
        }
    }
    
    private func loadNotificationHistory() async -> NotificationHistory {
        // Simulate loading notification history
        return NotificationHistory()
    }
    
    private func loadNotificationTemplates() async {
        let templates = await notificationTemplateEngine.loadTemplates()
        await MainActor.run {
            notificationTemplates = templates
        }
    }
    
    private func saveNotificationPreferences(_ preferences: NotificationPreferences) async {
        // Simulate saving preferences
    }
}

// MARK: - Supporting Classes

class PushNotificationManager {
    func configure(_ config: NotificationConfiguration) {
        // Configure push notification manager
    }
    
    func sendNotification(_ notification: NotificationItem) async throws {
        // Simulate sending push notification
    }
}

class InAppNotificationManager {
    func configure(_ config: NotificationConfiguration) {
        // Configure in-app notification manager
    }
    
    func showNotification(_ notification: NotificationItem) async throws {
        // Simulate showing in-app notification
    }
}

class EmailNotificationManager {
    func configure(_ config: NotificationConfiguration) {
        // Configure email notification manager
    }
    
    func sendNotification(_ notification: NotificationItem) async throws {
        // Simulate sending email notification
    }
}

class SMSNotificationManager {
    func configure(_ config: NotificationConfiguration) {
        // Configure SMS notification manager
    }
    
    func sendNotification(_ notification: NotificationItem) async throws {
        // Simulate sending SMS notification
    }
}

class NotificationScheduler {
    func configure(_ config: NotificationConfiguration) {
        // Configure notification scheduler
    }
    
    func scheduleNotification(_ notification: NotificationItem) async throws {
        // Simulate scheduling notification
    }
    
    func cancelNotification(_ notificationId: String) async throws {
        // Simulate cancelling notification
    }
    
    func getNotificationCenter() async -> NotificationCenter {
        // Simulate getting notification center
        return NotificationCenter()
    }
}

class NotificationPersonalizer {
    func configure(_ config: PersonalizationConfiguration) {
        // Configure notification personalizer
    }
    
    func personalizeNotification(_ notification: NotificationItem) async -> NotificationItem {
        // Simulate personalizing notification
        return notification
    }
    
    func getRecommendations(for userId: String) async -> [NotificationRecommendation] {
        // Simulate getting recommendations
        return []
    }
}

class NotificationAnalyticsEngine {
    func configure(_ config: AnalyticsConfiguration) {
        // Configure notification analytics engine
    }
    
    func getAnalytics() async -> NotificationAnalytics {
        // Simulate getting analytics
        return NotificationAnalytics()
    }
    
    func trackNotificationOpen(_ notificationId: String) async {
        // Simulate tracking notification open
    }
    
    func trackNotificationAction(_ notificationId: String, action: NotificationAction) async {
        // Simulate tracking notification action
    }
    
    func runABTest(_ testConfig: NotificationABTest) async -> ABTestResult {
        // Simulate running A/B test
        return ABTestResult(
            testId: testConfig.testId,
            variantA: ABTestVariant(name: "Control", openRate: 0.05, users: 1000),
            variantB: ABTestVariant(name: "Treatment", openRate: 0.07, users: 1000),
            confidence: 0.95,
            isSignificant: true,
            winner: "Treatment"
        )
    }
    
    func exportData(format: ExportFormat, dateRange: DateRange) async throws -> Data {
        // Simulate exporting data
        return "Mock notification data".data(using: .utf8) ?? Data()
    }
}

class NotificationTemplateEngine {
    func configure(_ config: NotificationConfiguration) {
        // Configure notification template engine
    }
    
    func createTemplate(_ template: NotificationTemplate) async throws {
        // Simulate creating template
    }
    
    func getTemplate(_ templateName: String) async -> NotificationTemplate {
        // Simulate getting template
        return NotificationTemplate(
            name: templateName,
            type: .contentRecommendation,
            titleTemplate: "New content for you",
            messageTemplate: "Check out this new content",
            variables: [],
            defaultPriority: .normal,
            defaultChannels: [.push, .inApp],
            isActive: true,
            createdAt: Date(),
            updatedAt: Date()
        )
    }
    
    func createNotificationFromTemplate(_ template: NotificationTemplate, variables: [String: String]) async -> NotificationItem {
        // Simulate creating notification from template
        return NotificationItem(
            title: template.titleTemplate,
            message: template.messageTemplate,
            type: template.type,
            category: .content,
            priority: template.defaultPriority,
            targetAudience: [],
            deliveryChannels: template.defaultChannels,
            scheduledTime: nil,
            expirationTime: nil,
            isInteractive: false,
            actionButtons: [],
            richMedia: nil,
            metadata: NotificationMetadata(
                campaignId: nil,
                userId: nil,
                contentId: nil,
                sessionId: nil,
                deviceInfo: DeviceInfo(
                    platform: "iOS",
                    version: "1.0",
                    deviceModel: "iPhone",
                    screenSize: "375x812",
                    timezone: "UTC"
                ),
                locationInfo: nil,
                customData: [:]
            ),
            status: .draft,
            createdAt: Date(),
            sentAt: nil,
            deliveredAt: nil,
            openedAt: nil
        )
    }
    
    func loadTemplates() async -> NotificationTemplates {
        // Simulate loading templates
        return NotificationTemplates()
    }
}

// MARK: - Supporting Data Structures

public struct NotificationConfiguration {
    var maxNotificationsPerDay: Int = 50
    var maxNotificationsPerHour: Int = 10
    var notificationTimeout: TimeInterval = 86400 // 24 hours
    var retryAttempts: Int = 3
    var retryDelay: TimeInterval = 300 // 5 minutes
    var supportedChannels: [DeliveryChannel] = [.push, .inApp, .email]
}

public struct PersonalizationConfiguration {
    var enablePersonalization: Bool = true
    var personalizationFactors: [String] = ["user_behavior", "preferences", "context"]
    var machineLearningEnabled: Bool = true
    var realTimeOptimization: Bool = true
}

public struct AnalyticsConfiguration {
    var trackingEnabled: Bool = true
    var dataRetentionDays: Int = 365
    var privacyControls: [String] = []
    var exportFormats: [ExportFormat] = [.json, .csv]
}

public struct NotificationABTest: Codable {
    let testId: String
    let variantA: NotificationItem
    let variantB: NotificationItem
    let targetAudience: [String]
    let duration: TimeInterval
    let successMetric: String
}

public struct ABTestResult: Codable {
    let testId: String
    let variantA: ABTestVariant
    let variantB: ABTestVariant
    let confidence: Float
    let isSignificant: Bool
    let winner: String?
}

public struct ABTestVariant: Codable {
    let name: String
    let openRate: Float
    let users: Int
}

public struct NotificationRecommendation: Codable, Identifiable {
    public let id = UUID()
    let title: String
    let message: String
    let type: NotificationType
    let priority: NotificationPriority
    let confidence: Float
    let reasoning: String
}

public struct DateRange: Codable {
    let startDate: Date
    let endDate: Date
}

public enum ExportFormat: String, CaseIterable, Codable {
    case json = "JSON"
    case csv = "CSV"
    case xml = "XML"
    case pdf = "PDF"
} 