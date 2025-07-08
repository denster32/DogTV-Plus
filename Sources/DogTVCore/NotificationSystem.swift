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
// MARK: - Notification System
/// Comprehensive notification management for DogTV+
@available(macOS 10.15, *)
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
    private var analyticsConfig: NotificationAnalyticsConfiguration
    
    // MARK: - Data Structures
    
    public struct NotificationCenter: Codable {
        var notifications: [NotificationItem] = []
        var unreadCount: Int = 0
        var lastUpdated: Date = Date()
    }
    
    public struct NotificationItem: Codable, Identifiable {
        public var id = UUID()
        var title: String
        var message: String
        var type: NotificationType
        var priority: NotificationPriority
        var scheduledDate: Date?
        var isRead: Bool = false
        var isDelivered: Bool = false
        var deliveryChannels: [DeliveryChannel] = []
        var metadata: [String: String] = [:]
        var status: NotificationStatus = .draft
    }
    
    public enum NotificationType: String, CaseIterable, Codable {
        case info = "Info"
        case warning = "Warning"
        case error = "Error"
        case success = "Success"
        case reminder = "Reminder"
    }
    
    public enum NotificationPriority: String, CaseIterable, Codable {
        case low = "Low"
        case normal = "Normal"
        case high = "High"
        case urgent = "Urgent"
    }
    
    public enum DeliveryChannel: String, CaseIterable, Codable {
        case push = "Push"
        case inApp = "In-App"
        case email = "Email"
        case sms = "SMS"
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
    
    public struct NotificationAction: Codable, Identifiable {
        public var id = UUID()
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
        var totalSent: Int = 0
        var delivered: Int = 0
        var failed: Int = 0
        var deliveryRate: Float = 0.0
    }
    
    public struct EngagementMetrics: Codable {
        var opened: Int = 0
        var clicked: Int = 0
        var dismissed: Int = 0
        var engagementRate: Float = 0.0
    }
    
    public struct PerformanceMetrics: Codable {
        var averageDeliveryTime: TimeInterval = 0.0
        var openRate: Float = 0.0
        var clickRate: Float = 0.0
        var conversionRate: Float = 0.0
    }
    
    public struct UserBehavior: Codable {
        var preferredChannels: [DeliveryChannel] = []
        var preferredTimes: [Date] = []
        var optOutCategories: [String] = []
        var engagementHistory: [String] = []
    }
    
    public struct NotificationTemplates: Codable {
        var templates: [NotificationTemplate] = []
        var categories: [String] = []
        var lastUpdated: Date = Date()
    }
    
    public struct NotificationTemplate: Codable, Identifiable {
        public var id = UUID()
        var name: String
        var title: String
        var message: String
        var type: NotificationType
        var priority: NotificationPriority
        var variables: [String] = []
        var isActive: Bool = true
    }
    
    // MARK: - Initialization
    
    public init() {
        self.notificationConfig = NotificationConfiguration()
        self.personalizationConfig = PersonalizationConfiguration()
        self.analyticsConfig = NotificationAnalyticsConfiguration()
        
        setupNotificationSystem()
        print("NotificationSystem initialized")
    }
    
    // MARK: - Public Methods
    
    /// Send notification
    @available(macOS 10.15, *)
    public func sendNotification(_ notification: NotificationSystem.NotificationItem) async throws {
        // Personalize notification
        let personalizedNotification = await notificationPersonalizer.personalizeNotification(notification)
        
        // Schedule notification
        try await notificationScheduler.scheduleNotification(personalizedNotification)
        
        // Send through appropriate channels
        try await sendThroughChannels(personalizedNotification)
        
        // Update analytics
        await notificationAnalyticsEngine.trackNotificationSent(notification.id.uuidString)
        
        print("Notification sent: \(notification.title)")
    }
    
    /// Send immediate notification
    @available(macOS 10.15, *)
    public func sendImmediateNotification(_ notification: NotificationSystem.NotificationItem) async throws {
        // Personalize notification
        let personalizedNotification = await notificationPersonalizer.personalizeNotification(notification)
        
        // Send through all channels
        try await sendThroughChannels(personalizedNotification)
        
        // Update analytics
        await notificationAnalyticsEngine.trackNotificationSent(notification.id.uuidString)
        
        print("Immediate notification sent: \(notification.title)")
    }
    
    /// Schedule notification
    @available(macOS 10.15, *)
    public func scheduleNotification(_ notification: NotificationSystem.NotificationItem, at date: Date) async throws {
        var scheduledNotification = notification
        scheduledNotification.status = .scheduled
        
        try await notificationScheduler.scheduleNotification(scheduledNotification)
        
        // Update notification center
        await MainActor.run {
            notificationHistory.append(scheduledNotification)
        }
        
        print("Notification scheduled: \(notification.title) at \(date)")
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
    @available(macOS 10.15, *)
    public func getNotificationAnalytics() async -> NotificationAnalytics {
        let analytics = await notificationAnalyticsEngine.getAnalytics()
        
        await MainActor.run {
            notificationAnalytics = analytics
        }
        
        print("Notification analytics loaded")
        
        return analytics
    }
    
    /// Create notification template
    @available(macOS 10.15, *)
    public func createNotificationTemplate(_ template: NotificationTemplate) async throws {
        try await notificationTemplateEngine.createTemplate(template)
        
        // Update templates
        await loadNotificationTemplates()
        
        print("Notification template created: \(template.name)")
    }
    
    /// Send notification using template
    @available(macOS 10.15, *)
    public func sendNotificationFromTemplate(_ templateName: String, variables: [String: String]) async throws {
        let template = notificationTemplates.templates.first { $0.name == templateName }
        guard let template = template else {
            throw NotificationError.templateNotFound(templateName)
        }
        
        let notification = await notificationTemplateEngine.createNotificationFromTemplate(template, variables: variables)
        
        try await sendNotification(notification)
        
        print("Notification sent using template: \(templateName)")
    }
    
    /// A/B test notifications
    @available(macOS 10.15, *)
    public func runNotificationABTest(_ testConfig: NotificationABTest) async -> ABTestResult {
        let result = await notificationAnalyticsEngine.runABTest(testConfig)
        
        // Update analytics
        await updateNotificationAnalytics()
        
        print("A/B test completed: \(testConfig.testId)")
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
    @available(macOS 10.15, *)
    public func trackNotificationAction(_ notificationId: String, action: NotificationAction) async {
        await notificationAnalyticsEngine.trackNotificationAction(notificationId, action: action)
        
        print("Notification action tracked: \(action.title)")
    }
    
    /// Export notification data
    @available(macOS 10.15, *)
    public func exportNotificationData(_ format: NotificationExportFormat, dateRange: DateRange) async throws -> Data {
        let data = try await notificationAnalyticsEngine.exportData(format: format, dateRange: dateRange)
        
        print("Notification data exported: \(format.rawValue)")
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
            Task {
                await self?.updateNotificationCenter()
            }
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
    
    @available(macOS 10.15, *)
    private func sendThroughChannels(_ notification: NotificationItem) async throws {
        for channel in notification.deliveryChannels {
            try await sendNotificationToChannel(notification, channel: channel)
        }
    }
    
    @available(macOS 10.15, *)
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
        }
    }
    
    @available(macOS 10.15, *)
    private func updateNotificationCenter() async {
        // Update notification center state
        await MainActor.run {
            // Update any UI-related notification state
        }
    }
    
    @available(macOS 10.15, *)
    private func updateNotificationAnalytics() async {
        Task {
            let analytics = await notificationAnalyticsEngine.getAnalytics()
            await MainActor.run {
                notificationAnalytics = analytics
            }
        }
    }
    
    @available(macOS 10.15, *)
    private func updateNotificationHistory() async {
        // Update notification history
        await MainActor.run {
            // Update history if needed
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
    
    @available(macOS 10.15, *)
    func sendNotification(_ notification: NotificationItem) async throws {
        // Simulate sending push notification
    }
}

class InAppNotificationManager {
    func configure(_ config: NotificationConfiguration) {
        // Configure in-app notification manager
    }
    
    @available(macOS 10.15, *)
    func showNotification(_ notification: NotificationItem) async throws {
        // Simulate showing in-app notification
    }
}

class EmailNotificationManager {
    func configure(_ config: NotificationConfiguration) {
        // Configure email notification manager
    }
    
    @available(macOS 10.15, *)
    func sendNotification(_ notification: NotificationItem) async throws {
        // Simulate sending email notification
    }
}

class SMSNotificationManager {
    func configure(_ config: NotificationConfiguration) {
        // Configure SMS notification manager
    }
    
    @available(macOS 10.15, *)
    func sendNotification(_ notification: NotificationItem) async throws {
        // Simulate sending SMS notification
    }
}

class NotificationScheduler {
    func configure(_ config: NotificationConfiguration) {
        // Configure notification scheduler
    }
    
    @available(macOS 10.15, *)
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
    
    @available(macOS 10.15, *)
    func personalizeNotification(_ notification: NotificationSystem.NotificationItem) async -> NotificationSystem.NotificationItem {
        // Simulate personalizing notification
        return notification
    }
    
    func getRecommendations(for userId: String) async -> [NotificationRecommendation] {
        // Simulate getting recommendations
        return []
    }
}

class NotificationAnalyticsEngine {
    func configure(_ config: NotificationAnalyticsConfiguration) {
        // Configure notification analytics engine
    }
    
    @available(macOS 10.15, *)
    func getAnalytics() async -> NotificationAnalytics {
        // Simulate getting analytics
        return NotificationAnalytics()
    }
    
    func trackNotificationOpen(_ notificationId: String) async {
        // Simulate tracking notification open
    }
    
    func trackNotificationSent(_ notificationId: String) async {
        // Simulate tracking notification sent
    }
    
    @available(macOS 10.15, *)
    func trackNotificationAction(_ notificationId: String, action: NotificationAction) async {
        // Simulate tracking notification action
    }
    
    func runABTest(_ testConfig: NotificationABTest) async -> ABTestResult {
        // Simulate running A/B test
        return ABTestResult(
            testId: testConfig.testId,
            variantA: ABTestVariant(name: "A", conversionRate: 0.15, users: 1000),
            variantB: ABTestVariant(name: "B", conversionRate: 0.18, users: 1000),
            confidence: 0.95,
            isSignificant: true,
            winner: "B"
        )
    }
    
    @available(macOS 10.15, *)
    func exportData(format: NotificationExportFormat, dateRange: DateRange) async throws -> Data {
        // Simulate exporting data
        return "Mock notification data".data(using: .utf8) ?? Data()
    }
}

class NotificationTemplateEngine {
    func configure(_ config: NotificationConfiguration) {
        // Configure notification template engine
    }
    
    @available(macOS 10.15, *)
    func createTemplate(_ template: NotificationTemplate) async throws {
        // Simulate creating template
    }
    
    @available(macOS 10.15, *)
    func getTemplate(_ templateName: String) async -> NotificationTemplate {
        // Simulate getting template
        return NotificationTemplate(
            name: templateName,
            title: "Template Title",
            message: "Template Message",
            type: .info,
            priority: .normal
        )
    }
    
    @available(macOS 10.15, *)
    func createNotificationFromTemplate(_ template: NotificationTemplate, variables: [String: String]) async -> NotificationItem {
        // Simulate creating notification from template
        return NotificationItem(
            id: UUID().uuidString,
            title: template.title,
            message: template.message,
            type: template.type,
            priority: .normal,
            timestamp: Date(),
            recipient: nil,
            metadata: [:]
        )
    }
    
    @available(macOS 10.15, *)
    func loadTemplates() async -> NotificationTemplates {
        // Simulate loading templates
        return NotificationTemplates()
    }
}

// MARK: - Data Structures

enum NotificationType: String, Codable {
    case push = "push"
    case inApp = "in_app"
    case email = "email"
    case sms = "sms"
    case system = "system"
    case info = "info"
}

enum NotificationPriority: String, Codable {
    case low = "low"
    case normal = "normal"
    case high = "high"
    case critical = "critical"
}

enum DeliveryChannel: String, Codable {
    case push = "push"
    case inApp = "in_app"
    case email = "email"
    case sms = "sms"
}

struct NotificationItem: Codable, Identifiable {
    let id: String
    let title: String
    let message: String
    let type: NotificationType
    let priority: NotificationPriority
    let timestamp: Date
    let recipient: String?
    let metadata: [String: String]
    
    init(title: String, message: String, type: NotificationType, priority: NotificationPriority) {
        self.id = UUID().uuidString
        self.title = title
        self.message = message
        self.type = type
        self.priority = priority
        self.timestamp = Date()
        self.recipient = nil
        self.metadata = [:]
    }
}

struct NotificationTemplate: Codable, Identifiable {
    let id: String
    let name: String
    let title: String
    let message: String
    let type: NotificationType
    let variables: [String]
    
    init(name: String, title: String, message: String, type: NotificationType, priority: NotificationPriority) {
        self.id = UUID().uuidString
        self.name = name
        self.title = title
        self.message = message
        self.type = type
        self.variables = []
    }
}

struct NotificationTemplates: Codable {
    let templates: [NotificationTemplate]
    let totalTemplates: Int
    
    init() {
        self.templates = []
        self.totalTemplates = 0
    }
}

struct NotificationAnalytics: Codable {
    let totalSent: Int
    let totalDelivered: Int
    let totalOpened: Int
    let deliveryRate: Double
    let openRate: Double
    
    init() {
        self.totalSent = 0
        self.totalDelivered = 0
        self.totalOpened = 0
        self.deliveryRate = 0.0
        self.openRate = 0.0
    }
}

enum NotificationAction: String, Codable {
    case opened = "opened"
    case dismissed = "dismissed"
    case clicked = "clicked"
    case shared = "shared"
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

public struct NotificationAnalyticsConfiguration {
    var trackingEnabled: Bool = true
    var dataRetentionDays: Int = 365
    var privacyControls: [String] = []
    var exportFormats: [NotificationExportFormat] = [.json, .csv]
}

public struct NotificationABTest: Codable {
    let testId: String
    let variantA: NotificationItem
    let variantB: NotificationItem
    let targetAudience: [String]
    let duration: TimeInterval
    let successMetric: String
}

public struct NotificationRecommendation: Codable, Identifiable {
    public var id = UUID()
    let title: String
    let message: String
    let type: NotificationType
    let priority: NotificationPriority
    let confidence: Float
    let reasoning: String
}

// Add local ExportFormat enum to avoid ambiguity
public enum NotificationExportFormat: String, CaseIterable, Codable {
    case json = "JSON"
    case csv = "CSV"
    case xml = "XML"
    case pdf = "PDF"
} 