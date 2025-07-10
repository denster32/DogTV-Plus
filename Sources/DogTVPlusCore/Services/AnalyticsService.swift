import Foundation

import Combine

public protocol AnalyticsService {
    func trackEvent(_ event: AnalyticsEvent)
    func startSession(userID: String)
    func endSession()
    func getSessionId() -> String?
    func setUserId(_ userId: String?)
    func reset()
}

public final class CoreAnalyticsService: AnalyticsService, ObservableObject, @unchecked Sendable {
    @MainActor public static let shared = CoreAnalyticsService()

    @Published public private(set) var events: [AnalyticsEvent] = []
    private var sessionId: String?
    private var userId: String?

    private var sessionStartTime: Date?

    private init() {
        startNewSession()
    }

    public func trackEvent(_ event: AnalyticsEvent) {
        print("Logged event: \(event)")
        events.append(event)
    }
    
    public func startSession(userID: String) {
        self.userId = userID
        startNewSession()
        trackEvent(.sessionStart(attributes: [AnyEquatable(userID)]))
    }
    
    public func endSession() {
        trackEvent(.sessionEnd(attributes: [AnyEquatable(userId ?? "unknown")]))
    }

    public func getSessionId() -> String? {
        sessionId
    }

    public func setUserId(_ userId: String?) {
        self.userId = userId
    }

    public func reset() {
        events.removeAll()
        startNewSession()
    }

    /// Get current session duration in seconds
    public var currentSessionDuration: TimeInterval {
        guard let sessionStartTime = sessionStartTime else { return 0 }
        return Date().timeIntervalSince(sessionStartTime)
    }
    
    private func startNewSession() {
        sessionId = UUID().uuidString
        sessionStartTime = Date()
        print("🎯 [Analytics] New session started: \(sessionId ?? "unknown")")
    }
}
