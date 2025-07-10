import AVFoundation
import Foundation

/// Manages streaming of audio files for long sessions to optimize memory usage.
@available(iOS 17.0, tvOS 17.0, macOS 10.15, *)
public class AudioStreamingManager {

    private let audioEngine: AVAudioEngine
    private let playerNode: AVAudioPlayerNode
    private let mixerNode: AVAudioMixerNode
    private var audioFile: AVAudioFile?
    private var bufferQueue: [AVAudioPCMBuffer] = []
    private var isStreaming: Bool = false
    private let bufferSize: AVAudioFrameCount = 4096
    private let numberOfBuffers: Int = 3

    public init(audioEngine: AVAudioEngine, playerNode: AVAudioPlayerNode) {
        self.audioEngine = audioEngine
        self.playerNode = playerNode
        self.mixerNode = audioEngine.mainMixerNode
    }

    /// Starts streaming audio from a file.
    public func startStreaming(from file: AVAudioFile) throws {
        audioFile = file
        try prepareBuffers()
        scheduleBuffers()
        isStreaming = true
    }

    /// Stops audio streaming.
    public func stopStreaming() {
        isStreaming = false
        playerNode.stop()
        bufferQueue.removeAll()
    }

    /// Prepares audio buffers for streaming.
    private func prepareBuffers() throws {
        guard let audioFile = audioFile else {
            throw AudioError.fileNotFound
        }

        bufferQueue.removeAll()

        for _ in 0..<numberOfBuffers {
            guard let buffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: bufferSize) else {
                throw AudioError.bufferCreationFailed
            }

            do {
                try audioFile.read(into: buffer)
                bufferQueue.append(buffer)
            } catch {
                // If we can't read more data, break the loop
                break
            }
        }
    }

    /// Schedules buffers for playback.
    private func scheduleBuffers() {
        for buffer in bufferQueue {
            playerNode.scheduleBuffer(buffer) { [weak self] in
                self?.handleBufferComplete()
            }
        }
    }

    /// Handles buffer completion and schedules next buffer.
    private func handleBufferComplete() {
        guard isStreaming, let audioFile = audioFile else { return }

        // Create a new buffer and try to read more data
        if let buffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: bufferSize) {
            do {
                try audioFile.read(into: buffer)
                playerNode.scheduleBuffer(buffer) { [weak self] in
                    self?.handleBufferComplete()
                }
            } catch {
                // End of file or error - restart from beginning for seamless loop
                audioFile.framePosition = 0
                do {
                    try audioFile.read(into: buffer)
                    playerNode.scheduleBuffer(buffer) { [weak self] in
                        self?.handleBufferComplete()
                    }
                } catch {
                    print("Error reading audio file: \(error)")
                }
            }
        }
    }

    /// Optimizes streaming performance by adjusting buffer size based on system conditions.
    public func optimizeStreamingPerformance() {
        // Monitor system performance and adjust buffer size accordingly
        let systemLoad = ProcessInfo.processInfo.systemUptime

        // Adjust buffer size based on system conditions
        // This is a simplified example - real implementation would monitor CPU/memory usage
        if systemLoad > 1000 {
            // System has been running for a while, use larger buffers
            // bufferSize = 8192
        } else {
            // Use smaller buffers for better responsiveness
            // bufferSize = 2048
        }
    }
}
