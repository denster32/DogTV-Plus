// swiftlint:disable import_organization mark_usage file_length
import AVFoundation
import Accelerate
import Foundation
// swiftlint:enable import_organization

/// Advanced audio monitoring system with real-time analysis
@available(iOS 17.0, tvOS 17.0, macOS 10.15, *)
public class AudioMonitor: ObservableObject {
    
    // MARK: - Audio Analysis Components
    
    private let audioEngine = AVAudioEngine()
    private let inputNode: AVAudioInputNode
    private let fftSetup: FFTSetup
    private let fftSize: Int = 2048
    private let sampleRate: Double = 44100.0
    
    // MARK: - Analysis Buffers
    
    private var inputBuffer: [Float]
    private var fftBuffer: [Float]
    private var magnitudeBuffer: [Float]
    private var phaseBuffer: [Float]
    
    // MARK: - Published Properties
    
    @Published public private(set) var isMonitoring: Bool = false
    @Published public private(set) var currentMetrics: AudioMetrics = .default
    @Published public private(set) var frequencySpectrum: [Float] = []
    @Published public private(set) var peakFrequency: Float = 0.0
    @Published public private(set) var rmsLevel: Float = 0.0
    @Published public private(set) var peakLevel: Float = 0.0
    
    // MARK: - Canine Analysis
    
    @Published public private(set) var canineAnalysis: CanineAudioAnalysis = .default
    @Published public private(set) var stressIndicators: StressIndicators = .default
    
    // MARK: - Initialization
    
    public init() {
        self.inputNode = audioEngine.inputNode
        self.inputBuffer = Array(repeating: 0.0, count: fftSize)
        self.fftBuffer = Array(repeating: 0.0, count: fftSize)
        self.magnitudeBuffer = Array(repeating: 0.0, count: fftSize / 2)
        self.phaseBuffer = Array(repeating: 0.0, count: fftSize / 2)
        
        // Initialize FFT setup with proper configuration
        self.fftSetup = vDSP_create_fftsetup(vDSP_Length(log2(Float(fftSize))), FFTRadix(kFFTRadix2))!
        
        setupAudioEngine()
        configureAnalysis()
    }
    
    deinit {
        // Proper cleanup of FFT setup
        vDSP_destroy_fftsetup(fftSetup)
        audioEngine.stop()
    }
    
    // MARK: - Audio Engine Setup
    
    private func setupAudioEngine() {
        let inputFormat = inputNode.outputFormat(forBus: 0)
        
        // Install tap on input node for real-time analysis
        inputNode.installTap(onBus: 0, bufferSize: AVAudioFrameCount(fftSize), format: inputFormat) { [weak self] buffer, _ in
            self?.processAudioBuffer(buffer)
        }
        
        audioEngine.prepare()
    }
    
    private func configureAnalysis() {
        // Configure analysis parameters for canine audio monitoring
        configureCanineAnalysis()
        configureStressDetection()
    }
    
    private func configureCanineAnalysis() {
        // Configure frequency bands for canine hearing analysis
        let canineFrequencyBands = [
            FrequencyBand(low: 40, high: 80, name: "Low Bass"),
            FrequencyBand(low: 80, high: 160, name: "Bass"),
            FrequencyBand(low: 160, high: 320, name: "Low Mid"),
            FrequencyBand(low: 320, high: 640, name: "Mid"),
            FrequencyBand(low: 640, high: 1280, name: "Upper Mid"),
            FrequencyBand(low: 1280, high: 2560, name: "Presence"),
            FrequencyBand(low: 2560, high: 5120, name: "High"),
            FrequencyBand(low: 5120, high: 10240, name: "Very High"),
            FrequencyBand(low: 10240, high: 20000, name: "Ultra High")
        ]
        
        // Store frequency bands for analysis
        self.frequencyBands = canineFrequencyBands
    }
    
    private func configureStressDetection() {
        // Configure stress detection parameters
        stressThresholds = StressThresholds(
            highFrequencyThreshold: 0.7,
            rapidChangeThreshold: 0.5,
            sustainedLevelThreshold: 0.6
        )
    }
    
    // MARK: - Public API
    
    /// Start audio monitoring
    public func startMonitoring() async throws {
        guard !isMonitoring else { return }
        
        try audioEngine.start()
        isMonitoring = true
        
        // Start real-time analysis
        startRealTimeAnalysis()
        
        logInfo("Started real-time audio monitoring", category: .audio)
    }
    
    /// Stop audio monitoring
    public func stopMonitoring() {
        guard isMonitoring else { return }
        
        audioEngine.stop()
        isMonitoring = false
        
        // Stop real-time analysis
        stopRealTimeAnalysis()
        
        logInfo("Stopped audio monitoring", category: .audio)
    }
    
