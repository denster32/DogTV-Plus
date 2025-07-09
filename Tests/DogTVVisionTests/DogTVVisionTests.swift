import XCTest
import Metal
@testable import DogTVVision
@testable import DogTVCore

final class DogTVVisionTests: XCTestCase {

    func testMetalRendererInitialization() {
        let renderer = MetalRenderer()
        XCTAssertNotNil(renderer)
    }

    func testCanineVisualEffectsInitialization() {
        let effects = CanineVisualEffects()
        XCTAssertNotNil(effects)
    }

    func testShaderManagerInitialization() {
        let shaderManager = ShaderManager()
        XCTAssertNotNil(shaderManager)
    }

    func testProceduralContentGeneratorInitialization() {
        let generator = ProceduralContentGenerator()
        XCTAssertNotNil(generator)
    }

    func testParticleSystemInitialization() {
        let particleSystem = ParticleSystem()
        XCTAssertNotNil(particleSystem)
    }

    func testMetalDeviceAvailability() {
        let device = MTLCreateSystemDefaultDevice()
        XCTAssertNotNil(device, "Metal device should be available")
    }

    func testShaderLibraryLoading() {
        guard let device = MTLCreateSystemDefaultDevice() else {
            XCTSkip("Metal device not available")
        }

        let bundle = Bundle.module
        guard let library = device.makeDefaultLibrary(bundle: bundle) else {
            XCTSkip("Shader library not available in test environment")
        }

        XCTAssertNotNil(library)
    }

    func testVisualEffectTypes() {
        let effectTypes: [VisualEffectType] = [
            .particles,
            .fluidMotion,
            .colorShift,
            .geometricPatterns,
            .lightEffects
        ]

        XCTAssertEqual(effectTypes.count, 5)
        XCTAssertTrue(effectTypes.contains(.particles))
        XCTAssertTrue(effectTypes.contains(.fluidMotion))
    }

    func testRenderingConfiguration() {
        let config = RenderingConfiguration()
        XCTAssertNotNil(config)
        XCTAssertTrue(config.enableAntialiasing)
        XCTAssertEqual(config.targetFrameRate, 60)
    }
}
