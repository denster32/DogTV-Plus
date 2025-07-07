import XCTest
import Metal
import CoreImage
import Vision

@testable import DogTV_

/**
 * VisionComparisonSystemTests: Comprehensive testing for vision comparison rendering
 * 
 * Focuses on:
 * - Side-by-side vision rendering
 * - Color space conversion accuracy
 * - Performance and rendering quality
 */
class VisionComparisonSystemTests: XCTestCase {
    
    // MARK: - Test Constants
    
    /// Minimum acceptable rendering quality
    private let MIN_RENDERING_QUALITY: Float = 0.7
    
    /// Maximum acceptable rendering time
    private let MAX_RENDERING_TIME: TimeInterval = 0.05 // 50ms
    
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
    
    // MARK: - Rendering Mode Tests
    
    /// Test side-by-side vision rendering
    func testSideBySideRendering() {
        guard let device = MTLCreateSystemDefaultDevice(),
              let texture = createTestTexture(device: device) else {
            XCTFail("Failed to create test texture")
            return
        }
        
        let renderingConfigs = [
            VisionComparisonSystem.VisionRenderingConfig(mode: .sideBySide, colorProfile: .dichromatic),
            VisionComparisonSystem.VisionRenderingConfig(mode: .sideBySide, colorProfile: .trichromatic)
        ]
        
        for config in renderingConfigs {
            do {
                let start = Date()
                let result = try visionComparisonSystem.renderVisionComparison(
                    humanTexture: texture,
                    config: config
                )
                let renderTime = Date().timeIntervalSince(start)
                
                XCTAssertNotNil(result, "Vision comparison rendering failed for \(config.mode)")
                XCTAssertLessThan(renderTime, MAX_RENDERING_TIME, "Rendering time too long for \(config.mode)")
            } catch {
                XCTFail("Vision comparison rendering threw an error: \(error)")
            }
        }
    }
    
    /// Test dog vision color conversion
    func testDogVisionColorConversion() {
        guard let device = MTLCreateSystemDefaultDevice(),
              let texture = createTestTexture(device: device) else {
            XCTFail("Failed to create test texture")
            return
        }
        
        let colorProfiles = [
            VisionComparisonSystem.ColorPerceptionProfile.dichromatic,
            VisionComparisonSystem.ColorPerceptionProfile.monochromatic
        ]
        
        for profile in colorProfiles {
            let config = VisionComparisonSystem.VisionRenderingConfig(
                mode: .dogVision,
                colorProfile: profile,
                renderingQuality: .high
            )
            
            do {
                let result = try visionComparisonSystem.renderVisionComparison(
                    humanTexture: texture,
                    config: config
                )
                
                XCTAssertNotNil(result, "Dog vision color conversion failed for \(profile)")
            } catch {
                XCTFail("Dog vision color conversion threw an error: \(error)")
            }
        }
    }
    
    /// Test rendering quality variations
    func testRenderingQualityVariations() {
        guard let device = MTLCreateSystemDefaultDevice(),
              let texture = createTestTexture(device: device) else {
            XCTFail("Failed to create test texture")
            return
        }
        
        let qualityLevels: [VisionComparisonSystem.RenderingQuality] = [
            .low, .medium, .high, .ultra
        ]
        
        for quality in qualityLevels {
            let config = VisionComparisonSystem.VisionRenderingConfig(
                mode: .sideBySide,
                colorProfile: .dichromatic,
                renderingQuality: quality
            )
            
            do {
                let start = Date()
                let result = try visionComparisonSystem.renderVisionComparison(
                    humanTexture: texture,
                    config: config
                )
                let renderTime = Date().timeIntervalSince(start)
                
                XCTAssertNotNil(result, "Rendering failed for quality level \(quality)")
                XCTAssertLessThan(renderTime, MAX_RENDERING_TIME * Double(quality.rawValue + 1), "Rendering time too long for \(quality)")
            } catch {
                XCTFail("Rendering threw an error for quality level \(quality): \(error)")
            }
        }
    }
    
    // MARK: - Performance Tests
    
