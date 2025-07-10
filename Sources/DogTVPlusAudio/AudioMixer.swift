import Foundation
import AVFoundation

/// Manages mixing of multiple audio player nodes.
@available(iOS 17.0, tvOS 17.0, macOS 10.15, *)
public class AudioMixer {

    private let audioEngine: AVAudioEngine
    private let mixerNode: AVAudioMixerNode
    private var playerNodes: [AVAudioPlayerNode] = []

    public init(audioEngine: AVAudioEngine) {
        self.audioEngine = audioEngine
        self.mixerNode = audioEngine.mainMixerNode
    }

    /// Adds a player node to the mixer.
    public func addPlayerNode(_ playerNode: AVAudioPlayerNode, format: AVAudioFormat?) {
        audioEngine.attach(playerNode)
        audioEngine.connect(playerNode, to: mixerNode, format: format)
        playerNodes.append(playerNode)
    }

    /// Removes a player node from the mixer.
    public func removePlayerNode(_ playerNode: AVAudioPlayerNode) {
        playerNode.stop()
        audioEngine.detach(playerNode)
        if let index = playerNodes.firstIndex(of: playerNode) {
            playerNodes.remove(at: index)
        }
    }

    /// Sets the volume for a specific player node.
    public func setVolume(for playerNode: AVAudioPlayerNode, volume: Float) {
        playerNode.volume = volume
    }

    /// Sets the main volume for the mixer.
    public func setMainVolume(_ volume: Float) {
        mixerNode.outputVolume = volume
    }

    /// Fades in a player node over a specified duration.
    public func fadeIn(node: AVAudioPlayerNode, duration: TimeInterval) {
        node.volume = 0
        node.play()

        let steps = 20
        let stepDuration = duration / Double(steps)

        for i in 1...steps {
            let time = DispatchTime.now() + stepDuration * Double(i)
            DispatchQueue.main.asyncAfter(deadline: time) {
                node.volume = Float(i) / Float(steps)
            }
        }
    }

    /// Fades out a player node over a specified duration.
    public func fadeOut(node: AVAudioPlayerNode, duration: TimeInterval) {
        let initialVolume = node.volume
        let steps = 20
        let stepDuration = duration / Double(steps)

        for i in 1...steps {
            let time = DispatchTime.now() + stepDuration * Double(i)
            DispatchQueue.main.asyncAfter(deadline: time) {
                node.volume = initialVolume * (1.0 - (Float(i) / Float(steps)))
            }
        }

        let stopTime = DispatchTime.now() + duration
        DispatchQueue.main.asyncAfter(deadline: stopTime) {
            node.stop()
        }
    }
}
