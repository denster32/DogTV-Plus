import Foundation

import AVFoundation

/// Manages synchronization between audio and visual components.
@available(iOS 17.0, tvOS 17.0, macOS 10.15, *)
public class AudioVisualSync {

    private var audioStartTime: TimeInterval = 0
    private var visualStartTime: TimeInterval = 0
    private var isSynchronized: Bool = false

    /// Starts the synchronization clock for both audio and visuals.
    public func start() {
        let currentTime = CACurrentMediaTime()
        audioStartTime = currentTime
        visualStartTime = currentTime
        isSynchronized = true
    }

    /// Stops and resets the synchronization.
    public func stop() {
        isSynchronized = false
        audioStartTime = 0
        visualStartTime = 0
    }

    /// Resynchronizes the audio and visual timers to the current time.
    public func resynchronize() {
        guard isSynchronized else { return }
        start()
    }

    /// Gets the elapsed time for the audio component.
    public func getCurrentAudioTime() -> TimeInterval {
        guard isSynchronized else { return 0 }
        return CACurrentMediaTime() - audioStartTime
    }

    /// Gets the elapsed time for the visual component.
    public func getCurrentVisualTime() -> TimeInterval {
        guard isSynchronized else { return 0 }
        return CACurrentMediaTime() - visualStartTime
    }

    /// Checks if audio and visuals are currently synchronized within a given tolerance.
    /// - Parameter tolerance: The maximum allowed time difference in seconds.
    /// - Returns: `true` if the components are synchronized, `false` otherwise.
    public func checkSynchronization(tolerance: TimeInterval = 0.1) -> Bool {
        guard isSynchronized else { return false }
        let timeDifference = abs(getCurrentAudioTime() - getCurrentVisualTime())
        return timeDifference < tolerance
    }
}
