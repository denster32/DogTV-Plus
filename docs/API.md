# API Reference

## Core Components

### ProceduralContentGenerator

Main class for real-time content generation using Metal shaders.

```swift
public class ProceduralContentGenerator: ObservableObject {
    public func generateScene(_ scene: CanineScene) async throws -> MTLTexture
    public func updateUniforms(_ uniforms: ProceduralUniforms)
    public func setActiveShader(_ shader: String)
}
```

### CanineBehaviorAnalyzer

AI-powered behavior analysis engine.

```swift
public class CanineBehaviorAnalyzer: ObservableObject {
    public func startAnalysis()
    public func processFrame(_ frame: CVPixelBuffer) -> BehaviorMetrics
    public func getEngagementLevel() -> Float
}
```

### EnhancedContentView

Main SwiftUI view component.

```swift
public struct EnhancedContentView: View {
    @StateObject private var contentGenerator = ProceduralContentGenerator()
    @StateObject private var behaviorAnalyzer = CanineBehaviorAnalyzer()
}
```

## Data Types

### CanineScene

```swift
public enum CanineScene: String, CaseIterable {
    case oceanWaves = "Ocean Waves"
    case forestCanopy = "Forest Canopy"
    case fireflies = "Fireflies"
    case gentleRain = "Gentle Rain"
    case zenGarden = "Zen Garden"
    case squirrelChase = "Squirrel Chase"
}
```

### ProceduralUniforms

```swift
public struct ProceduralUniforms {
    var time: Float
    var resolution: SIMD2<Float>
    var canineBlue: SIMD3<Float>
    var canineYellow: SIMD3<Float>
    var motionSpeed: Float
    var engagementLevel: Float
}
```

### BehaviorMetrics

```swift
public struct BehaviorMetrics {
    let engagement: Float
    let attention: Float
    let stress: Float
    let interest: Float
    let timestamp: Date
}
```

## Metal Shaders

### Ocean Wave Shader

```metal
fragment float4 ocean_wave_shader(float4 position [[stage_in]],
                                 constant ProceduralUniforms& uniforms [[buffer(0)]])
```

### Forest Canopy Shader

```metal
fragment float4 forest_canopy_shader(float4 position [[stage_in]],
                                    constant ProceduralUniforms& uniforms [[buffer(0)]])
```

### Firefly Shader

```metal
fragment float4 firefly_shader(float4 position [[stage_in]],
                              constant ProceduralUniforms& uniforms [[buffer(0)]])
```

## Error Handling

### ContentError

```swift
public enum ContentError: Error {
    case generationFailed
    case shaderCompilationError
    case metalDeviceUnavailable
    case invalidScene
}
```

### AnalysisError

```swift
public enum AnalysisError: Error {
    case visionFrameworkUnavailable
    case modelLoadFailed
    case processingError
}
```

## Usage Examples

### Basic Setup

```swift
import DogTVCore
import DogTVVision
import DogTVBehavior

let generator = ProceduralContentGenerator()
let analyzer = CanineBehaviorAnalyzer()

try await generator.generateScene(.oceanWaves)
analyzer.startAnalysis()
```

### Custom Scene Configuration

```swift
var uniforms = ProceduralUniforms()
uniforms.motionSpeed = 0.5
uniforms.engagementLevel = 0.8

generator.updateUniforms(uniforms)
```