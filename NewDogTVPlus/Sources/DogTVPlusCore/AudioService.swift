import Foundation
import Combine
@preconcurrency import AVFoundation

/// Audio service for managing audio playback and settings
@available(iOS 17.0, tvOS 17.0, macOS 10.15, *)
@MainActor
public class AudioService: ObservableObject {
    @Published public var isPlaying: Bool = false
    @Published public var volume: Float = 0.7
    @Published public var currentAudioSettings: AudioSettings = .default
    @Published public var error: AudioError?
    
    private var audioEngine = AVAudioEngine()
    private var playerNode = AVAudioPlayerNode()
    private var cancellables = Set<AnyCancellable>()
    
    public init() {
        setupAudioEngine()
        setupAudioSession()
    }
    
    deinit {
        // Audio engine will be cleaned up automatically
    }
    
    // MARK: - Public Methods
    
    /// Start audio playback
    public func playAudio() async throws {
        do {
            error = nil
            
            guard !isPlaying else { return }
            
            // Start audio engine if not running
            if !audioEngine.isRunning {
                try audioEngine.start()
            }
            
            // Start player node
            if !playerNode.isPlaying {
                playerNode.play()
            }
            
            isPlaying = true
            
        } catch {
            self.error = .playbackFailed
            throw AudioError.playbackFailed
        }
    }
    
    /// Stop audio playback
    public func stopAudio() async throws {
        error = nil
        
        if playerNode.isPlaying {
            playerNode.stop()
        }
        
        isPlaying = false
    }
    
    /// Update audio settings
    public func updateAudioSettings(_ settings: AudioSettings) async throws {
        currentAudioSettings = settings
        volume = settings.volume
        
        // Apply settings to audio engine
        applyAudioSettings()
    }
    
    /// Set volume
    public func setVolume(_ newVolume: Float) {
        volume = max(0.0, min(1.0, newVolume))
        currentAudioSettings.volume = volume
        applyVolumeSettings()
    }
    
    // MARK: - Private Methods
    
    private func setupAudioEngine() {
        // Attach player node to engine
        audioEngine.attach(playerNode)
        
        // Connect player node to main mixer
        audioEngine.connect(playerNode, to: audioEngine.mainMixerNode, format: nil)
        
        // Prepare engine
        audioEngine.prepare()
    }
    
    private func setupAudioSession() {
        #if !os(macOS)
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default)
            try audioSession.setActive(true)
        } catch {
            self.error = .setupFailed
        }
        #endif
    }
    
    private func applyAudioSettings() {
        applyVolumeSettings()
        applyFrequencySettings()
    }
    
    private func applyVolumeSettings() {
        audioEngine.mainMixerNode.outputVolume = volume
    }
    
    private func applyFrequencySettings() {
        // Frequency filtering will be implemented in the audio module
        // This is a placeholder for frequency-specific processing
    }
}

// MARK: - Audio Error
public enum AudioError: Error, LocalizedError {
    case setupFailed
    case playbackFailed
    case stopFailed
    case configurationFailed
    
    public var errorDescription: String? {
        switch self {
        case .setupFailed:
            return "Failed to setup audio system"
        case .playbackFailed:
            return "Audio playback failed"
        case .stopFailed:
            return "Failed to stop audio"
        case .configurationFailed:
            return "Audio configuration failed"
        }
    }
}
