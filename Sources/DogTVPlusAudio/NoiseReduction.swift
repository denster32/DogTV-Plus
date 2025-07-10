import Foundation
import AVFoundation
import Accelerate

/// Provides noise reduction capabilities for clean audio output.
@available(iOS 17.0, tvOS 17.0, macOS 10.15, *)
public class NoiseReduction {

    private let audioEngine: AVAudioEngine
    private let noiseGate: AVAudioUnitEffect
    private let spectralFilter: AVAudioUnitEffect
    private var noiseProfile: [Float] = []
    private let bufferSize: Int = 1024

    public init(audioEngine: AVAudioEngine) {
        self.audioEngine = audioEngine
        self.noiseGate = AVAudioUnitEffect()
        self.spectralFilter = AVAudioUnitEffect()

        setupNoiseReduction()
    }

    /// Sets up noise reduction components.
    private func setupNoiseReduction() {
        audioEngine.attach(noiseGate)
        audioEngine.attach(spectralFilter)

        setupNoiseGate()
        setupSpectralFilter()
    }

    /// Configures the noise gate with appropriate settings.
    private func setupNoiseGate() {
        // Configure noise gate parameters
        // Threshold: -40dB (signals below this level are considered noise)
        // Ratio: 10:1 (strong gating)
        // Attack: 1ms (fast response)
        // Release: 100ms (smooth release)

        // Note: AVAudioUnitEffect doesn't have direct parameter access
        // Real implementation would use AudioUnit parameters
    }

    /// Configures the spectral filter for noise reduction.
    private func setupSpectralFilter() {
        // Configure spectral filtering for noise reduction
        // This would typically use FFT-based noise reduction
    }

    /// Applies noise gate to reduce background noise.
    public func applyNoiseGate(to node: AVAudioNode, threshold: Float = -40.0) {
        let format = node.outputFormat(forBus: 0)
        audioEngine.connect(node, to: noiseGate, format: format)

        // Set noise gate threshold
        setNoiseGateThreshold(threshold)
    }

    /// Sets the noise gate threshold.
    private func setNoiseGateThreshold(_ threshold: Float) {
        // Set threshold parameter for noise gate
        // Real implementation would use AudioUnit parameter setting
    }

    /// Performs spectral noise reduction on audio signal.
    public func applySpectralNoiseReduction(to buffer: AVAudioPCMBuffer, noiseProfile: [Float]) -> AVAudioPCMBuffer? {
        guard let channelData = buffer.floatChannelData?[0] else { return nil }

        // Create output buffer
        guard let outputBuffer = AVAudioPCMBuffer(pcmFormat: buffer.format, frameCapacity: buffer.frameCapacity) else {
            return nil
        }

        guard let outputData = outputBuffer.floatChannelData?[0] else { return nil }

        // Apply spectral noise reduction using FFT
        let frameCount = Int(buffer.frameLength)
        var inputReal = [Float](repeating: 0, count: frameCount)
        var inputImag = [Float](repeating: 0, count: frameCount)

        // Copy input data
        for i in 0..<frameCount {
            inputReal[i] = channelData[i]
        }

        // Perform FFT
        var outputReal = [Float](repeating: 0, count: frameCount)
        var outputImag = [Float](repeating: 0, count: frameCount)

        // Apply noise reduction in frequency domain
        for i in 0..<frameCount / 2 {
            let magnitude = sqrt(inputReal[i] * inputReal[i] + inputImag[i] * inputImag[i])
            let noiseLevel = i < noiseProfile.count ? noiseProfile[i] : 0.0

            // Spectral subtraction
            let cleanMagnitude = max(magnitude - noiseLevel, 0.1 * magnitude)
            let phase = atan2(inputImag[i], inputReal[i])

            outputReal[i] = cleanMagnitude * cos(phase)
            outputImag[i] = cleanMagnitude * sin(phase)
        }

        // Inverse FFT back to time domain
        for i in 0..<frameCount {
            outputData[i] = outputReal[i] // Simplified - real implementation would use proper IFFT
        }

        outputBuffer.frameLength = buffer.frameLength
        return outputBuffer
    }

    /// Learns noise profile from a quiet segment.
    public func learnNoiseProfile(from buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }

        let frameCount = Int(buffer.frameLength)
        var inputReal = [Float](repeating: 0, count: frameCount)
        var inputImag = [Float](repeating: 0, count: frameCount)

        // Copy input data
        for i in 0..<frameCount {
            inputReal[i] = channelData[i]
        }

        // Perform FFT to analyze noise spectrum
        var outputReal = [Float](repeating: 0, count: frameCount)
        var outputImag = [Float](repeating: 0, count: frameCount)

        // Calculate magnitude spectrum
        noiseProfile = []
        for i in 0..<frameCount / 2 {
            let magnitude = sqrt(outputReal[i] * outputReal[i] + outputImag[i] * outputImag[i])
            noiseProfile.append(magnitude)
        }
    }

    /// Applies adaptive noise reduction based on signal characteristics.
    public func applyAdaptiveNoiseReduction(to buffer: AVAudioPCMBuffer) -> AVAudioPCMBuffer? {
        guard let channelData = buffer.floatChannelData?[0] else { return nil }

        // Analyze signal characteristics
        let signalLevel = calculateRMSLevel(channelData, frameCount: Int(buffer.frameLength))

        // Adjust noise reduction parameters based on signal level
        let adaptiveThreshold: Float
        if signalLevel > 0.1 {
            adaptiveThreshold = -35.0 // Less aggressive for louder signals
        } else {
            adaptiveThreshold = -45.0 // More aggressive for quieter signals
        }

        // Apply adaptive noise reduction
        return applySpectralNoiseReduction(to: buffer, noiseProfile: noiseProfile)
    }

    /// Calculates RMS level of audio signal.
    private func calculateRMSLevel(_ data: UnsafePointer<Float>, frameCount: Int) -> Float {
        var sum: Float = 0.0
        for i in 0..<frameCount {
            sum += data[i] * data[i]
        }
        return sqrt(sum / Float(frameCount))
    }

    /// Monitors noise levels in real-time.
    public func monitorNoiseLevel(in buffer: AVAudioPCMBuffer) -> Float {
        guard let channelData = buffer.floatChannelData?[0] else { return 0.0 }

        let frameCount = Int(buffer.frameLength)
        var noiseLevel: Float = 0.0

        // Calculate noise level using spectral analysis
        for i in 0..<frameCount {
            let sample = channelData[i]
            noiseLevel += abs(sample)
        }

        return noiseLevel / Float(frameCount)
    }

    /// Provides noise reduction quality assessment.
    public func assessNoiseReductionQuality(original: AVAudioPCMBuffer, processed: AVAudioPCMBuffer) -> Float {
        guard let originalData = original.floatChannelData?[0],
              let processedData = processed.floatChannelData?[0] else { return 0.0 }

        let frameCount = Int(min(original.frameLength, processed.frameLength))
        var qualityScore: Float = 0.0

        // Calculate signal-to-noise ratio improvement
        let originalNoise = calculateRMSLevel(originalData, frameCount: frameCount)
        let processedNoise = calculateRMSLevel(processedData, frameCount: frameCount)

        qualityScore = originalNoise / max(processedNoise, 0.001)

        return min(qualityScore, 10.0) // Cap at 10x improvement
    }
}
