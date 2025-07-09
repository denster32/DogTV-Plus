import Foundation

import Combine

public protocol AnalyticsService {
    func logEvent(_ event: AnalyticsEvent)
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

    public func logEvent(_ event: AnalyticsEvent) {
        print("Logged event: \(event)")
        events.append(event)
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
