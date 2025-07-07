import XCTest
import Metal
import CoreImage
import Vision
import UIKit

@testable import DogTV_

/**
 * SocialSharingSystemTests: Comprehensive testing for social sharing capabilities
 * 
 * Focuses on:
 * - Screenshot capture
 * - Texture processing
 * - Social media sharing
 * - Performance
 */
class SocialSharingSystemTests: XCTestCase {
    
    // MARK: - Test Constants
    
    /// Maximum acceptable rendering time
    private let MAX_RENDERING_TIME: TimeInterval = 0.05 // 50ms
    
    /// Maximum acceptable screenshot processing time
    private let MAX_SCREENSHOT_TIME: TimeInterval = 0.1 // 100ms
    
    // MARK: - Test Properties
    
    /// Social sharing system for testing
    private var socialSharingSystem: SocialSharingSystem!
    
    // MARK: - Setup and Teardown
    
    override func setUp() {
        super.setUp()
        do {
            socialSharingSystem = try SocialSharingSystem()
        } catch {
            XCTFail("Failed to initialize SocialSharingSystem: \(error)")
        }
    }
    
    override func tearDown() {
        socialSharingSystem = nil
        super.tearDown()
    }
    
    // MARK: - Screenshot Capture Tests
    
    /// Test screenshot capture with different configurations
    func testScreenshotCapture() {
        guard let device = MTLCreateSystemDefaultDevice(),
              let sourceTexture = createTestTexture(device: device) else {
            XCTFail("Failed to create test texture")
            return
        }
        
        let resolutions: [SocialSharingSystem.ScreenshotResolution] = [
            .standard,
            .fullHD,
            .fourK,
            .custom(width: 2560, height: 1440)
        ]
        
        let annotationStyles: [SocialSharingSystem.AnnotationStyle] = [
            .none,
            .minimal,
            .scientific,
            .educational
        ]
        
        let watermarkPreferences: [SocialSharingSystem.WatermarkPreference] = [
            .none,
            .minimal,
            .branded,
            .fullBranding
        ]
        
        for resolution in resolutions {
            for annotationStyle in annotationStyles {
                for watermarkPreference in watermarkPreferences {
                    let config = SocialSharingSystem.ScreenshotConfig(
                        resolution: resolution,
                        annotationStyle: annotationStyle,
                        watermarkPreference: watermarkPreference
                    )
                    
                    let metadata = SocialSharingSystem.SharingMetadata(
                        breed: "borderCollie",
                        behaviorContext: "High-energy play",
                        scientificInsights: ["Motion sensitivity", "Color perception"]
                    )
                    
                    do {
                        let start = Date()
                        let result = try socialSharingSystem.captureScreenshot(
                            texture: sourceTexture,
                            config: config,
                            metadata: metadata
                        )
                        let processingTime = Date().timeIntervalSince(start)
                        
                        XCTAssertNotNil(result, "Screenshot capture failed")
                        XCTAssertLessThan(processingTime, MAX_SCREENSHOT_TIME, "Screenshot processing time too long")
                    } catch {
                        XCTFail("Screenshot capture threw an error: \(error)")
                    }
                }
            }
        }
    }
    
    // MARK: - Social Media Sharing Tests
    
    /// Test social media sharing with different platforms
    func testSocialMediaSharing() {
        guard let device = MTLCreateSystemDefaultDevice(),
              let screenshotTexture = createTestTexture(device: device) else {
            XCTFail("Failed to create test texture")
            return
        }
        
        let platforms: [SocialSharingSystem.SharingPlatform] = [
            .twitter,
            .instagram,
            .facebook,
            .tiktok,
            .custom("CustomPlatform")
        ]
        
        let privacyLevels: [SocialSharingSystem.PrivacyLevel] = [
            .minimal,
            .standard,
            .detailed,
            .scientific
        ]
        
        let contentTypes: [SocialSharingSystem.ContentType] = [
            .screenshot,
            .videoClip,
            .scientificData
        ]
        
        for platform in platforms {
            for privacyLevel in privacyLevels {
                for contentType in contentTypes {
                    let config = SocialSharingSystem.SharingConfiguration(
                        platform: platform,
                        privacyLevel: privacyLevel,
                        contentType: contentType
                    )
                    
                    let metadata = SocialSharingSystem.SharingMetadata(
                        breed: "germanShepherd",
                        behaviorContext: "Training session",
                        scientificInsights: ["Breed-specific learning patterns"]
                    )
                    
                    do {
                        try socialSharingSystem.shareToSocialMedia(
                            texture: screenshotTexture,
                            config: config,
                            metadata: metadata
                        )
                    } catch let error as SocialSharingSystem.SharingError {
                        switch error {
                        case .platformNotSupported:
                            // This is expected for custom platforms
                            if case .custom = platform {
                                continue
                            }
                            XCTFail("Unexpected platform not supported error")
                        default:
                            XCTFail("Social media sharing failed: \(error)")
                        }
                    } catch {
                        XCTFail("Unexpected error during social media sharing: \(error)")
                    }
                }
            }
        }
    }
    
    // MARK: - Performance Tests
    
    /// Comprehensive performance test for screenshot processing
    func testScreenshotProcessingPerformance() {
        guard let device = MTLCreateSystemDefaultDevice(),
              let sourceTexture = createTestTexture(device: device) else {
            XCTFail("Failed to create test texture")
            return
        }
        
        let iterations = 50
        let config = SocialSharingSystem.ScreenshotConfig(
            resolution: .fullHD,
            annotationStyle: .scientific,
            watermarkPreference: .branded
        )
        
        measure {
            for _ in 0..<iterations {
                do {
                    _ = try socialSharingSystem.captureScreenshot(
                        texture: sourceTexture,
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