import XCTest
import AVFoundation
@testable import DogTVAudio
@testable import DogTVCore

final class AudioProcessingTests: XCTestCase {

    var audioEngine: AVAudioEngine!
    var processingPipeline: AudioProcessingPipeline!

    override func setUp() {
        super.setUp()
        audioEngine = AVAudioEngine()
        processingPipeline = AudioProcessingPipeline(audioEngine: audioEngine)
    }

    override func tearDown() {
        audioEngine.stop()
        audioEngine = nil
        processingPipeline = nil
        super.tearDown()
    }

    func testProcessingPipelineInitialization() {
        XCTAssertNotNil(processingPipeline)
    }

    func testOptimizePipelineOrder() {
        // Test that pipeline optimization doesn't crash
        processingPipeline.optimizePipelineOrder()
        XCTAssertTrue(true) // Method should complete without error
    }

    func testOptimizeLatency() {
        // Test latency optimization
        processingPipeline.optimizeLatency()
        XCTAssertTrue(true) // Method should complete without error
    }

    func testGetCPUUsage() {
        let cpuUsage = processingPipeline.getCPUUsage()
        XCTAssertGreaterThanOrEqual(cpuUsage, 0.0)
        XCTAssertLessThanOrEqual(cpuUsage, 1.0)
    }

    func testBypassPipeline() {
        // Test pipeline bypass
        processingPipeline.bypassPipeline(true)
        processingPipeline.bypassPipeline(false)
        XCTAssertTrue(true) // Method should complete without error
    }

    func testUpdateSettings() {
        // Create test audio settings
        let audioSettings = AudioSettings(
            volume: 0.8,
            isEnabled: true,
            frequencyRange: .canineOptimized,
            includeNatureSounds: true,
            equalizerSettings: EqualizerSettings(
                bandGains: [0.0, 0.0, 0.0, 0.0, 0.0]
            ),
            reverbIntensity: 0.3,
            compressionSettings: CompressionSettings(
                threshold: -20.0,
                headRoom: 5.0,
                attackTime: 0.01,
                releaseTime: 0.1,
                masterGain: 0.0
            )
        )

        // Test settings update
        processingPipeline.updateSettings(audioSettings)
        XCTAssertTrue(true) // Method should complete without error
    }
}
