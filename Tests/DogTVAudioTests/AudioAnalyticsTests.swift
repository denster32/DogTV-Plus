import Foundation
import XCTest

import AVFoundation

@testable import DogTVAudio
@testable import DogTVCore

class AudioAnalyticsTests: XCTestCase {

    var audioAnalytics: AudioAnalytics!
    var mockAnalyticsService: MockAnalyticsService!

    override func setUp() {
        super.setUp()
        mockAnalyticsService = MockAnalyticsService()
        audioAnalytics = AudioAnalytics(analyticsService: mockAnalyticsService)
    }

    override func tearDown() {
        audioAnalytics = nil
        mockAnalyticsService = nil
        super.tearDown()
    }

    func testStartAndEndSession() {
        audioAnalytics.startSession(scene: .nature)
        XCTAssertNotNil(audioAnalytics.sessionStartTime)
        XCTAssertEqual(audioAnalytics.currentSessionDuration, 0)

        let expectation = XCTestExpectation(description: "Wait for session to end")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.audioAnalytics.endSession()
            XCTAssertNil(self.audioAnalytics.sessionStartTime)
            XCTAssertGreaterThan(self.audioAnalytics.currentSessionDuration, 0)
            XCTAssertEqual(self.mockAnalyticsService.loggedEvents.count, 2) // Start and End
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testAudioQualityTracking() {
        guard let buffer = makeTestBuffer() else {
            XCTFail("Failed to create audio buffer")
            return
        }

        audioAnalytics.trackAudioQuality(buffer: buffer)
        XCTAssertGreaterThan(audioAnalytics.audioQualityScore, 0)
    }

    func testUsageStatistics() {
        audioAnalytics.startSession(scene: .urban)
        audioAnalytics.totalListeningTime = 120
        let stats = audioAnalytics.getUsageStatistics()

        XCTAssertEqual(stats.totalListeningTime, 120)
        XCTAssertEqual(stats.favoriteScene, .urban)
    }

    func testHighAndLowQualityScores() {
        // Create a high-quality buffer (e.g., high dynamic range)
        guard let highQualityBuffer = makeTestBuffer() else {
            XCTFail("Failed to create high quality buffer")
            return
        }
        if let channelData = highQualityBuffer.floatChannelData?[0] {
            for i in 0..<Int(highQualityBuffer.frameLength) {
                channelData[i] = sin(Float(i) * 0.1) * 0.8 // High amplitude
            }
        }
        audioAnalytics.trackAudioQuality(buffer: highQualityBuffer)
        let highQualityScore = audioAnalytics.audioQualityScore

        // Create a low-quality buffer (e.g., clipped audio)
        guard let lowQualityBuffer = makeTestBuffer() else {
            XCTFail("Failed to create low quality buffer")
            return
        }
        if let channelData = lowQualityBuffer.floatChannelData?[0] {
            for i in 0..<Int(lowQualityBuffer.frameLength) {
                channelData[i] = max(-0.1, min(0.1, sin(Float(i) * 0.1))) // Low amplitude, clipped
            }
        }
        audioAnalytics.trackAudioQuality(buffer: lowQualityBuffer)
        let mixedQualityScore = audioAnalytics.audioQualityScore

        // Quality should be affected by the low quality buffer
        XCTAssertLessThan(mixedQualityScore, highQualityScore)
    }

    func testLongRunningSession() {
        // Test analytics with a longer running session
        audioAnalytics.startSession(scene: .stars)

        // Simulate quality tracking over time
        guard let buffer = makeTestBuffer() else {
            XCTFail("Failed to create audio buffer")
            return
        }

        if let channelData = buffer.floatChannelData?[0] {
            for i in 0..<Int(buffer.frameLength) {
                channelData[i] = sin(Float(i) * 0.1) * 0.5 // Example audio data
            }
        }

        for _ in 0..<100 { // Simulate 100 updates
            audioAnalytics.trackAudioQuality(buffer: buffer)
        }

        audioAnalytics.endSession()
        let stats = audioAnalytics.getUsageStatistics()

        // Verify that the session produced some statistics
        XCTAssertNotNil(stats, "Session statistics should not be nil")
        XCTAssertGreaterThan(stats.averageSessionDuration, 0)
        XCTAssertGreaterThan(stats.audioQualityScore, 0)
        XCTAssertEqual(mockAnalyticsService.loggedEvents.count, 2, "Should log start and end events for the session")
    }

    private func makeTestBuffer() -> AVAudioPCMBuffer? {
        guard let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1) else {
            return nil
        }
        let frameCount: AVAudioFrameCount = 1024

        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            return nil
        }
        buffer.frameLength = frameCount
        return buffer
    }
}

// Mock AnalyticsService for testing
class MockAnalyticsService: AnalyticsService {
    var loggedEvents: [AnalyticsEvent] = []

    func logEvent(_ event: AnalyticsEvent) {
        loggedEvents.append(event)
    }

    func getSessionId() -> String? {
        return "mockSessionId"
    }

    func setUserId(_ userId: String?) {
        // No-op
    }

    func reset() {
        loggedEvents.removeAll()
    }
}
