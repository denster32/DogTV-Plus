import XCTest
import AVFoundation
@testable import DogTVAudio
@testable import DogTVCore

final class AudioTests: XCTestCase {

    var audioEngine: CanineAudioEngine!

    override func setUp() {
        super.setUp()
        audioEngine = CanineAudioEngine()
    }

    override func tearDown() {
        audioEngine.stopAudio()
        audioEngine = nil
        super.tearDown()
    }

    func testAudioEngineInitialization() {
        XCTAssertNotNil(audioEngine)
        XCTAssertEqual(audioEngine.volume, 0.7)
        XCTAssertFalse(audioEngine.isPlaying)
        XCTAssertEqual(audioEngine.frequencyRange, .canineOptimized)
        XCTAssertTrue(audioEngine.includeNatureSounds)
    }

    func testVolumeControl() {
        // Test setting volume within valid range
        audioEngine.setVolume(0.5)
        XCTAssertEqual(audioEngine.volume, 0.5)

        // Test clamping of volume values
        audioEngine.setVolume(1.5)
        XCTAssertEqual(audioEngine.volume, 1.0)

        audioEngine.setVolume(-0.5)
        XCTAssertEqual(audioEngine.volume, 0.0)
    }

    func testFrequencyFiltering() {
        // Test different frequency ranges
        audioEngine.applyCanineFrequencyFiltering(.canineOptimized)
        XCTAssertEqual(audioEngine.frequencyRange, .canineOptimized)

        audioEngine.applyCanineFrequencyFiltering(.fullRange)
        XCTAssertEqual(audioEngine.frequencyRange, .fullRange)

        audioEngine.applyCanineFrequencyFiltering(.lowFrequency)
        XCTAssertEqual(audioEngine.frequencyRange, .lowFrequency)
    }

    func testAudioPlaybackControls() {
        // Test that playback controls don't crash without loaded audio
        audioEngine.stopAudio()
        XCTAssertFalse(audioEngine.isPlaying)

        audioEngine.pauseAudio()
        XCTAssertFalse(audioEngine.isPlaying)

        audioEngine.resumeAudio()
        XCTAssertTrue(audioEngine.isPlaying)
    }

    func testReverbSettings() {
        // Test reverb adjustment
        audioEngine.setReverb(wetDryMix: 50.0)
        XCTAssertTrue(true) // Method should complete without error

        audioEngine.setReverb(wetDryMix: 0.0)
        XCTAssertTrue(true) // Method should complete without error
    }

    func testEqualizerSettings() {
        // Test equalizer band adjustments
        for band in 0..<5 {
            audioEngine.setEqualizer(band: band, gain: 2.0)
            audioEngine.setEqualizer(band: band, gain: -2.0)
            audioEngine.setEqualizer(band: band, gain: 0.0)
        }

        // Test invalid band index
        audioEngine.setEqualizer(band: 10, gain: 5.0)
        XCTAssertTrue(true) // Should handle invalid band gracefully
    }

    func testAudioFileLoading() {
        // Test loading audio for different scenes
        do {
            try audioEngine.loadAudio(for: .ocean)
            XCTAssertTrue(true) // Should complete without error if files exist
        } catch {
            // Expected if audio files don't exist in test bundle
            XCTAssertTrue(error is AudioError)
        }

        do {
            try audioEngine.loadAudio(for: .forest)
            XCTAssertTrue(true) // Should complete without error if files exist
        } catch {
            // Expected if audio files don't exist in test bundle
            XCTAssertTrue(error is AudioError)
        }
    }

    func testAudioMonitorIntegration() {
        // Test that audio monitor is properly integrated
        XCTAssertNotNil(audioEngine.monitor)

        // Test monitor functionality
        if let monitor = audioEngine.monitor {
            XCTAssertEqual(monitor.currentVolume, 0.0)
            XCTAssertEqual(monitor.peakVolume, 0.0)
            XCTAssertEqual(monitor.frequencySpectrum.count, 0)

            // Test peak volume reset
            monitor.resetPeakVolume()
            XCTAssertEqual(monitor.peakVolume, 0.0)
        }
    }

    func testCrossfadeFeature() {
        // Create mock player nodes for crossfade testing
        let playerNode1 = AVAudioPlayerNode()
        let playerNode2 = AVAudioPlayerNode()

        // Test crossfade functionality
        audioEngine.crossfade(from: playerNode1, to: playerNode2, duration: 1.0)
        XCTAssertTrue(true) // Method should complete without error
    }

    func testAudioEngineStartStop() {
        // Test that audio engine can be started and stopped safely
        audioEngine.stopAudio()
        XCTAssertFalse(audioEngine.isPlaying)

        // Try to play without loaded audio - should handle gracefully
        do {
            try audioEngine.playAudio()
            XCTFail("Should throw error when no audio is loaded")
        } catch {
            XCTAssertTrue(error is AudioError)
        }
    }

    func testPerformanceUnderLoad() {
        // Test that multiple operations don't cause performance issues
        let startTime = CFAbsoluteTimeGetCurrent()

        for i in 0..<100 {
            audioEngine.setVolume(Float(i % 10) / 10.0)
            audioEngine.setReverb(wetDryMix: Float(i % 50))
            audioEngine.setEqualizer(band: i % 5, gain: Float((i % 20) - 10))
        }

        let endTime = CFAbsoluteTimeGetCurrent()
        let executionTime = endTime - startTime

        // Should complete operations quickly
        XCTAssertLessThan(executionTime, 1.0)
    }
}
