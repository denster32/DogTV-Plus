import XCTest  // For Swift testing

func testHardwareLimitAlerts() {
    // Simulate hardware limit scenarios
    let highThermalScenario = PerformanceData(thermalLevel: 0.9, gpuUtilization: 0.85)  // High levels
    XCTAssertTrue(checkForLimits(data: highThermalScenario), "Should trigger alert for high thermal and GPU levels")
    
    let normalScenario = PerformanceData(thermalLevel: 0.3, gpuUtilization: 0.4)  // Normal levels
    XCTAssertFalse(checkForLimits(data: normalScenario), "Should not trigger alert for normal levels")
}

func testMonitoringFunction() {
    let sampleData = PerformanceData(thermalLevel: 0.5, gpuUtilization: 0.6)
    startMonitoring()  // Assuming this starts monitoring
    let alertTriggered = simulateMonitoring(data: sampleData)
    XCTAssertEqual(alertTriggered, true, "Monitoring should detect and alert on thresholds")
} 