import Foundation

public class AnalyticsAccuracyTestResults {
    public init() {}
    public func addCollectionAccuracy(_ accuracy: Double) {}
    public func addProcessingAccuracy(_ accuracy: Double) {}
    public func addReportingAccuracy(_ accuracy: Double) {}
    public func addRealTimeAccuracy(_ accuracy: Double) {}
    public func addPrivacyCompliance(_ compliance: Double) {}
    public func getAverageCollectionAccuracy() -> Double { return 0.0 }
    public func getAverageProcessingAccuracy() -> Double { return 0.0 }
    public func getAverageReportingAccuracy() -> Double { return 0.0 }
    public func getAverageRealTimeAccuracy() -> Double { return 0.0 }
    public func getAveragePrivacyCompliance() -> Double { return 0.0 }
} 