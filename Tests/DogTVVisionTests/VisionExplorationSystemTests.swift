import XCTest
import Metal
import CoreImage
import Vision

@testable import DogTV_

/**
 * VisionExplorationSystemTests: Comprehensive testing for interactive vision exploration
 * 
 * Focuses on:
 * - Guided tour generation
 * - Zoom and focus controls
 * - Annotation generation
 * - Performance and rendering quality
 */
class VisionExplorationSystemTests: XCTestCase {
    
    // MARK: - Test Constants
    
    /// Minimum acceptable rendering quality
    private let MIN_RENDERING_QUALITY: Float = 0.7
    
    /// Maximum acceptable rendering time
    private let MAX_RENDERING_TIME: TimeInterval = 0.1 // 100ms
    
    // MARK: - Test Properties
    
    /// Vision comparison system for testing
    private var visionComparisonSystem: VisionComparisonSystem!
    
    /// Vision exploration system for testing
    private var visionExplorationSystem: VisionExplorationSystem!
    
    // MARK: - Setup and Teardown
    
    override func setUp() {
        super.setUp()
        do {
            visionComparisonSystem = try VisionComparisonSystem()
            visionExplorationSystem = VisionExplorationSystem(visionComparisonSystem: visionComparisonSystem)
        } catch {
            XCTFail("Failed to initialize VisionExplorationSystem: \(error)")
        }
    }
    
    override func tearDown() {
        visionComparisonSystem = nil
        visionExplorationSystem = nil
        super.tearDown()
    }
    
    // MARK: - Guided Tour Generation Tests
    
    /// Test guided tour generation for different environments
    func testGuidedTourGeneration() {
        guard let device = MTLCreateSystemDefaultDevice(),
              let texture = createTestTexture(device: device) else {
            XCTFail("Failed to create test texture")
            return
        }
        
        let environments: [VisionExplorationSystem.EnvironmentType] = [
            .park, .beach, .forest, .urban, .home
        ]
        
        for environment in environments {
            let config = VisionExplorationSystem.ExplorationConfig(
                mode: .guidedTour,
                environment: environment,
                zoomLevel: 1.5,
                annotationStyle: .scientific
            )
            
            do {
                let start = Date()
                let tourTextures = try visionExplorationSystem.generateGuidedTour(
                    texture: texture,
                    config: config
                )
                let renderTime = Date().timeIntervalSince(start)
                
                XCTAssertFalse(tourTextures.isEmpty, "Guided tour should generate textures for \(environment)")
                XCTAssertLessThan(renderTime, MAX_RENDERING_TIME, "Guided tour generation time too long for \(environment)")
                
                // Verify texture properties
                for (index, tourTexture) in tourTextures.enumerated() {
                    XCTAssertEqual(tourTexture.width, texture.width, "Tour texture \(index) width should match original")
                    XCTAssertEqual(tourTexture.height, texture.height, "Tour texture \(index) height should match original")
                }
            } catch {
                XCTFail("Guided tour generation failed for \(environment): \(error)")
            }
        }
    }
    
    // MARK: - Annotation Generation Tests
    
    /// Test annotation generation for different annotation styles
    func testAnnotationGeneration() {
        guard let device = MTLCreateSystemDefaultDevice(),
              let texture = createTestTexture(device: device) else {
            XCTFail("Failed to create test texture")
            return
        }
        
        let annotationStyles: [VisionExplorationSystem.AnnotationStyle] = [
            .scientific, .educational, .interactive, .minimal
        ]
        
        for style in annotationStyles {
            let config = VisionExplorationSystem.ExplorationConfig(
                mode: .annotatedView,
                annotationStyle: style
            )
            
            do {
                let start = Date()
                let annotatedTexture = try visionExplorationSystem.generateAnnotations(
                    texture: texture,
                    config: config
                )
                let renderTime = Date().timeIntervalSince(start)
                
                XCTAssertNotNil(annotatedTexture, "Annotation generation failed for \(style)")
                XCTAssertLessThan(renderTime, MAX_RENDERING_TIME, "Annotation generation time too long for \(style)")
                
                // Verify texture properties
                XCTAssertEqual(annotatedTexture?.width, texture.width, "Annotated texture width should match original")
                XCTAssertEqual(annotatedTexture?.height, texture.height, "Annotated texture height should match original")
            } catch {
                XCTFail("Annotation generation failed for \(style): \(error)")
            }
        }
    }
    
    // MARK: - Performance Tests
    
    /// Comprehensive performance test for vision exploration
    func testVisionExplorationPerformance() {
        guard let device = MTLCreateSystemDefaultDevice(),
              let texture = createTestTexture(device: device) else {
            XCTFail("Failed to create test texture")
            return
        }
        
        let iterations = 50
        let config = VisionExplorationSystem.ExplorationConfig(
            mode: .guidedTour,
            environment: .park,
            zoomLevel: 1.5,
            annotationStyle: .scientific
        )
        
        measure {
            for _ in 0..<iterations {
                do {
                    _ = try visionExplorationSystem.generateGuidedTour(
                        texture: texture,
                        config: config
                    )
                } catch {
                    XCTFail("Performance test failed: \(error)")
                }
            }
        }
    }
    
    // MARK: - Error Handling Tests
    
    /// Test error handling for invalid exploration modes
    func testInvalidModeHandling() {
        guard let device = MTLCreateSystemDefaultDevice(),
              let texture = createTestTexture(device: device) else {
            XCTFail("Failed to create test texture")
            return
        }
        
        // Test guided tour with annotation mode
        var config = VisionExplorationSystem.ExplorationConfig(
            mode: .annotatedView,
            environment: .park
        )
        
        XCTAssertThrowsError(try visionExplorationSystem.generateGuidedTour(
            texture: texture,
            config: config
        ), "Should throw error for invalid guided tour mode")
        
        // Test annotations with guided tour mode
        config = VisionExplorationSystem.ExplorationConfig(
            mode: .guidedTour,
            annotationStyle: .scientific
        )
        
        XCTAssertThrowsError(try visionExplorationSystem.generateAnnotations(
            texture: texture,
            config: config
        ), "Should throw error for invalid annotation mode")
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
        descriptor.usage = [.renderTarget, .shaderWrite]
        return device.makeTexture(descriptor: descriptor)
    }
} 