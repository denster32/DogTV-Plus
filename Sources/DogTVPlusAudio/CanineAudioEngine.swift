@preconcurrency import AVFoundation
import Combine
import DogTVCore
import Foundation

/// Audio engine for processing and optimizing audio for dogs
@available(iOS 17.0, tvOS 17.0, macOS 10.15, *)
public class CanineAudioEngine: ObservableObject {
    // MARK: - Audio Engine Components

    private var audioEngine = AVAudioEngine()
    private var playerNodes: [AVAudioPlayerNode] = []
    private var mixerNode = AVAudioMixerNode()
    private let audioFileLoader = AudioFileLoader()
    private var equalizerNode = AVAudioUnitEQ(numberOfBands: 5)
    private var frequencyFilterNode = AVAudioUnitEQ(numberOfBands: 2)
    private var reverbNode = AVAudioUnitReverb()
    // Compressor not available on macOS, using gain instead
    private var gainNode = AVAudioUnitEQ(numberOfBands: 1)
    internal var monitor: AudioMonitor?

    // MARK: - Audio Settings

    @Published public var volume: Float = 0.7
    @Published public var frequencyRange: FrequencyRange = .high
    @Published public var includeNatureSounds: Bool = true
    @Published public var isPlaying: Bool = false

    public init() {
        setupAudioEngine()
        setupAudioSession()
        monitor = AudioMonitor(tapNode: audioEngine.outputNode)
    }

    deinit {
        audioEngine.stop()
    }

    // MARK: - Audio Engine Setup

    private func setupAudioEngine() {
        // Attach mixer node
        mixerNode = audioEngine.mainMixerNode

        // Attach processing nodes
        audioEngine.attach(equalizerNode)
        audioEngine.attach(frequencyFilterNode)
        audioEngine.attach(reverbNode)
        audioEngine.attach(gainNode)

        // Set up the processing chain: mixer -> equalizer -> frequencyFilter -> reverb -> compressor -> output
        let format = audioEngine.outputNode.outputFormat(forBus: 0)
        audioEngine.connect(mixerNode, to: equalizerNode, format: format)
        audioEngine.connect(equalizerNode, to: frequencyFilterNode, format: format)
        audioEngine.connect(frequencyFilterNode, to: reverbNode, format: format)
        audioEngine.connect(reverbNode, to: gainNode, format: format)
        audioEngine.connect(gainNode, to: audioEngine.outputNode, format: format)

        // Set default parameters for effects
        setupDefaultEqualizer()
        applyCanineFrequencyFiltering(frequencyRange) // Apply default range
        setupDefaultReverb()
        setupDefaultCompressor()

        // Prepare and start engine
        audioEngine.prepare()

        do {
            try audioEngine.start()
        } catch {
            print("Failed to start audio engine: \(error)")
        }
    }

    private func setupAudioSession() {
        #if !os(macOS)
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .default)
            try audioSession.setActive(true)

