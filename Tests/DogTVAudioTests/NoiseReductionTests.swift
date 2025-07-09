import XCTest
import AVFoundation
@testable import DogTVAudio

final class NoiseReductionTests: XCTestCase {

    var audioEngine: AVAudioEngine!
    var noiseReduction: NoiseReduction!

    override func setUp() {
        super.setUp()
        audioEngine = AVAudioEngine()
        noiseReduction = NoiseReduction(audioEngine: audioEngine)
    }

    override func tearDown() {
        audioEngine.stop()
        audioEngine = nil
        noiseReduction = nil
        super.tearDown()
    }

    func testNoiseReductionInitialization() {
        XCTAssertNotNil(noiseReduction)
    }

    func testApplyNoiseGate() {
        // Test applying noise gate to audio engine output
        noiseReduction.applyNoiseGate(to: audioEngine.outputNode, threshold: -40.0)
        XCTAssertTrue(true) // Method should complete without error
    }

    func testSpectralNoiseReduction() {
        // Create a test audio buffer
        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
        let frameCount: AVAudioFrameCount = 1024

        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            XCTFail("Failed to create audio buffer")
            return
        }

        buffer.frameLength = frameCount

        // Fill buffer with test data
        if let channelData = buffer.floatChannelData?[0] {
            for i in 0..<Int(frameCount) {
                channelData[i] = sin(2.0 * Float.pi * 440.0 * Float(i) / 44100.0) * 0.5
            }
        }

        // Create noise profile
        let noiseProfile = [Float](repeating: 0.1, count: Int(frameCount / 2))

        // Test spectral noise reduction
        let processedBuffer = noiseReduction.applySpectralNoiseReduction(to: buffer, noiseProfile: noiseProfile)
        XCTAssertNotNil(processedBuffer)
        XCTAssertEqual(processedBuffer?.frameLength, buffer.frameLength)
    }

    func testLearnNoiseProfile() {
        // Create a test audio buffer with noise
        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
        let frameCount: AVAudioFrameCount = 1024

        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            XCTFail("Failed to create audio buffer")
            return
        }

        buffer.frameLength = frameCount

        // Fill buffer with noise (random values)
        if let channelData = buffer.floatChannelData?[0] {
            for i in 0..<Int(frameCount) {
                channelData[i] = Float.random(in: -0.1...0.1)
            }
        }

        // Test noise profile learning
        noiseReduction.learnNoiseProfile(from: buffer)
        XCTAssertTrue(true) // Method should complete without error
    }

    func testAdaptiveNoiseReduction() {
        // Create a test audio buffer
        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
        let frameCount: AVAudioFrameCount = 1024

        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            XCTFail("Failed to create audio buffer")
            return
        }

        buffer.frameLength = frameCount

        // Fill buffer with test signal
        if let channelData = buffer.floatChannelData?[0] {
            for i in 0..<Int(frameCount) {
                channelData[i] = sin(2.0 * Float.pi * 440.0 * Float(i) / 44100.0) * 0.5
            }
        }

        // Test adaptive noise reduction
        let processedBuffer = noiseReduction.applyAdaptiveNoiseReduction(to: buffer)
        XCTAssertNotNil(processedBuffer)
    }

    func testMonitorNoiseLevel() {
        // Create a test audio buffer
        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
        let frameCount: AVAudioFrameCount = 1024

        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            XCTFail("Failed to create audio buffer")
            return
        }

        buffer.frameLength = frameCount

        // Fill buffer with known noise level
        if let channelData = buffer.floatChannelData?[0] {
            for i in 0..<Int(frameCount) {
                channelData[i] = 0.1 // Constant noise level
            }
        }

        // Test noise level monitoring
        let noiseLevel = noiseReduction.monitorNoiseLevel(in: buffer)
        XCTAssertGreaterThan(noiseLevel, 0.0)
        XCTAssertLessThan(noiseLevel, 1.0)
    }

    func testAssessNoiseReductionQuality() {
        // Create original and processed test buffers
        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
        let frameCount: AVAudioFrameCount = 1024

        guard let originalBuffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount),
              let processedBuffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            XCTFail("Failed to create audio buffers")
            return
        }

        originalBuffer.frameLength = frameCount
        processedBuffer.frameLength = frameCount

        // Fill original buffer with noisy signal
        if let channelData = originalBuffer.floatChannelData?[0] {
            for i in 0..<Int(frameCount) {
                channelData[i] = sin(2.0 * Float.pi * 440.0 * Float(i) / 44100.0) * 0.5 + Float.random(in: -0.1...0.1)
            }
        }

        // Fill processed buffer with cleaner signal
        if let channelData = processedBuffer.floatChannelData?[0] {
            for i in 0..<Int(frameCount) {
                channelData[i] = sin(2.0 * Float.pi * 440.0 * Float(i) / 44100.0) * 0.5 + Float.random(in: -0.05...0.05)
            }
        }

        // Test quality assessment
        let qualityScore = noiseReduction.assessNoiseReductionQuality(original: originalBuffer, processed: processedBuffer)
        XCTAssertGreaterThan(qualityScore, 0.0)
        XCTAssertLessThanOrEqual(qualityScore, 10.0)
    }
}
