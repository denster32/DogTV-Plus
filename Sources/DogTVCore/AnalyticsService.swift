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
        trackEvent(.sessionStart(attributes: ["user_id": AnyEquatable(userID)]))
    }
    
    public func endSession() {
        trackEvent(.sessionEnd(attributes: ["user_id": AnyEquatable(userId ?? "unknown")]))
    }

    public func logEvent(_ event: AnalyticsEvent) {
        trackEvent(event)
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

    private func startNewSession() {
        sessionId = UUID().uuidString
    }
}