            // Observe interruptions
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(handleInterruption),
                                                   name: AVAudioSession.interruptionNotification,
                                                   object: audioSession)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
        #endif
    }

    @objc private func handleInterruption(notification: Notification) {
        #if !os(macOS)
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }

        if type == .began {
            // Interruption began, pause audio
            stopAudio()
        } else if type == .ended {
            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    // Interruption ended, resume audio
                    try? playAudio()
                }
            }
        }
        #endif
    }

    // MARK: - Audio Control

    /// Load audio files for a specific scene.
    public func loadAudio(for scene: SceneType) throws {
        // Stop and detach any existing player nodes
        for playerNode in playerNodes {
            playerNode.stop()
            audioEngine.detach(playerNode)
        }
        playerNodes.removeAll()

        let audioFiles = try audioFileLoader.loadAudioFiles(for: scene)

        for audioFile in audioFiles {
            guard let buffer = loadFileIntoBuffer(audioFile: audioFile) else {
                throw AudioError.bufferCreationFailed
            }

            let playerNode = AVAudioPlayerNode()
            playerNodes.append(playerNode)
            audioEngine.attach(playerNode)
            audioEngine.connect(playerNode, to: mixerNode, format: audioFile.processingFormat)

            // Schedule the buffer to loop
            playerNode.scheduleBuffer(buffer, at: nil, options: .loops, completionHandler: nil)
        }
    }

    private func loadFileIntoBuffer(audioFile: AVAudioFile) -> AVAudioPCMBuffer? {
        // Read the entire audio file into a buffer for looping.
        // This is suitable for reasonably sized audio files. For very large files, streaming would be better.
        guard let buffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat,
                                            frameCapacity: AVAudioFrameCount(audioFile.length)) else {
            return nil
        }
        do {
            try audioFile.read(into: buffer)
            return buffer
        } catch {
            print("Failed to read audio file into buffer: \(error)")
            return nil
        }
    }

    /// Start audio playback
    public func playAudio() throws {
        guard !playerNodes.isEmpty else {
            throw AudioError.fileNotFound
        }

        if !audioEngine.isRunning {
            do {
                try audioEngine.start()
            } catch {
                print("Could not start audio engine: \(error)")
                return
            }
        }

        for playerNode in playerNodes {
            playerNode.play()
        }
        isPlaying = true
    }

    /// Stop audio playback
    public func stopAudio() {
        for playerNode in playerNodes {
            playerNode.stop()
        }
        isPlaying = false
    }

    /// Pause audio playback
    public func pauseAudio() {
        for playerNode in playerNodes {
            playerNode.pause()
        }
        isPlaying = false
    }

    /// Resume audio playback
    public func resumeAudio() {
        for playerNode in playerNodes {
            playerNode.play()
        }
        isPlaying = true
    }

    /// Set volume
    public func setVolume(_ newVolume: Float) {
        let clampedVolume = max(0.0, min(1.0, newVolume))
        volume = clampedVolume
        mixerNode.outputVolume = volume
    }

    /// Fade between audio tracks smoothly.
    /// - Parameters:
    ///   - fromNode: The audio node to fade out.
    ///   - toNode: The audio node to fade in.
    ///   - duration: The duration of the fade.
    public func crossfade(from fromNode: AVAudioPlayerNode, to toNode: AVAudioPlayerNode, duration: TimeInterval) {
        // Simple linear crossfade.
        let steps = 20
        let stepDuration = duration / Double(steps)

        for i in 0...steps {
            let time = DispatchTime.now() + stepDuration * Double(i)
            DispatchQueue.main.asyncAfter(deadline: time) {
                let fromVolume = 1.0 - (Float(i) / Float(steps))
                let toVolume = Float(i) / Float(steps)
                fromNode.volume = fromVolume
                toNode.volume = toVolume
            }
        }
    }

    /// Set reverb mix
    public func setReverb(wetDryMix: Float) {
        reverbNode.wetDryMix = wetDryMix
    }

    /// Apply frequency filtering based on canine hearing range
    public func applyCanineFrequencyFiltering(_ range: FrequencyRange) {
        frequencyRange = range
        let frequencyBounds = range.hertzRange

        // High-pass filter
        frequencyFilterNode.bands[0].filterType = .highPass
        frequencyFilterNode.bands[0].frequency = Float(frequencyBounds.lowerBound)
        frequencyFilterNode.bands[0].gain = 0
        frequencyFilterNode.bands[0].bypass = false

        // Low-pass filter
        frequencyFilterNode.bands[1].filterType = .lowPass
        frequencyFilterNode.bands[1].frequency = Float(frequencyBounds.upperBound)
        frequencyFilterNode.bands[1].gain = 0
        frequencyFilterNode.bands[1].bypass = false
    }

    private func setupDefaultReverb() {
        reverbNode.loadFactoryPreset(.mediumHall)
        reverbNode.wetDryMix = 30.0
    }

    private func setupDefaultCompressor() {
        // Using gain node instead of compressor for macOS compatibility
        gainNode.bands[0].frequency = 1000.0
        gainNode.bands[0].gain = 0.0
        gainNode.bands[0].bandwidth = 1.0
        gainNode.bands[0].filterType = .parametric
        gainNode.bands[0].bypass = false
    }

    private func setupDefaultEqualizer() {
        // As per AGENT_4_AUDIO_SYSTEMS.md
        // Low frequency band (bass)
        equalizerNode.bands[0].filterType = .lowShelf
        equalizerNode.bands[0].frequency = 250.0
        equalizerNode.bands[0].gain = 2.0

        // Low-mid frequency band
        equalizerNode.bands[1].filterType = .parametric
        equalizerNode.bands[1].frequency = 500.0
        equalizerNode.bands[1].gain = 0.0
        equalizerNode.bands[1].bandwidth = 1.0

        // Mid frequency band
        equalizerNode.bands[2].filterType = .parametric
        equalizerNode.bands[2].frequency = 1000.0
        equalizerNode.bands[2].gain = 0.0
        equalizerNode.bands[2].bandwidth = 1.0

        // High-mid frequency band
        equalizerNode.bands[3].filterType = .parametric
        equalizerNode.bands[3].frequency = 4000.0
        equalizerNode.bands[3].gain = 0.0
        equalizerNode.bands[3].bandwidth = 1.0

        // High frequency band (treble)
        equalizerNode.bands[4].filterType = .highShelf
        equalizerNode.bands[4].frequency = 8000.0
        equalizerNode.bands[4].gain = -1.0
    }

    public func setEqualizer(band: Int, gain: Float) {
        guard band >= 0 && band < equalizerNode.bands.count else { return }
        equalizerNode.bands[band].gain = gain
    }
}

enum AudioError: Error, LocalizedError {
    case fileNotFound
    case bufferCreationFailed

    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "Audio file not found."
        case .bufferCreationFailed:
            return "Failed to create audio buffer for playback."
        }
    }
}
