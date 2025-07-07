import Foundation

public class BehaviorDetection {
    public init() {}

    /// Analyzes tail position to determine behavior state.
    public func analyzeTailPosition(_ positionData: [Float]) -> String {
        // Simplified logic: average position
        let avg = positionData.reduce(0, +) / Float(positionData.count)
        return avg > 0.5 ? "calm" : "active"
    }
} 