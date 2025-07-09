import XCTest
import Metal
import CoreImage
import Vision

@testable import DogTVVision

/**
 * VisionEducationOverlaySystemTests: Comprehensive testing for educational overlay rendering
 * 
 * Focuses on:
 * - Overlay generation
 * - Localization support
 * - Performance and rendering quality
 */
class VisionEducationOverlaySystemTests: XCTestCase {

    // MARK: - Test Constants

    /// Minimum acceptable rendering quality
    private let MIN_RENDERING_QUALITY: Float = 0.7

    /// Maximum acceptable rendering time
    private let MAX_RENDERING_TIME: TimeInterval = 0.05 // 50ms

    // MARK: - Test Properties

    /// Vision education overlay system for testing
    private var visionEducationOverlaySystem: VisionEducationOverlaySystem!

    // MARK: - Setup and Teardown

    override func setUp() {
        super.setUp()
        do {
            visionEducationOverlaySystem = try VisionEducationOverlaySystem()
        } catch {
            XCTFail("Failed to initialize VisionEducationOverlaySystem: \(error)")
        }
    }

    override func tearDown() {
        visionEducationOverlaySystem = nil
        super.tearDown()
    }

    // MARK: - Overlay Generation Tests

    /// Test educational overlay generation for different content types
    func testEducationalOverlayGeneration() {
        guard let device = MTLCreateSystemDefaultDevice(),
              let backgroundTexture = createTestTexture(device: device) else {
            XCTFail("Failed to create test texture")
            return
        }

        let contentTypes: [VisionEducationOverlaySystem.EducationalContentType] = [
            .colorPerception,
            .motionSensitivity,
            .visualAcuity,
            .depthPerception
        ]

        for contentType in contentTypes {
            let configs = [
                VisionEducationOverlaySystem.EducationalOverlayConfig(
                    contentType: contentType,
                    complexity: .basic,
                    breed: "labrador"
                ),
                VisionEducationOverlaySystem.EducationalOverlayConfig(
                    contentType: contentType,
                    complexity: .advanced,
                    breed: "borderCollie",
                    language: "es"
                )
            ]

            for config in configs {
                do {
                    let start = Date()
                    let result = try visionEducationOverlaySystem.generateEducationalOverlay(
                        backgroundTexture: backgroundTexture,
                        config: config
                    )
                    let renderTime = Date().timeIntervalSince(start)

                    XCTAssertNotNil(result, "Educational overlay generation failed for \(contentType)")
                    XCTAssertLessThan(renderTime, MAX_RENDERING_TIME, "Rendering time too long for \(contentType)")
                } catch {
                    XCTFail("Educational overlay generation threw an error: \(error)")
                }
            }
        }
    }

    /// Test localization support
    func testLocalizationSupport() {
        guard let device = MTLCreateSystemDefaultDevice(),
              let backgroundTexture = createTestTexture(device: device) else {
            XCTFail("Failed to create test texture")
            return
        }

        let languages = ["en", "es"]

        for language in languages {
            let configs = [
                VisionEducationOverlaySystem.EducationalOverlayConfig(
                    contentType: .colorPerception,
                    complexity: .basic,
                    language: language
                ),
                VisionEducationOverlaySystem.EducationalOverlayConfig(
                    contentType: .motionSensitivity,
                    complexity: .advanced,
                    breed: "germanShepherd",
                    language: language
                )
            ]

            for config in configs {
                do {
                    let result = try visionEducationOverlaySystem.generateEducationalOverlay(
                        backgroundTexture: backgroundTexture,
                        config: config
                    )

                    XCTAssertNotNil(result, "Localized overlay generation failed for \(language)")
                } catch {
                    XCTFail("Localized overlay generation threw an error: \(error)")
                }
            }
        }
    }

    /// Test complexity levels
    func testComplexityLevels() {
        guard let device = MTLCreateSystemDefaultDevice(),
              let backgroundTexture = createTestTexture(device: device) else {
            XCTFail("Failed to create test texture")
            return
        }

        let complexityLevels: [VisionEducationOverlaySystem.EducationComplexity] = [
            .basic, .intermediate, .advanced, .scientific
        ]

        for complexity in complexityLevels {
            let config = VisionEducationOverlaySystem.EducationalOverlayConfig(
                contentType: .visualAcuity,
                complexity: complexity,
                breed: "borderCollie"
            )

            do {
                let start = Date()
                let result = try visionEducationOverlaySystem.generateEducationalOverlay(
                    backgroundTexture: backgroundTexture,
                    config: config
                )
                let renderTime = Date().timeIntervalSince(start)

                XCTAssertNotNil(result, "Educational overlay generation failed for \(complexity)")
                XCTAssertLessThan(renderTime, MAX_RENDERING_TIME * Double(complexity.rawValue + 1), "Rendering time too long for \(complexity)")
            } catch {
                XCTFail("Educational overlay generation threw an error: \(error)")
            }
        }
    }

    // MARK: - Performance Tests

    /// Comprehensive performance test for educational overlay rendering
    func testEducationalOverlayPerformance() {
        guard let device = MTLCreateSystemDefaultDevice(),
              let backgroundTexture = createTestTexture(device: device) else {
            XCTFail("Failed to create test texture")
            return
        }

        let iterations = 100
        let config = VisionEducationOverlaySystem.EducationalOverlayConfig(
            contentType: .motionSensitivity,
            complexity: .advanced,
            breed: "labrador"
        )

        measure {
            for _ in 0..<iterations {
                do {
                    _ = try visionEducationOverlaySystem.generateEducationalOverlay(
                        backgroundTexture: backgroundTexture,
                        config: config
                    )
                } catch {
                    XCTFail("Performance test failed: \(error)")
                }
            }
        }
    }

    // MARK: - Utility Methods

    /// Create a test texture for rendering
    private func createTestTexture(device: MTLDevice) -> MTLTexture? {
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .bgra8Unorm,
            width: 1920,
            height: 1080,
            mipmapped: false
        )
        descriptor.usage = [.renderTarget, .shaderRead, .shaderWrite]
        return device.makeTexture(descriptor: descriptor)
    }
}

// MARK: - Extension for EducationComplexity Raw Value
extension VisionEducationOverlaySystem.EducationComplexity: RawRepresentable {
    public typealias RawValue = Int

    public init?(rawValue: RawValue) {
        switch rawValue {
        case 0: self = .basic
        case 1: self = .intermediate
        case 2: self = .advanced
        case 3: self = .scientific
        default: return nil
        }
    }

    public var rawValue: RawValue {
        switch self {
        case .basic: return 0
        case .intermediate: return 1
        case .advanced: return 2
        case .scientific: return 3
        }
    }
}
