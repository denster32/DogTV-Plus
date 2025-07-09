import Foundation
import AVFoundation
import Combine
import DogTVCore

/// Provides audio analytics and usage tracking capabilities.
@available(iOS 17.0, tvOS 17.0, macOS 10.15, *)
public class AudioAnalytics: ObservableObject {

    // MARK: - Published Properties
    @Published public var currentSessionDuration: TimeInterval = 0
    @Published public var totalListeningTime: TimeInterval = 0
    @Published public var averageVolume: Float = 0
    @Published public var peakVolume: Float = 0
    @Published public var frequencyDistribution: [Float] = []
    @Published public var audioQualityScore: Float = 0

    // MARK: - Private Properties
    private var sessionStartTime: Date?
    private var audioMonitor: AudioMonitor?
    private var volumeHistory: [Float] = []
    private var qualityMeasurements: [Float] = []
    private var scenePlayCounts: [SceneType: Int] = [:]
    private var sessionData: [AudioSessionData] = []
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    public init() {
        setupAnalytics()
    }

    /// Sets up analytics tracking.
    private func setupAnalytics() {
        // Load existing analytics data
        loadAnalyticsData()

        // Start periodic analytics updates
        Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateAnalytics()
            }
            .store(in: &cancellables)
    }

    // MARK: - Session Tracking

    /// Starts a new audio session.
    public func startSession(scene: SceneType) {
        sessionStartTime = Date()
        currentSessionDuration = 0

        // Update scene play count
        scenePlayCounts[scene, default: 0] += 1

        // Create session data
        let sessionData = AudioSessionData(
            id: UUID(),
            scene: scene,
            startTime: Date(),
            endTime: nil,
            duration: 0,
            averageVolume: 0,
            peakVolume: 0,
            qualityScore: 0
        )

        self.sessionData.append(sessionData)

        // Track session start event
        trackEvent(.sessionStarted(scene: scene))
    }

    /// Ends the current audio session.
    public func endSession() {
        guard let startTime = sessionStartTime else { return }

        let duration = Date().timeIntervalSince(startTime)
        currentSessionDuration = duration
        totalListeningTime += duration

        // Update last session data
        if var lastSession = sessionData.last {
            lastSession.endTime = Date()
            lastSession.duration = duration
            lastSession.averageVolume = averageVolume
            lastSession.peakVolume = peakVolume
            lastSession.qualityScore = audioQualityScore

            sessionData[sessionData.count - 1] = lastSession
        }

        // Reset session tracking
        sessionStartTime = nil

        // Save analytics data
        saveAnalyticsData()

        // Track session end event
        trackEvent(.sessionEnded(duration: duration))
    }

    /// Pauses the current session.
    public func pauseSession() {
        trackEvent(.sessionPaused)
    }

    /// Resumes the current session.
    public func resumeSession() {
        trackEvent(.sessionResumed)
    }

    // MARK: - Audio Quality Tracking

    /// Tracks audio quality metrics.
    public func trackAudioQuality(buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }

        let frameCount = Int(buffer.frameLength)

        // Calculate volume metrics
        var rms: Float = 0.0
        var peak: Float = 0.0

        for i in 0..<frameCount {
            let sample = abs(channelData[i])
            rms += sample * sample
            peak = max(peak, sample)
        }

        rms = sqrt(rms / Float(frameCount))

        // Update volume history
        volumeHistory.append(rms)
        if volumeHistory.count > 1000 {
            volumeHistory.removeFirst()
        }

        // Calculate average volume
        averageVolume = volumeHistory.reduce(0, +) / Float(volumeHistory.count)

        // Update peak volume
        if peak > peakVolume {
            peakVolume = peak
        }

        // Calculate quality score
        let qualityScore = calculateAudioQualityScore(rms: rms, peak: peak)
        qualityMeasurements.append(qualityScore)
        if qualityMeasurements.count > 100 {
            qualityMeasurements.removeFirst()
        }

        audioQualityScore = qualityMeasurements.reduce(0, +) / Float(qualityMeasurements.count)
    }

    /// Calculates audio quality score based on various metrics.
    private func calculateAudioQualityScore(rms: Float, peak: Float) -> Float {
        // Dynamic range score (0-40 points)
        let dynamicRange = peak - rms
        let dynamicRangeScore = min(dynamicRange * 20, 40)

        // Volume consistency score (0-30 points)
        let volumeConsistency = 1.0 - (peak - rms) / max(peak, 0.01)
        let consistencyScore = volumeConsistency * 30

        // Optimal level score (0-30 points)
        let optimalLevel = 1.0 - abs(rms - 0.5) * 2 // Optimal RMS around 0.5
        let levelScore = optimalLevel * 30

        return dynamicRangeScore + consistencyScore + levelScore
    }

    // MARK: - Usage Statistics

    /// Gets comprehensive usage statistics.
    public func getUsageStatistics() -> AudioUsageStatistics {
        AudioUsageStatistics(
            totalListeningTime: totalListeningTime,
            totalSessions: sessionData.count,
            averageSessionDuration: totalListeningTime / max(Double(sessionData.count), 1),
            favoriteScene: getMostPlayedScene(),
            scenePlayCounts: scenePlayCounts,
            averageVolume: averageVolume,
            peakVolume: peakVolume,
            audioQualityScore: audioQualityScore,
            lastSessionDate: sessionData.last?.startTime
        )
    }

    /// Gets the most played scene.
    private func getMostPlayedScene() -> SceneType? {
        scenePlayCounts.max { $0.value < $1.value }?.key
    }

    /// Exports analytics data for external analysis.
    public func exportAnalyticsData() -> Data? {
        let exportData = AudioAnalyticsExportData(
            sessionData: sessionData,
            scenePlayCounts: scenePlayCounts,
            totalListeningTime: totalListeningTime,
            averageVolume: averageVolume,
            peakVolume: peakVolume,
            audioQualityScore: audioQualityScore,
            exportDate: Date()
        )

        return try? JSONEncoder().encode(exportData)
    }

    // MARK: - Event Tracking

    /// Tracks audio events.
    private func trackEvent(_ event: AudioEvent) {
        // Log event for analytics
        print("Audio Event: \(event)")

        // Here you would typically send to analytics service
        // For now, we'll just print to console
    }

    // MARK: - Private Methods

    /// Updates analytics in real-time.
    private func updateAnalytics() {
        guard let startTime = sessionStartTime else { return }

        currentSessionDuration = Date().timeIntervalSince(startTime)

        // Update frequency distribution if monitor is available
        if let monitor = audioMonitor {
            frequencyDistribution = monitor.frequencySpectrum
        }
    }

    /// Loads analytics data from storage.
    private func loadAnalyticsData() {
        // Load from UserDefaults or file storage
        if let data = UserDefaults.standard.data(forKey: "AudioAnalyticsData") {
            do {
                let decoded = try JSONDecoder().decode(AudioAnalyticsStorageData.self, from: data)
                totalListeningTime = decoded.totalListeningTime
                scenePlayCounts = decoded.scenePlayCounts
                averageVolume = decoded.averageVolume
                peakVolume = decoded.peakVolume
                audioQualityScore = decoded.audioQualityScore
            } catch {
                print("Failed to load analytics data: \(error)")
            }
        }
    }

    /// Saves analytics data to storage.
    private func saveAnalyticsData() {
        let storageData = AudioAnalyticsStorageData(
            totalListeningTime: totalListeningTime,
            scenePlayCounts: scenePlayCounts,
            averageVolume: averageVolume,
            peakVolume: peakVolume,
            audioQualityScore: audioQualityScore
        )

        do {
            let encoded = try JSONEncoder().encode(storageData)
            UserDefaults.standard.set(encoded, forKey: "AudioAnalyticsData")
        } catch {
            print("Failed to save analytics data: \(error)")
        }
    }
}

