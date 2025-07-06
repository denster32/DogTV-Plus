import Foundation

/// PerformanceOptimizer manages the performance of the DogTV+ app to sustain high-intensity rendering.
/// It monitors thermal state changes on Apple TV hardware and dynamically adjusts rendering parameters
/// to prevent overheating while maintaining optimal visual and audio quality for canine relaxation.
class PerformanceOptimizer {
    private var thermalState: ProcessInfo.ThermalState = .nominal
    private var performanceLevel: PerformanceLevel = .high
    private var performanceDelegate: PerformanceAdjustmentDelegate?
    private var thermalObservation: NSObjectProtocol?
    
    /// Initializes the performance optimizer, setting up thermal state observation.
    init() {
        observeThermalState()
    }
    
    /// Sets a delegate to receive performance adjustment notifications.
    /// This allows the app to adapt rendering based on thermal constraints.
    func setPerformanceDelegate(_ delegate: PerformanceAdjustmentDelegate) {
        self.performanceDelegate = delegate
    }
    
    /// Observes thermal state changes using NotificationCenter.
    /// Updates performance parameters whenever the thermal state changes.
    private func observeThermalState() {
        // Monitor thermal state changes
        thermalObservation = NotificationCenter.default.addObserver(forName: ProcessInfo.thermalStateDidChangeNotification, object: nil, queue: .main) { [weak self] _ in
            self?.updateThermalState()
        }
        updateThermalState()
    }
    
    /// Updates the current thermal state from ProcessInfo.
    /// Adjusts performance parameters based on the new thermal state.
    private func updateThermalState() {
        thermalState = ProcessInfo.processInfo.thermalState
        adjustPerformanceBasedOnThermalState()
    }
    
    /// Adjusts performance parameters based on the current thermal state.
    /// Reduces rendering intensity under critical thermal conditions to prevent overheating.
    private func adjustPerformanceBasedOnThermalState() {
        switch thermalState {
        case .nominal:
            performanceLevel = .high
            performanceDelegate?.adjustPerformance(to: .high, frameRate: 120, shaderComplexity: 1.0, audioProcessing: 1.0)
            print("Thermal state nominal: Setting performance to high (120fps, full shaders)")
        case .fair:
            performanceLevel = .medium
            performanceDelegate?.adjustPerformance(to: .medium, frameRate: 90, shaderComplexity: 0.8, audioProcessing: 0.9)
            print("Thermal state fair: Reducing performance to medium (90fps, 80% shaders)")
        case .serious:
            performanceLevel = .low
            performanceDelegate?.adjustPerformance(to: .low, frameRate: 60, shaderComplexity: 0.6, audioProcessing: 0.7)
            print("Thermal state serious: Reducing performance to low (60fps, 60% shaders)")
        case .critical:
            performanceLevel = .minimal
            performanceDelegate?.adjustPerformance(to: .minimal, frameRate: 30, shaderComplexity: 0.3, audioProcessing: 0.5)
            print("Thermal state critical: Setting performance to minimal (30fps, 30% shaders)")
        @unknown default:
            performanceLevel = .medium
            performanceDelegate?.adjustPerformance(to: .medium, frameRate: 90, shaderComplexity: 0.8, audioProcessing: 0.9)
            print("Unknown thermal state: Defaulting to medium performance")
        }
    }
    
    /// Manually triggers a performance boost for high-intensity content.
    /// Only boosts if thermal state allows to prevent overheating.
    func requestPerformanceBoost() {
        if thermalState == .nominal {
            performanceLevel = .high
            performanceDelegate?.adjustPerformance(to: .high, frameRate: 120, shaderComplexity: 1.0, audioProcessing: 1.0)
            print("Performance boost requested and applied (thermal state nominal)")
        } else {
            print("Performance boost denied due to thermal constraints: \(thermalState)")
        }
    }
    
    /// Returns the current performance level for monitoring purposes.
    func currentPerformanceLevel() -> PerformanceLevel {
        return performanceLevel
    }
    
    /// Cleans up resources by removing thermal state observation.
    deinit {
        if let observer = thermalObservation {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}

/// Enum representing different levels of performance for rendering and processing.
enum PerformanceLevel: String {
    case high
    case medium
    case low
    case minimal
}

/// Protocol for delegates to receive performance adjustment notifications.
/// Implementers (like VisualRenderer or CanineAudioEngine) adjust their parameters accordingly.
protocol PerformanceAdjustmentDelegate: AnyObject {
    func adjustPerformance(to level: PerformanceLevel, frameRate: Int, shaderComplexity: Float, audioProcessing: Float)
}

struct RenderingParameters {
    let frameRate: Int
    let quality: QualityLevel
    let particleCount: Int
}

enum QualityLevel {
    case high, medium, low
}

extension Notification.Name {
    static let performanceLevelDidChange = Notification.Name("performanceLevelDidChange")
} 