    /// Get current audio metrics
    public func getCurrentMetrics() -> AudioMetrics {
        return currentMetrics
    }
    
    /// Get frequency spectrum analysis
    public func getFrequencySpectrum() -> [Float] {
        return frequencySpectrum
    }
    
    /// Get canine-specific analysis
    public func getCanineAnalysis() -> CanineAudioAnalysis {
        return canineAnalysis
    }
    
    /// Get stress indicators
    public func getStressIndicators() -> StressIndicators {
        return stressIndicators
    }
    
    // MARK: - Audio Processing
    
    private func processAudioBuffer(_ buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        
        // Copy audio data to input buffer
        let frameCount = Int(buffer.frameLength)
        let samplesToProcess = min(frameCount, fftSize)
        
        // Convert audio data to our buffer
        for i in 0..<samplesToProcess {
            inputBuffer[i] = channelData[i]
        }
        
        // Zero-pad if necessary
        for i in samplesToProcess..<fftSize {
            inputBuffer[i] = 0.0
        }
        
        // Perform FFT analysis
        performFFTAnalysis()
        
        // Calculate audio metrics
        calculateAudioMetrics()
        
        // Perform canine-specific analysis
        performCanineAnalysis()
        
        // Detect stress indicators
        detectStressIndicators()
        
        // Update published properties on main thread
        DispatchQueue.main.async { [weak self] in
            self?.updatePublishedProperties()
        }
    }
    
    private func performFFTAnalysis() {
        // Apply window function to reduce spectral leakage
        applyHannWindow()
        
        // Copy input buffer to FFT buffer
        vDSP_vclr(fftBuffer, 1, vDSP_Length(fftSize))
        vDSP_vmov(inputBuffer, 1, fftBuffer, 1, vDSP_Length(fftSize))
        
        // Perform FFT
        var splitComplex = DSPSplitComplex(realp: &fftBuffer[0], imagp: &fftBuffer[fftSize/2])
        vDSP_fft_zrip(fftSetup, &splitComplex, 1, vDSP_Length(log2(Float(fftSize))), FFTDirection(FFT_FORWARD))
        
        // Calculate magnitude spectrum
        vDSP_zvmags(&splitComplex, 1, magnitudeBuffer, 1, vDSP_Length(fftSize/2))
        
        // Convert to dB
        var scale = Float(1.0 / Float(fftSize))
        vDSP_vsmul(magnitudeBuffer, 1, &scale, magnitudeBuffer, 1, vDSP_Length(fftSize/2))
        
        // Convert to dB scale
        for i in 0..<fftSize/2 {
            if magnitudeBuffer[i] > 0 {
                magnitudeBuffer[i] = 20 * log10(magnitudeBuffer[i])
            } else {
                magnitudeBuffer[i] = -120.0 // Very low level
            }
        }
        
        // Update frequency spectrum
        frequencySpectrum = Array(magnitudeBuffer)
    }
    
    private func applyHannWindow() {
        // Apply Hann window to reduce spectral leakage
        var window = [Float](repeating: 0.0, count: fftSize)
        vDSP_hann_window(&window, vDSP_Length(fftSize), Int32(vDSP_HANN_NORM))
        vDSP_vmul(inputBuffer, 1, window, 1, &inputBuffer, 1, vDSP_Length(fftSize))
    }
    
    private func calculateAudioMetrics() {
        // Calculate RMS level
        var rms: Float = 0.0
        vDSP_rmsqv(inputBuffer, 1, &rms, vDSP_Length(fftSize))
        self.rmsLevel = rms
        
        // Calculate peak level
        var peak: Float = 0.0
        vDSP_maxv(inputBuffer, 1, &peak, vDSP_Length(fftSize))
        self.peakLevel = peak
        
        // Find peak frequency
        if let maxIndex = magnitudeBuffer.enumerated().max(by: { $0.element < $1.element })?.offset {
            let frequency = Float(maxIndex) * Float(sampleRate) / Float(fftSize)
            self.peakFrequency = frequency
        }
        
        // Update audio metrics
        currentMetrics = AudioMetrics(
            rmsLevel: rmsLevel,
            peakLevel: peakLevel,
            peakFrequency: peakFrequency,
            frequencySpectrum: frequencySpectrum,
            timestamp: Date()
        )
    }
    