    /// Comprehensive performance test for vision comparison rendering
    func testVisionComparisonPerformance() {
        guard let device = MTLCreateSystemDefaultDevice(),
              let texture = createTestTexture(device: device) else {
            XCTFail("Failed to create test texture")
            return
        }
        
        let iterations = 100
        let config = VisionComparisonSystem.VisionRenderingConfig(
            mode: .sideBySide,
            colorProfile: .dichromatic,
            renderingQuality: .high
        )
        
        measure {
            for _ in 0..<iterations {
                do {
                    _ = try visionComparisonSystem.renderVisionComparison(
                        humanTexture: texture,
                        config: config
                    )
                } catch {
                    XCTFail("Performance test failed: \(error)")
                }
            }
        }
    }
    
    // MARK: - Live Content Conversion Tests
    
    /// Test live content color space conversion
    func testLiveContentColorSpaceConversion() {
        guard let device = MTLCreateSystemDefaultDevice() else {
            XCTFail("Failed to create Metal device")
            return
        }
        
        // Create multiple test textures to simulate video frames
        let testFrames = (0..<5).compactMap { _ in
            createTestTexture(device: device)
        }
        
        let colorProfiles: [VisionComparisonSystem.ColorPerceptionProfile] = [
            .dichromatic,
            .monochromatic,
            .trichromatic
        ]
        
        for profile in colorProfiles {
            let config = VisionComparisonSystem.VisionRenderingConfig(
                mode: .dogVision,
                colorProfile: profile,
                renderingQuality: .high
            )
            
            let convertedFrames = visionComparisonSystem.simulateLiveVideoConversion(
                videoFrames: testFrames,
                config: config
            )
            
            XCTAssertEqual(convertedFrames.count, testFrames.count, "Frame count should remain consistent")
            
            for (index, frame) in convertedFrames.enumerated() {
                XCTAssertNotNil(frame, "Frame \(index) conversion failed for \(profile)")
                
                // Optional: Add more specific checks for converted frames
                if let convertedFrame = frame {
                    XCTAssertEqual(convertedFrame.width, testFrames[index].width, "Converted frame width should match original")
                    XCTAssertEqual(convertedFrame.height, testFrames[index].height, "Converted frame height should match original")
                }
            }
        }
    }
    
    /// Test live content conversion performance
    func testLiveContentConversionPerformance() {
        guard let device = MTLCreateSystemDefaultDevice() else {
            XCTFail("Failed to create Metal device")
            return
        }
        
        // Create multiple test textures to simulate video frames
        let testFrames = (0..<30).compactMap { _ in
            createTestTexture(device: device)
        }
        
        let config = VisionComparisonSystem.VisionRenderingConfig(
            mode: .dogVision,
            colorProfile: .dichromatic,
            renderingQuality: .high
        )
        
        measure {
            _ = visionComparisonSystem.simulateLiveVideoConversion(
                videoFrames: testFrames,
                config: config
            )
        }
    }
    
    /// Test color space conversion edge cases
    func testColorSpaceConversionEdgeCases() {
        guard let device = MTLCreateSystemDefaultDevice(),
              let texture = createTestTexture(device: device) else {
            XCTFail("Failed to create test texture")
            return
        }
        
        let edgeCaseConfigs = [
            VisionComparisonSystem.VisionRenderingConfig(
                mode: .dogVision,
                colorProfile: .monochromatic,
                renderingQuality: .low
            ),
            VisionComparisonSystem.VisionRenderingConfig(
                mode: .dogVision,
                colorProfile: .trichromatic,
                renderingQuality: .ultra
            )
        ]
        
        for config in edgeCaseConfigs {
            do {
                let result = try visionComparisonSystem.convertLiveContentToDogVision(
                    texture,
                    config: config
                )
                
                XCTAssertNotNil(result, "Edge case conversion failed for \(config.colorProfile)")
            } catch {
                XCTFail("Edge case conversion threw an error: \(error)")
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

// MARK: - Extension for RenderingQuality Raw Value
extension VisionComparisonSystem.RenderingQuality: RawRepresentable {
    public typealias RawValue = Int
    
    public init?(rawValue: RawValue) {
        switch rawValue {
        case 0: self = .low
        case 1: self = .medium
        case 2: self = .high
        case 3: self = .ultra
        default: return nil
        }
    }
    
    public var rawValue: RawValue {
        switch self {
        case .low: return 0
        case .medium: return 1
        case .high: return 2
        case .ultra: return 3
        }
    }
} 