// MARK: - Data Models

/// Represents a single audio session.
public struct AudioSessionData: Codable {
    let id: UUID
    let scene: SceneType
    let startTime: Date
    var endTime: Date?
    var duration: TimeInterval
    var averageVolume: Float
    var peakVolume: Float
    var qualityScore: Float
}

/// Comprehensive usage statistics.
public struct AudioUsageStatistics {
    let totalListeningTime: TimeInterval
    let totalSessions: Int
    let averageSessionDuration: TimeInterval
    let favoriteScene: SceneType?
    let scenePlayCounts: [SceneType: Int]
    let averageVolume: Float
    let peakVolume: Float
    let audioQualityScore: Float
    let lastSessionDate: Date?
}

/// Data for analytics export.
private struct AudioAnalyticsExportData: Codable {
    let sessionData: [AudioSessionData]
    let scenePlayCounts: [SceneType: Int]
    let totalListeningTime: TimeInterval
    let averageVolume: Float
    let peakVolume: Float
    let audioQualityScore: Float
    let exportDate: Date
}

/// Data for analytics storage.
private struct AudioAnalyticsStorageData: Codable {
    let totalListeningTime: TimeInterval
    let scenePlayCounts: [SceneType: Int]
    let averageVolume: Float
    let peakVolume: Float
    let audioQualityScore: Float
}

/// Audio events for tracking.
public enum AudioEvent {
    case sessionStarted(scene: SceneType)
    case sessionEnded(duration: TimeInterval)
    case sessionPaused
    case sessionResumed
    case volumeChanged(from: Float, to: Float)
    case sceneChanged(from: SceneType, to: SceneType)
    case audioError(Error)
    case qualityIssue(score: Float)
}
