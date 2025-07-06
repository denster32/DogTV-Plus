import Foundation

/// PerformanceScaler: Manages dynamic performance scaling and mode adjustments.
/// This module is responsible for setting performance modes, adjusting rendering parameters
/// via the VisualRenderer, and controlling target frame rates based on system conditions.
class PerformanceScaler {

    // MARK: - Performance Scaling Properties
    private var performanceMode: PerformanceMode = .balanced
    private var scalingFactor: Float = 1.0
    private var targetFrameRate: Float = 60.0
    
    // Dependency on VisualRenderer for applying visual adjustments
    private var visualRenderer: VisualRenderer

    // MARK: - Data Structures
    enum PerformanceMode: String, CaseIterable {
        case powerSaving = "Power Saving"
        case balanced = "Balanced"
        case performance = "Performance"
        case thermalThrottled = "Thermal Throttled"
        case emergency = "Emergency"
    }

    // MARK: - Initialization
    init(visualRenderer: VisualRenderer) {
        self.visualRenderer = visualRenderer
        setupPerformanceScaling()
        print("PerformanceScaler initialized with dynamic performance scaling.")
    }

    // MARK: - Setup
    private func setupPerformanceScaling() {
        // Initialize scaling parameters
        performanceMode = .balanced
        scalingFactor = 1.0
        print("Performance scaling initialized.")
    }

    // MARK: - Public Interface Methods

    /// Sets the overall performance mode of the application.
    /// Adjusts rendering quality and frame rate based on the selected mode.
    func setPerformanceMode(_ mode: PerformanceMode) {
        guard performanceMode != mode else { return }
        performanceMode = mode
        print("Performance mode set to: \(performanceMode.rawValue)")
        applyPerformanceMode()
    }

    /// Returns the current performance mode.
    func getPerformanceMode() -> PerformanceMode {
        return performanceMode
    }

    /// Returns the current target frame rate for the given performance mode.
    func getTargetFrameRate() -> Float {
        return targetFrameRate
    }

    /// Returns the current scaling factor applied to rendering.
    func getScalingFactor() -> Float {
        return scalingFactor
    }

    // MARK: - Internal Adjustment Methods

    /// Applies the current performance mode settings to the VisualRenderer.
    private func applyPerformanceMode() {
        switch performanceMode {
        case .powerSaving:
            visualRenderer.setScalingFactor(0.7)
            visualRenderer.setQualityLevel(.low)
            visualRenderer.setShaderComplexity(.low)
            targetFrameRate = 30.0
        case .balanced:
            visualRenderer.setScalingFactor(0.9)
            visualRenderer.setQualityLevel(.medium)
            visualRenderer.setShaderComplexity(.medium)
            targetFrameRate = 45.0
        case .performance:
            visualRenderer.setScalingFactor(1.0)
            visualRenderer.setQualityLevel(.high)
            visualRenderer.setShaderComplexity(.high)
            targetFrameRate = 60.0
        case .thermalThrottled:
            visualRenderer.setScalingFactor(0.5)
            visualRenderer.setQualityLevel(.lowest)
            visualRenderer.setShaderComplexity(.lowest)
            targetFrameRate = 15.0
        case .emergency:
            visualRenderer.setScalingFactor(0.3)
            visualRenderer.setQualityLevel(.lowest)
            visualRenderer.setShaderComplexity(.lowest)
            targetFrameRate = 10.0
        }
        print("Applied performance settings for \(performanceMode.rawValue) mode.")
    }
} 