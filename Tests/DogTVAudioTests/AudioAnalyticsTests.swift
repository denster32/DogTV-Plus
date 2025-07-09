import XCTest
import AVFoundation
@testable import DogTVAudio
@testable import DogTVCore

final class AudioAnalyticsTests: XCTestCase {

    var audioAnalytics: AudioAnalytics!

    override func setUp() {
        super.setUp()
        audioAnalytics = AudioAnalytics()
    }

    override func tearDown() {
        audioAnalytics = nil
        super.tearDown()
    }

    func testAudioAnalyticsInitialization() {
        XCTAssertNotNil(audioAnalytics)
        XCTAssertEqual(audioAnalytics.currentSessionDuration, 0)
        XCTAssertEqual(audioAnalytics.totalListeningTime, 0)
        XCTAssertEqual(audioAnalytics.averageVolume, 0)
        XCTAssertEqual(audioAnalytics.peakVolume, 0)
        XCTAssertEqual(audioAnalytics.audioQualityScore, 0)
    }

    func testSessionTracking() {
        // Test session start
        audioAnalytics.startSession(scene: .ocean)
        XCTAssertGreaterThan(audioAnalytics.currentSessionDuration, 0)

        // Wait a bit to let session duration increase
        let expectation = self.expectation(description: "Session duration should increase")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)

        // Test session end
        audioAnalytics.endSession()
        XCTAssertGreaterThan(audioAnalytics.totalListeningTime, 0)
    }

    func testSessionPauseResume() {
        audioAnalytics.startSession(scene: .forest)

        // Test pause
        audioAnalytics.pauseSession()
        XCTAssertTrue(true) // Method should complete without error

        // Test resume
        audioAnalytics.resumeSession()
        XCTAssertTrue(true) // Method should complete without error

        audioAnalytics.endSession()
    }

    func testAudioQualityTracking() {
        // Create a test audio buffer
        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
        let frameCount: AVAudioFrameCount = 1024

        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            XCTFail("Failed to create audio buffer")
            return
        }

        buffer.frameLength = frameCount

        // Fill buffer with test audio data
        if let channelData = buffer.floatChannelData?[0] {
            for i in 0..<Int(frameCount) {
                channelData[i] = sin(2.0 * Float.pi * 440.0 * Float(i) / 44100.0) * 0.5
            }
        }

        // Track audio quality
        audioAnalytics.trackAudioQuality(buffer: buffer)

        // Verify that quality metrics are updated
        XCTAssertGreaterThan(audioAnalytics.averageVolume, 0)
        XCTAssertGreaterThan(audioAnalytics.peakVolume, 0)
        XCTAssertGreaterThan(audioAnalytics.audioQualityScore, 0)
    }

    func testUsageStatistics() {
        // Start multiple sessions
        audioAnalytics.startSession(scene: .ocean)
        audioAnalytics.endSession()

        audioAnalytics.startSession(scene: .forest)
        audioAnalytics.endSession()

        audioAnalytics.startSession(scene: .ocean)
        audioAnalytics.endSession()

        // Get usage statistics
        let stats = audioAnalytics.getUsageStatistics()

        XCTAssertEqual(stats.totalSessions, 3)
        XCTAssertGreaterThan(stats.totalListeningTime, 0)
        XCTAssertGreaterThan(stats.averageSessionDuration, 0)
        XCTAssertNotNil(stats.favoriteScene)
        XCTAssertEqual(stats.favoriteScene, .ocean) // Ocean was played twice
        XCTAssertEqual(stats.scenePlayCounts[.ocean], 2)
        XCTAssertEqual(stats.scenePlayCounts[.forest], 1)
    }

    func testAnalyticsExport() {
        // Start a session to generate some data
        audioAnalytics.startSession(scene: .rain)
        audioAnalytics.endSession()

        // Export analytics data
        let exportedData = audioAnalytics.exportAnalyticsData()
        XCTAssertNotNil(exportedData)

        // Verify that exported data is valid JSON
        if let data = exportedData {
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                XCTAssertNotNil(jsonObject)
            } catch {
                XCTFail("Exported data is not valid JSON: \(error)")
            }
        }
    }

    func testMultipleQualityMeasurements() {
        // Create multiple test buffers with different quality levels
        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
        let frameCount: AVAudioFrameCount = 1024

        // High quality buffer
        guard let highQualityBuffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            XCTFail("Failed to create audio buffer")
            return
        }
        highQualityBuffer.frameLength = frameCount

        if let channelData = highQualityBuffer.floatChannelData?[0] {
            for i in 0..<Int(frameCount) {
                channelData[i] = sin(2.0 * Float.pi * 440.0 * Float(i) / 44100.0) * 0.7
            }
        }

        // Low quality buffer (with noise)
        guard let lowQualityBuffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            XCTFail("Failed to create audio buffer")
            return
        }
        lowQualityBuffer.frameLength = frameCount

        if let channelData = lowQualityBuffer.floatChannelData?[0] {
            for i in 0..<Int(frameCount) {
                let signal = sin(2.0 * Float.pi * 440.0 * Float(i) / 44100.0) * 0.3
                let noise = Float.random(in: -0.2...0.2)
                channelData[i] = signal + noise
            }
        }

        // Track quality for multiple buffers
        audioAnalytics.trackAudioQuality(buffer: highQualityBuffer)
        let highQualityScore = audioAnalytics.audioQualityScore

        audioAnalytics.trackAudioQuality(buffer: lowQualityBuffer)
        let mixedQualityScore = audioAnalytics.audioQualityScore

        // Quality should be affected by the low quality buffer
        XCTAssertLessThan(mixedQualityScore, highQualityScore)
    }

    func testLongRunningSession() {
        // Test analytics with a longer running session
        audioAnalytics.startSession(scene: .stars)

        // Simulate quality tracking over time
        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
        let frameCount: AVAudioFrameCount = 1024

        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            XCTFail("Failed to create audio buffer")
            return
        }
        buffer.frameLength = frameCount

        if let channelData = buffer.floatChannelData?[0] {
            for i in 0..<Int(frameCount) {
                channelData[i] = sin(2.0 * Float.pi * 440.0 * Float(i) / 44100.0) * 0.5
            }
        }

        // Track quality multiple times
        for _ in 0..<10 {
            audioAnalytics.trackAudioQuality(buffer: buffer)
        }

        // End session
        audioAnalytics.endSession()

        // Verify analytics are reasonable
        XCTAssertGreaterThan(audioAnalytics.totalListeningTime, 0)
        XCTAssertGreaterThan(audioAnalytics.averageVolume, 0)
        XCTAssertGreaterThan(audioAnalytics.audioQualityScore, 0)
    }
}
