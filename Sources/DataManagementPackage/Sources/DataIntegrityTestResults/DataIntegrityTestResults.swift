import Foundation

public class DataIntegrityTestResults {
    public init() {}
    public func addConsistencyScore(_ score: Double) {}
    public func addIntegrityScore(_ score: Double) {}
    public func addCompletenessScore(_ score: Double) {}
    public func addAccuracyScore(_ score: Double) {}
    public func addPerformanceScore(_ score: Double) {}
    public func getAverageConsistencyScore() -> Double { return 0.0 }
    public func getAverageIntegrityScore() -> Double { return 0.0 }
    public func getAverageCompletenessScore() -> Double { return 0.0 }
    public func getAverageAccuracyScore() -> Double { return 0.0 }
    public func getAveragePerformanceScore() -> Double { return 0.0 }
} 