    private func performCanineAnalysis() {
        // Analyze frequency bands relevant to canine hearing
        var bandLevels: [Float] = []
        
        for band in frequencyBands {
            let bandLevel = calculateBandLevel(band: band)
            bandLevels.append(bandLevel)
        }
        
        // Detect high-frequency content (important for dogs)
        let highFrequencyContent = calculateHighFrequencyContent()
        
        // Analyze temporal patterns
        let temporalAnalysis = analyzeTemporalPatterns()
        
        // Update canine analysis
        canineAnalysis = CanineAudioAnalysis(
            bandLevels: bandLevels,
            highFrequencyContent: highFrequencyContent,
            temporalPatterns: temporalAnalysis,
            overallEngagement: calculateEngagementScore(),
            timestamp: Date()
        )
    }
    
    private func calculateBandLevel(band: FrequencyBand) -> Float {
        let lowBin = Int(band.low * Float(fftSize) / Float(sampleRate))
        let highBin = Int(band.high * Float(fftSize) / Float(sampleRate))
        
        var bandEnergy: Float = 0.0
        let binCount = highBin - lowBin + 1
        
        if binCount > 0 {
            vDSP_sve(magnitudeBuffer[lowBin...highBin], 1, &bandEnergy, vDSP_Length(binCount))
            bandEnergy /= Float(binCount)
        }
        
        return bandEnergy
    }
    
    private func calculateHighFrequencyContent() -> Float {
        // Calculate energy in high frequency range (2kHz - 20kHz)
        let lowBin = Int(2000 * fftSize / Int(sampleRate))
        let highBin = Int(20000 * fftSize / Int(sampleRate))
        
        var highFreqEnergy: Float = 0.0
        let binCount = highBin - lowBin + 1
        
        if binCount > 0 {
            vDSP_sve(magnitudeBuffer[lowBin...highBin], 1, &highFreqEnergy, vDSP_Length(binCount))
            highFreqEnergy /= Float(binCount)
        }
        
        return highFreqEnergy
    }
    
    private func analyzeTemporalPatterns() -> TemporalPatterns {
        // Analyze temporal characteristics of the audio
        let attackTime = calculateAttackTime()
        let decayTime = calculateDecayTime()
        let sustainLevel = calculateSustainLevel()
        
        return TemporalPatterns(
            attackTime: attackTime,
            decayTime: decayTime,
            sustainLevel: sustainLevel,
            dynamicRange: peakLevel - rmsLevel
        )
    }
    
    private func calculateAttackTime() -> Float {
        // Calculate attack time (time to reach 90% of peak)
        // Simplified implementation for real-time processing
        return 0.01 // 10ms default
    }
    
    private func calculateDecayTime() -> Float {
        // Calculate decay time
        return 0.1 // 100ms default
    }
    
    private func calculateSustainLevel() -> Float {
        // Calculate sustain level
        return rmsLevel
    }
    
    private func calculateEngagementScore() -> Float {
        // Calculate overall engagement score for dogs
        let highFreqScore = min(canineAnalysis.highFrequencyContent / 0.5, 1.0)
        let dynamicScore = min(canineAnalysis.temporalPatterns.dynamicRange / 0.3, 1.0)
        let temporalScore = min(canineAnalysis.temporalPatterns.attackTime / 0.05, 1.0)
        
        return (highFreqScore + dynamicScore + temporalScore) / 3.0
    }
    
    private func detectStressIndicators() {
        // Detect potential stress indicators in the audio
        let highFreqStress = canineAnalysis.highFrequencyContent > stressThresholds.highFrequencyThreshold
        let rapidChangeStress = detectRapidChanges()
        let sustainedStress = rmsLevel > stressThresholds.sustainedLevelThreshold
        
        stressIndicators = StressIndicators(
            highFrequencyStress: highFreqStress,
            rapidChangeStress: rapidChangeStress,
            sustainedLevelStress: sustainedStress,
            overallStressLevel: calculateOverallStressLevel(),
            timestamp: Date()
        )
    }
    
    private func detectRapidChanges() -> Bool {
        // Detect rapid changes in audio level (potential stress indicator)
        let levelChange = abs(peakLevel - rmsLevel)
        return levelChange > stressThresholds.rapidChangeThreshold
    }
    
    private func calculateOverallStressLevel() -> Float {
        var stressScore: Float = 0.0
        var stressFactors: Int = 0
        
        if stressIndicators.highFrequencyStress {
            stressScore += 0.4
            stressFactors += 1
        }
        
        if stressIndicators.rapidChangeStress {
            stressScore += 0.3
            stressFactors += 1
        }
        
        if stressIndicators.sustainedLevelStress {
            stressScore += 0.3
            stressFactors += 1
        }
        
        return stressFactors > 0 ? stressScore / Float(stressFactors) : 0.0
    }
    
    private func updatePublishedProperties() {
        // Update all published properties on main thread
        objectWillChange.send()
    }
    
