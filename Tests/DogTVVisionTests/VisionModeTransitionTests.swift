import XCTest
import Metal
import CoreImage
import Vision

@testable import DogTV_

/**
 * VisionModeTransitionTests: Comprehensive testing for vision mode transitions
 * 
 * Focuses on:
 * - Transition rendering
 * - Performance
 * - Different transition types and easing
 */
class VisionModeTransitionTests: XCTestCase {
    
    // MARK: - Test Constants
    
    /// Maximum acceptable rendering time
    private let MAX_RENDERING_TIME: TimeInterval = 0.05 // 50ms
    
    /// Maximum acceptable transition time
    private let MAX_TRANSITION_TIME: TimeInterval = 1.0 // 1 second
    
    // MARK: - Test Properties
    
    /// Vision comparison system for testing
    private var visionComparisonSystem: VisionComparisonSystem!
    
    // MARK: - Setup and Teardown
    
    override func setUp() {
        super.setUp()
        do {
            visionComparisonSystem = try VisionComparisonSystem()
        } catch {
            XCTFail("Failed to initialize VisionComparisonSystem: \(error)")
        }
    }
    
    override func tearDown() {
        visionComparisonSystem = nil
        super.tearDown()
    }
    
    // MARK: - Transition Type Tests
    
    /// Test all transition types
    func testVisionModeTransitionTypes() {
        guard let device = MTLCreateSystemDefaultDevice(),
              let fromTexture = createTestTexture(device: device),
              let toTexture = createTestTexture(device: device) else {
            XCTFail("Failed to create test textures")
            return
        }
        
        let transitionTypes: [VisionComparisonSystem.TransitionType] = [
            .fade, .dissolve, .slide, .zoom, .morph
        ]
        
        for transitionType in transitionTypes {
            let config = VisionComparisonSystem.VisionModeTransitionConfig(
                fromMode: .humanVision,
                toMode: .dogVision,
                transitionType: transitionType,
                duration: 0.5,
                easing: .easeInOut
            )
            
            do {
                let start = Date()
                let result = try visionComparisonSystem.performVisionModeTransition(
                    fromTexture: fromTexture,
                    toTexture: toTexture,
                    config: config
                )
                let renderTime = Date().timeIntervalSince(start)
                
                XCTAssertNotNil(result, "Transition rendering failed for \(transitionType)")
                XCTAssertLessThan(renderTime, MAX_RENDERING_TIME, "Rendering time too long for \(transitionType)")
            } catch {
                XCTFail("Transition rendering threw an error: \(error)")
            }
        }
    }
    
    // MARK: - Easing Function Tests
    
    /// Test different easing functions
    func testVisionModeTransitionEasing() {
        guard let device = MTLCreateSystemDefaultDevice(),
              let fromTexture = createTestTexture(device: device),
              let toTexture = createTestTexture(device: device) else {
            XCTFail("Failed to create test textures")
            return
        }
        
        let easingTypes: [VisionComparisonSystem.TimingCurve] = [
            .linear, .easeIn, .easeOut, .easeInOut, .spring
        ]
        
        for easing in easingTypes {
            let config = VisionComparisonSystem.VisionModeTransitionConfig(
                fromMode: .humanVision,
                toMode: .dogVision,
                transitionType: .fade,
                duration: 0.5,
                easing: easing
            )
            
            do {
                let result = try visionComparisonSystem.performVisionModeTransition(
                    fromTexture: fromTexture,
                    toTexture: toTexture,
                    config: config
                )
                
                XCTAssertNotNil(result, "Transition rendering failed for \(easing)")
            } catch {
                XCTFail("Transition rendering threw an error: \(error)")
            }
        }
    }
    
    // MARK: - Animated Transition Tests
    
    /// Test animated vision mode transition
    func testAnimatedVisionModeTransition() {
        guard let device = MTLCreateSystemDefaultDevice(),
              let fromTexture = createTestTexture(device: device),
              let toTexture = createTestTexture(device: device) else {
            XCTFail("Failed to create test textures")
            return
        }
        
        let expectation = XCTestExpectation(description: "Vision Mode Transition")
        
        let config = VisionComparisonSystem.VisionModeTransitionConfig(
            fromMode: .humanVision,
            toMode: .dogVision,
            transitionType: .fade,
            duration: 0.5,
            easing: .easeInOut
        )
        
        var progressSteps: [Float] = []
        var transitionCompleted = false
        
        visionComparisonSystem.animateVisionModeTransition(
            fromTexture: fromTexture,
            toTexture: toTexture,
            config: config,
            progressHandler: { progress in
                progressSteps.append(progress)
            },
            completionHandler: { result in
                XCTAssertNotNil(result, "Animated transition failed")
                XCTAssertTrue(progressSteps.last == 1.0, "Transition did not complete fully")
                transitionCompleted = true
                expectation.fulfill()
            }
        )
        
        wait(for: [expectation], timeout: MAX_TRANSITION_TIME)
        
        XCTAssertTrue(transitionCompleted, "Transition did not complete")
        XCTAssertTrue(progressSteps.count > 1, "Not enough progress steps")
        XCTAssertTrue(progressSteps.first == 0.0, "First progress step should be 0.0")
        XCTAssertTrue(progressSteps.last == 1.0, "Last progress step should be 1.0")
    }
    
    // MARK: - Performance Tests
    
    /// Comprehensive performance test for vision mode transitions
    func testVisionModeTransitionPerformance() {
        guard let device = MTLCreateSystemDefaultDevice(),
              let fromTexture = createTestTexture(device: device),
              let toTexture = createTestTexture(device: device) else {
            XCTFail("Failed to create test textures")
            return
        }
        
        let iterations = 50
        let config = VisionComparisonSystem.VisionModeTransitionConfig(
            fromMode: .humanVision,
            toMode: .dogVision,
            transitionType: .fade,
            duration: 0.5,
            easing: .easeInOut
        )
        
        measure {
            for _ in 0..<iterations {
                do {
                    _ = try visionComparisonSystem.performVisionModeTransition(
                        fromTexture: fromTexture,
                        toTexture: toTexture,
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