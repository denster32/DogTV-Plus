import Foundation

/// PerformanceAlertManager: Manages the triggering, registration, and retrieval of performance alerts.
/// This module defines various alert types, severities, and handles the logic for triggering
/// and clearing alerts based on performance data. It also allows external modules to register
/// callbacks for specific alert types.
class PerformanceAlertManager {

    // MARK: - Alert Properties
    private var alertHistory: [PerformanceAlert] = []
    private var alertCallbacks: [PerformanceAlertType: [() -> Void]] = [:]
    private var alertThresholds: [PerformanceAlertType: Float] = [:]

    // MARK: - Data Structures
    struct PerformanceAlert {
        let timestamp: Date
        let type: PerformanceAlertType
        let severity: AlertSeverity
        let message: String
        let data: PerformanceData
        let actionTaken: String?
    }

    struct PerformanceData {
        let thermalLevel: Float
        let gpuUtilization: Float
        let cpuUtilization: Float
        let memoryUsage: Float
        let frameRate: Float
        let temperature: Float
    }

    enum PerformanceAlertType: String, CaseIterable {
        case highTemperature = "High Temperature"
        case thermalThrottling = "Thermal Throttling"
        case lowFrameRate = "Low Frame Rate"
        case highMemoryUsage = "High Memory Usage"
        case performanceDegradation = "Performance Degradation"
        case thermalRecovery = "Thermal Recovery"
    }

    enum AlertSeverity: String, CaseIterable {
        case info = "Info"
        case warning = "Warning"
        case critical = "Critical"
        case emergency = "Emergency"
    }

    enum AlertAction {
        case add
        case remove
    }

    // MARK: - Initialization
    init() {
        setupAlertSystem()
        print("PerformanceAlertManager initialized.")
    }

    // MARK: - Setup
    private func setupAlertSystem() {
        alertThresholds[.highTemperature] = 0.8 // Thermal level
        alertThresholds[.thermalThrottling] = 0.9 // Thermal level
        alertThresholds[.lowFrameRate] = 25.0 // FPS
        alertThresholds[.highMemoryUsage] = 0.9 // Normalized memory usage
        alertThresholds[.performanceDegradation] = 0.1 // Drop in performance score
        print("Performance alert system thresholds set.")
    }

    // MARK: - Public Alert Management Methods

    /// Triggers a performance alert based on the provided data and type.
    /// If `action` is `.remove`, it clears existing alerts of that type.
    func triggerAlert(type: PerformanceAlertType, severity: AlertSeverity, message: String, data: PerformanceData, action: AlertAction = .add) {
        let newAlert = PerformanceAlert(
            timestamp: Date(),
            type: type,
            severity: severity,
            message: message,
            data: data,
            actionTaken: nil // This could be dynamically set based on actions taken by the optimizer
        )

        switch action {
        case .add:
            if !alertHistory.contains(where: { $0.type == type && $0.severity == severity }) {
                alertHistory.append(newAlert)
                print("Performance Alert [\(severity.rawValue)]: \(message) (Type: \(type.rawValue))")
                // Execute registered callbacks
                alertCallbacks[type]?.forEach { $0() }
            }
        case .remove:
            alertHistory.removeAll { $0.type == type }
            print("Performance Alert Cleared: \(message) (Type: \(type.rawValue))")
        }
    }

    /// Registers a callback to be executed when a specific alert type is triggered.
    func registerAlertCallback(for type: PerformanceAlertType, callback: @escaping () -> Void) {
        alertCallbacks[type, default: []].append(callback)
    }

    /// Retrieves the current list of active performance alerts.
    func getActiveAlerts() -> [PerformanceAlert] {
        return alertHistory
    }

    /// Checks if a specific alert type and severity is currently active.
    func isAlertActive(type: PerformanceAlertType, severity: AlertSeverity) -> Bool {
        return alertHistory.contains(where: { $0.type == type && $0.severity == severity })
    }

    /// Retrieves the threshold for a given alert type.
    func getThreshold(for type: PerformanceAlertType) -> Float? {
        return alertThresholds[type]
    }
    
    /// Clears all alerts of a specific type. Used for recovery scenarios.
    func clearAlerts(for type: PerformanceAlertType) {
        alertHistory.removeAll { $0.type == type }
        print("All alerts of type \(type.rawValue) cleared.")
    }
} 