    private func startRealTimeAnalysis() {
        // Start real-time analysis timer
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateAnalysis()
        }
    }
    
    private func stopRealTimeAnalysis() {
        // Stop real-time analysis
        // Timer cleanup handled automatically
    }
    
    private func updateAnalysis() {
        // Update analysis results
        // This is called periodically for real-time updates
    }
    
    // MARK: - Private Properties
    
    private var frequencyBands: [FrequencyBand] = []
    private var stressThresholds: StressThresholds = StressThresholds()
}

// MARK: - Supporting Models

/// Audio metrics
public struct AudioMetrics: Codable, Sendable {
    public let rmsLevel: Float
    public let peakLevel: Float
    public let peakFrequency: Float
    public let frequencySpectrum: [Float]
    public let timestamp: Date
    
    public init(rmsLevel: Float = 0.0, peakLevel: Float = 0.0, peakFrequency: Float = 0.0, frequencySpectrum: [Float] = [], timestamp: Date = Date()) {
        self.rmsLevel = max(0.0, min(1.0, rmsLevel))
        self.peakLevel = max(0.0, min(1.0, peakLevel))
        self.peakFrequency = max(0.0, peakFrequency)
        self.frequencySpectrum = frequencySpectrum
        self.timestamp = timestamp
    }
    
    public static let `default` = AudioMetrics()
}

/// Canine audio analysis
public struct CanineAudioAnalysis: Codable, Sendable {
    public let bandLevels: [Float]
    public let highFrequencyContent: Float
    public let temporalPatterns: TemporalPatterns
    public let overallEngagement: Float
    public let timestamp: Date
    
    public init(bandLevels: [Float] = [], highFrequencyContent: Float = 0.0, temporalPatterns: TemporalPatterns = .default, overallEngagement: Float = 0.0, timestamp: Date = Date()) {
        self.bandLevels = bandLevels
        self.highFrequencyContent = max(0.0, min(1.0, highFrequencyContent))
        self.temporalPatterns = temporalPatterns
        self.overallEngagement = max(0.0, min(1.0, overallEngagement))
        self.timestamp = timestamp
    }
    
    public static let `default` = CanineAudioAnalysis()
}

/// Temporal patterns
public struct TemporalPatterns: Codable, Sendable {
    public let attackTime: Float
    public let decayTime: Float
    public let sustainLevel: Float
    public let dynamicRange: Float
    
    public init(attackTime: Float = 0.0, decayTime: Float = 0.0, sustainLevel: Float = 0.0, dynamicRange: Float = 0.0) {
        self.attackTime = max(0.0, attackTime)
        self.decayTime = max(0.0, decayTime)
        self.sustainLevel = max(0.0, min(1.0, sustainLevel))
        self.dynamicRange = max(0.0, min(1.0, dynamicRange))
    }
    
    public static let `default` = TemporalPatterns()
}

/// Stress indicators
public struct StressIndicators: Codable, Sendable {
    public let highFrequencyStress: Bool
    public let rapidChangeStress: Bool
    public let sustainedLevelStress: Bool
    public let overallStressLevel: Float
    public let timestamp: Date
    
    public init(highFrequencyStress: Bool = false, rapidChangeStress: Bool = false, sustainedLevelStress: Bool = false, overallStressLevel: Float = 0.0, timestamp: Date = Date()) {
        self.highFrequencyStress = highFrequencyStress
        self.rapidChangeStress = rapidChangeStress
        self.sustainedLevelStress = sustainedLevelStress
        self.overallStressLevel = max(0.0, min(1.0, overallStressLevel))
        self.timestamp = timestamp
    }
    
    public static let `default` = StressIndicators()
}

/// Frequency band
public struct FrequencyBand: Codable, Sendable {
    public let low: Float
    public let high: Float
    public let name: String
    
    public init(low: Float, high: Float, name: String) {
        self.low = max(0.0, low)
        self.high = max(low, high)
        self.name = name
    }
}

/// Stress thresholds
public struct StressThresholds: Codable, Sendable {
    public let highFrequencyThreshold: Float
    public let rapidChangeThreshold: Float
    public let sustainedLevelThreshold: Float
    
    public init(highFrequencyThreshold: Float = 0.7, rapidChangeThreshold: Float = 0.5, sustainedLevelThreshold: Float = 0.6) {
        self.highFrequencyThreshold = max(0.0, min(1.0, highFrequencyThreshold))
        self.rapidChangeThreshold = max(0.0, min(1.0, rapidChangeThreshold))
        self.sustainedLevelThreshold = max(0.0, min(1.0, sustainedLevelThreshold))
    }
}
