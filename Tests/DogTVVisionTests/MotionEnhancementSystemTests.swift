import XCTest
@testable import DogTVVision

final class MotionEnhancementSystemTests: XCTestCase {
    var motionEnhancementSystem: MotionEnhancementSystem!

    override func setUp() {
        super.setUp()
        motionEnhancementSystem = MotionEnhancementSystem()
    }

    override func tearDown() {
        motionEnhancementSystem = nil
        super.tearDown()
    }

    // MARK: - Breed Motion Profile Tests

    func testBreedMotionProfileIntensityFactors() {
        let testCases: [(MotionEnhancementSystem.BreedMotionProfile, Float)] = [
            (.borderCollie, 1.5),
            (.jackRussell, 1.5),
            (.australianShepherd, 1.5),
            (.germanShepherd, 1.2),
            (.labrador, 1.0),
            (.bulldog, 0.5)
        ]

        for (breed, expectedFactor) in testCases {
            XCTAssertEqual(
                breed.motionIntensityFactor,
                expectedFactor,
                "Motion intensity factor for \(breed) should match expected value"
            )
        }
    }

    func testBreedMotionProfileMaxFrameRates() {
        let testCases: [(MotionEnhancementSystem.BreedMotionProfile, Int)] = [
            (.borderCollie, 120),
            (.jackRussell, 120),
            (.australianShepherd, 120),
            (.germanShepherd, 90),
            (.labrador, 60),
            (.bulldog, 30)
        ]

        for (breed, expectedFrameRate) in testCases {
            XCTAssertEqual(
                breed.maxFrameRate,
                expectedFrameRate,
                "Max frame rate for \(breed) should match expected value"
            )
        }
    }

    // MARK: - Motion Enhancement Configuration Tests

    func testMotionEnhancementConfigInitialization() {
        let config = MotionEnhancementSystem.MotionEnhancementConfig(
            breed: .borderCollie,
            contentType: .highEnergy,
            renderingQuality: .ultra
        )

        XCTAssertEqual(config.breed, .borderCollie)
        XCTAssertEqual(config.contentType, .highEnergy)
        XCTAssertEqual(config.renderingQuality, .ultra)
    }

    // MARK: - Motion Rendering Tests

    func testMotionRenderingForHighEnergyBreed() {
        let config = MotionEnhancementSystem.MotionEnhancementConfig(
            breed: .borderCollie,
            contentType: .highEnergy
        )

        let renderingParams = motionEnhancementSystem.enhanceMotionRendering(config: config)

        XCTAssertEqual(renderingParams.frameRate, 120, "High-energy breed should have maximum frame rate")
        XCTAssertTrue(renderingParams.motionBlurReduction > 0.9, "Motion blur reduction should be high")
        XCTAssertTrue(renderingParams.motionSmoothing < 0.9, "Motion smoothing should be reduced for high-energy content")
    }

    func testMotionRenderingForRelaxationContent() {
        let config = MotionEnhancementSystem.MotionEnhancementConfig(
            breed: .labrador,
            contentType: .relaxation
        )

        let renderingParams = motionEnhancementSystem.enhanceMotionRendering(config: config)

        XCTAssertEqual(renderingParams.frameRate, 30, "Relaxation content should have reduced frame rate")
        XCTAssertTrue(renderingParams.motionBlurReduction < 0.9, "Motion blur reduction should be lower")
        XCTAssertTrue(renderingParams.motionSmoothing > 0.9, "Motion smoothing should be increased for relaxation")
    }

    // MARK: - Performance Optimization Tests

    func testPerformanceOptimizationForHighEnergyContent() {
        let config = MotionEnhancementSystem.MotionEnhancementConfig(
            breed: .borderCollie,
            contentType: .highEnergy
        )

        let performanceMetrics = motionEnhancementSystem.optimizePerformance(config: config)

        XCTAssertTrue(performanceMetrics.gpuUtilization > 0.8, "GPU utilization should be high for high-energy content")
        XCTAssertTrue(performanceMetrics.memoryUsage > 300_000_000, "Memory usage should be significant")
        XCTAssertTrue(
            performanceMetrics.thermalState == .high || performanceMetrics.thermalState == .critical,
            "Thermal state should be elevated for high-energy content"
        )
    }

    func testPerformanceOptimizationForRelaxationContent() {
        let config = MotionEnhancementSystem.MotionEnhancementConfig(
            breed: .bulldog,
            contentType: .relaxation
        )

        let performanceMetrics = motionEnhancementSystem.optimizePerformance(config: config)

        XCTAssertTrue(performanceMetrics.gpuUtilization < 0.6, "GPU utilization should be lower for relaxation content")
        XCTAssertTrue(performanceMetrics.memoryUsage < 200_000_000, "Memory usage should be lower")
        XCTAssertTrue(
            performanceMetrics.thermalState == .nominal || performanceMetrics.thermalState == .moderate,
            "Thermal state should be low for relaxation content"
        )
    }

    // MARK: - Demonstration Test

    func testMotionEnhancementDemonstration() {
        // This test ensures the demonstration method runs without throwing an exception
        XCTAssertNoThrow(
            MotionEnhancementSystem.demonstrateMotionEnhancement(),
            "Motion enhancement demonstration should run without errors"
        )
    }
}
