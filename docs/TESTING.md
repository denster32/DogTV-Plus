# Testing Guide

## Overview

DogTV+ uses a comprehensive testing strategy covering unit tests, integration tests, and performance validation.

## Test Structure

```
Tests/
├── DogTVCoreTests/         # Core business logic tests
├── DogTVUITests/           # UI component tests
├── DogTVVisionTests/       # Metal shader and rendering tests
├── DogTVDataTests/         # Data management tests
└── DogTVSecurityTests/     # Security and privacy tests
```

## Running Tests

### All Tests
```bash
swift test
```

### Specific Test Suite
```bash
swift test --filter DogTVCoreTests
swift test --filter DogTVVisionTests
```

### Parallel Testing
```bash
swift test --parallel
```

## Core Tests

### ProceduralContentGenerator Tests

```swift
class ProceduralContentGeneratorTests: XCTestCase {
    func testSceneGeneration() async throws {
        let generator = ProceduralContentGenerator()
        let texture = try await generator.generateScene(.oceanWaves)
        XCTAssertNotNil(texture)
        XCTAssertEqual(texture.width, 1920)
        XCTAssertEqual(texture.height, 1080)
    }
    
    func testShaderCompilation() {
        let generator = ProceduralContentGenerator()
        XCTAssertNoThrow(try generator.compileShaders())
    }
}
```

### BehaviorAnalyzer Tests

```swift
class CanineBehaviorAnalyzerTests: XCTestCase {
    func testEngagementDetection() {
        let analyzer = CanineBehaviorAnalyzer()
        let mockFrame = createMockCVPixelBuffer()
        
        let metrics = analyzer.processFrame(mockFrame)
        XCTAssertGreaterThanOrEqual(metrics.engagement, 0.0)
        XCTAssertLessThanOrEqual(metrics.engagement, 1.0)
    }
}
```

## UI Tests

### ContentView Tests

```swift
class EnhancedContentViewTests: XCTestCase {
    func testViewRendering() {
        let contentView = EnhancedContentView()
        let hostingController = UIHostingController(rootView: contentView)
        
        XCTAssertNotNil(hostingController.view)
    }
    
    func testSceneTransitions() {
        // Test scene switching animations
    }
}
```

## Performance Tests

### Rendering Performance

```swift
class RenderingPerformanceTests: XCTestCase {
    func testFrameRate() {
        measure {
            let generator = ProceduralContentGenerator()
            for _ in 0..<60 {
                _ = try? generator.renderFrame()
            }
        }
    }
    
    func testMemoryUsage() {
        // Memory leak detection
        measureMetrics([.totalAllocatedBytes]) {
            let generator = ProceduralContentGenerator()
            for _ in 0..<100 {
                _ = try? generator.generateScene(.oceanWaves)
            }
        }
    }
}
```

### Startup Performance

```swift
func testLaunchTime() {
    measure {
        let app = EnhancedContentView()
        _ = app.body
    }
}
```

## Metal Shader Tests

### Shader Compilation

```swift
class ShaderTests: XCTestCase {
    func testAllShadersCompile() {
        let shaderNames = [
            "ocean_wave_shader",
            "forest_canopy_shader",
            "firefly_shader",
            "gentle_rain_shader",
            "zen_garden_shader",
            "squirrel_chase_shader"
        ]
        
        for shaderName in shaderNames {
            XCTAssertNoThrow(try compileShader(shaderName))
        }
    }
}
```

### Rendering Output Tests

```swift
func testShaderOutput() {
    let uniforms = ProceduralUniforms()
    let output = renderShader("ocean_wave_shader", uniforms: uniforms)
    
    XCTAssertNotNil(output)
    XCTAssertEqual(output.pixelFormat, .rgba8Unorm)
}
```

## Integration Tests

### End-to-End Workflow

```swift
class IntegrationTests: XCTestCase {
    func testCompleteWorkflow() async throws {
        // 1. Initialize system
        let contentView = EnhancedContentView()
        
        // 2. Start behavior analysis
        contentView.behaviorAnalyzer.startAnalysis()
        
        // 3. Generate content
        let scene = try await contentView.contentGenerator.generateScene(.forestCanopy)
        
        // 4. Verify output
        XCTAssertNotNil(scene)
    }
}
```

## Mock Objects

### Mock CVPixelBuffer

```swift
func createMockCVPixelBuffer() -> CVPixelBuffer {
    var pixelBuffer: CVPixelBuffer?
    CVPixelBufferCreate(
        kCFAllocatorDefault,
        640, 480,
        kCVPixelFormatType_32BGRA,
        nil,
        &pixelBuffer
    )
    return pixelBuffer!
}
```

### Mock MTLDevice

```swift
class MockMTLDevice: MTLDevice {
    // Mock implementation for testing
}
```

## Test Configuration

### XCTest Configuration

```swift
class TestConfiguration {
    static let shared = TestConfiguration()
    
    var useMockDevice = false
    var enablePerformanceTesting = true
    var recordBaselines = false
}
```

### Performance Baselines

- Frame generation: < 16ms (60 FPS target)
- Shader compilation: < 100ms
- Memory usage: < 200MB peak
- Launch time: < 2 seconds

## Continuous Integration

### GitHub Actions

```yaml
name: Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v2
      - name: Run tests
        run: swift test --parallel
```

### Test Coverage

Target: 90%+ code coverage

```bash
swift test --enable-code-coverage
xcrun llvm-cov show .build/debug/DogTVPlusPackageTests.xctest
```

## Manual Testing

### Device Testing Checklist

- [ ] Apple TV 4K (3rd generation)
- [ ] Apple TV 4K (2nd generation)  
- [ ] Apple TV HD
- [ ] iOS Simulator
- [ ] Physical iOS device

### Visual Testing

- [ ] All shaders render correctly
- [ ] No visual artifacts
- [ ] Smooth animations at 60 FPS
- [ ] Proper color reproduction
- [ ] Memory usage stays within limits

### Accessibility Testing

- [ ] VoiceOver navigation
- [ ] High contrast mode
- [ ] Reduced motion support
- [ ] Voice control compatibility

## Debugging

### Metal Debugging

```swift
// Enable Metal validation
let device = MTLCreateSystemDefaultDevice()
device?.debugLevel = .extended
```

### Performance Profiling

Use Instruments.app profiles:
- Time Profiler
- Allocations
- Metal System Trace
- Core Animation