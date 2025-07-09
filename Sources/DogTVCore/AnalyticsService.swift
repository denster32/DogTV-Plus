import Foundation
import Combine

/// A service for tracking analytics events and managing analytics data.
@MainActor
public class AnalyticsService: ObservableObject {

    @Published public private(set) var events: [AnalyticsEvent] = []
    @Published public private(set) var currentSession: SessionData?
    @Published public private(set) var usageStatistics = UsageStatistics()
    @Published public private(set) var error: Error?

    private let analyticsFileName = "analytics_events.json"
    private let maxEventCount = 1000 // Clean up when event count exceeds this

    public init() {
        Task {
            await loadEvents()
        }
    }

    // MARK: - Public API

    /// Tracks a new analytics event.
    /// - Parameter event: The event to track.
    public func trackEvent(_ event: AnalyticsEvent) async {
        events.append(event)
        await saveEvents()
        await cleanupEventsIfNeeded()
    }

    /// Starts a new tracking session.
    public func startSession(userID: String) {
        endSession() // End any existing session
        currentSession = SessionData(userID: userID)
        usageStatistics.totalSessions += 1
        print("Analytics session started for user \(userID).")
    }

    /// Ends the current tracking session.
    public func endSession() {
        guard var session = currentSession else { return }
        session.endTime = Date()
        usageStatistics.totalDuration += session.duration
        currentSession = nil
        print("Analytics session ended. Duration: \(session.duration) seconds.")
    }

    /// Tracks scene usage and updates statistics.
    /// - Parameter sceneType: The type of scene that was used.
    public func trackSceneUsage(sceneType: SceneType) {
        let key = sceneType.rawValue
        usageStatistics.sceneUsageCounts[key, default: 0] += 1
    }

    /// Exports all analytics data.
    /// - Returns: A `Data` object containing the analytics data, or `nil` on failure.
    public func exportAnalytics() async -> Data? {
        do {
            let data = try JSONEncoder().encode(self.events)
            return data
        } catch {
            self.error = error
            return nil
        }
    }

    // MARK: - Data Persistence

    /// Saves the analytics events to UserDefaults.
    private func saveEvents() async {
        do {
            let data = try JSONEncoder().encode(events)
            UserDefaults.standard.set(data, forKey: analyticsFileName)
            error = nil
        } catch {
            self.error = error
        }
    }

    /// Loads analytics events from UserDefaults.
    private func loadEvents() async {
        do {
            if let data = UserDefaults.standard.data(forKey: analyticsFileName) {
                let loadedEvents = try JSONDecoder().decode([AnalyticsEvent].self, from: data)
                self.events = loadedEvents
            }
            error = nil
        } catch {
            self.error = error
        }
    }

    // MARK: - Data Management

    /// Cleans up old events if the event count exceeds the maximum.
    private func cleanupEventsIfNeeded() async {
        guard events.count > maxEventCount else { return }

        let eventsToKeep = Array(events.suffix(maxEventCount))
        self.events = eventsToKeep
        await saveEvents()
    }
}
