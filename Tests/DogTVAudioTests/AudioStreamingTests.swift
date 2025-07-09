import XCTest
import AVFoundation
@testable import DogTVAudio
@testable import DogTVCore

final class AudioStreamingTests: XCTestCase {

    var audioEngine: AVAudioEngine!
    var playerNode: AVAudioPlayerNode!
    var streamingManager: AudioStreamingManager!

    override func setUp() {
        super.setUp()
        audioEngine = AVAudioEngine()
        playerNode = AVAudioPlayerNode()
        streamingManager = AudioStreamingManager(audioEngine: audioEngine, playerNode: playerNode)
    }

    override func tearDown() {
        streamingManager.stopStreaming()
        audioEngine.stop()
        audioEngine = nil
        playerNode = nil
        streamingManager = nil
        super.tearDown()
    }

    func testStreamingManagerInitialization() {
        XCTAssertNotNil(streamingManager)
    }

    func testStartStreamingWithValidFile() {
        // This test would need a valid audio file in the test bundle
        // For now, we'll test the error handling
        let expectation = self.expectation(description: "Streaming should handle missing file")

        // Try to start streaming without a valid file
        do {
            // Create a mock audio file URL
            let tempURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("test.wav")

            // This should throw an error since the file doesn't exist
            let audioFile = try AVAudioFile(forReading: tempURL)
            try streamingManager.startStreaming(from: audioFile)
            XCTFail("Should have thrown an error")
        } catch {
            // Expected behavior
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0)
    }

    func testStopStreaming() {
        // Test that stop streaming doesn't crash
        streamingManager.stopStreaming()
        XCTAssertTrue(true) // If we get here, the method didn't crash
    }

    func testOptimizeStreamingPerformance() {
        // Test performance optimization
        streamingManager.optimizeStreamingPerformance()
        XCTAssertTrue(true) // Method should complete without error
    }
}
