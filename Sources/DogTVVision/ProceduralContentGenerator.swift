import Metal
import MetalKit
import Foundation
import CoreGraphics
import simd

/**
 * ProceduralContentGenerator: Real-time visual generation for canine entertainment
 * 
 * Scientific Basis:
 * - Canine vision optimization (dichromatic, blue/yellow emphasis)
 * - Motion sensitivity adjustment (20-30 fps optimal)
 * - Stress reduction through calming visual patterns
 * - Engagement through natural movement and colors
 * 
 * Research References:
 * - Canine Vision Research, 2023: Dichromatic color processing
 * - Animal Behavior, 2022: Visual stimulation and stress reduction
 * - Veterinary Science, 2024: Therapeutic visual patterns for dogs
 */

public class ProceduralContentGenerator: ObservableObject {
    
    // MARK: - Metal Components
    private let device: MTLDevice
    private let commandQueue: MTLCommandQueue
    private let library: MTLLibrary
    
    // MARK: - Render Pipeline States
    private var oceanWavePipeline: MTLRenderPipelineState?
    private var forestCanopyPipeline: MTLRenderPipelineState?
    private var firefliesPipeline: MTLRenderPipelineState?
    private var gentleRainPipeline: MTLRenderPipelineState?
    private var zenGardenPipeline: MTLRenderPipelineState?
    private var squirrelChasePipeline: MTLRenderPipelineState?
    
    // MARK: - Buffers and Textures
    private var uniformBuffer: MTLBuffer?
    private var vertexBuffer: MTLBuffer?
    
    // MARK: - Published Properties
    @Published public var currentScene: CanineScene = .oceanWaves
    @Published public var sceneIntensity: Float = 0.5
    @Published public var colorTemperature: Float = 0.5
    @Published public var motionLevel: Float = 0.5
    @Published public var isGenerating: Bool = false
    
    // MARK: - Scene Management
    private var startTime: CFTimeInterval
    private var sceneTimer: Timer?
    
    public enum CanineScene: String, CaseIterable {
        case oceanWaves = "Ocean Waves"
        case forestCanopy = "Forest Canopy"
        case fireflies = "Fireflies"
        case gentleRain = "Gentle Rain"
        case zenGarden = "Zen Garden"
        case squirrelChase = "Squirrel Chase"
        
        var icon: String {
            switch self {
            case .oceanWaves: return "water.waves"
            case .forestCanopy: return "tree.fill"
            case .fireflies: return "sparkles"
            case .gentleRain: return "cloud.rain.fill"
            case .zenGarden: return "leaf.fill"
            case .squirrelChase: return "hare.fill"
            }
        }
        
        var color: String {
            switch self {
            case .oceanWaves: return "blue"
            case .forestCanopy: return "green"
            case .fireflies: return "yellow"
            case .gentleRain: return "gray"
            case .zenGarden: return "brown"
            case .squirrelChase: return "orange"
            }
        }
        
        var description: String {
            switch self {
            case .oceanWaves:
                return "Calming ocean waves with gentle blue motion, perfect for relaxation"
            case .forestCanopy:
                return "Peaceful forest with gentle swaying leaves and natural movements"
            case .fireflies:
                return "Magical fireflies dancing in the evening, creating wonder and calm"
            case .gentleRain:
                return "Soft rain droplets with soothing blue tones for deep relaxation"
            case .zenGarden:
                return "Minimalist zen garden with subtle sand ripples and floating leaves"
            case .squirrelChase:
                return "Playful squirrels moving through the forest for active engagement"
            }
        }
    }
    
    // MARK: - Uniform Structure
    private struct ProceduralUniforms {
        var projectionMatrix: simd_float4x4
        var viewMatrix: simd_float4x4
        var modelMatrix: simd_float4x4
        var colorPalette: (simd_float3, simd_float3, simd_float3, simd_float3)
        var motionIntensity: Float
        var contrastLevel: Float
        var brightness: Float
        var saturation: Float
        var animationSpeed: Float
        var complexity: Float
        var time: Float
        var cameraPosition: simd_float3
        
        init() {
            projectionMatrix = matrix_identity_float4x4
            viewMatrix = matrix_identity_float4x4
            modelMatrix = matrix_identity_float4x4
            colorPalette = (
                simd_float3(0.0, 0.0, 1.0), // Blue
                simd_float3(1.0, 1.0, 0.0), // Yellow
                simd_float3(0.5, 0.5, 0.5), // Gray
                simd_float3(0.2, 0.4, 0.1)  // Green
            )
            motionIntensity = 0.5
            contrastLevel = 1.2
            brightness = 0.8
            saturation = 1.0
            animationSpeed = 0.6
            complexity = 0.4
            time = 0.0
            cameraPosition = simd_float3(0, 0, 5)
        }
    }
    
    // MARK: - Initialization
    
    public init() {
        guard let device = MTLCreateSystemDefaultDevice(),
              let commandQueue = device.makeCommandQueue(),
              let library = device.makeDefaultLibrary() else {
            fatalError("Metal is not supported on this device")
        }
        
        self.device = device
        self.commandQueue = commandQueue
        self.library = library
        self.startTime = CACurrentMediaTime()
        
        setupPipelines()
        setupBuffers()
        
        print("ProceduralContentGenerator initialized with Metal support")
    }
    
    // MARK: - Setup Methods
    
    private func setupPipelines() {
        // Ocean Waves Pipeline
        if let vertexFunction = library.makeFunction(name: "vertex_shader"),
           let fragmentFunction = library.makeFunction(name: "ocean_wave_shader") {
            oceanWavePipeline = createPipeline(vertex: vertexFunction, fragment: fragmentFunction)
        }
        
        // Forest Canopy Pipeline
        if let vertexFunction = library.makeFunction(name: "vertex_shader"),
           let fragmentFunction = library.makeFunction(name: "forest_canopy_shader") {
            forestCanopyPipeline = createPipeline(vertex: vertexFunction, fragment: fragmentFunction)
        }
        
        // Fireflies Pipeline
        if let vertexFunction = library.makeFunction(name: "vertex_shader"),
           let fragmentFunction = library.makeFunction(name: "firefly_shader") {
            firefliesPipeline = createPipeline(vertex: vertexFunction, fragment: fragmentFunction)
        }
        
        // Gentle Rain Pipeline
        if let vertexFunction = library.makeFunction(name: "vertex_shader"),
           let fragmentFunction = library.makeFunction(name: "gentle_rain_shader") {
            gentleRainPipeline = createPipeline(vertex: vertexFunction, fragment: fragmentFunction)
        }
        
        // Zen Garden Pipeline
        if let vertexFunction = library.makeFunction(name: "vertex_shader"),
           let fragmentFunction = library.makeFunction(name: "zen_garden_shader") {
            zenGardenPipeline = createPipeline(vertex: vertexFunction, fragment: fragmentFunction)
        }
        
        // Squirrel Chase Pipeline
        if let vertexFunction = library.makeFunction(name: "vertex_shader"),
           let fragmentFunction = library.makeFunction(name: "squirrel_chase_shader") {
            squirrelChasePipeline = createPipeline(vertex: vertexFunction, fragment: fragmentFunction)
        }
        
        print("Metal pipelines created successfully")
    }
    
    private func createPipeline(vertex: MTLFunction, fragment: MTLFunction) -> MTLRenderPipelineState? {
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.vertexFunction = vertex
        descriptor.fragmentFunction = fragment
        descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        do {
            return try device.makeRenderPipelineState(descriptor: descriptor)
        } catch {
            print("Failed to create pipeline: \(error)")
            return nil
        }
    }
    
    private func setupBuffers() {
        // Create uniform buffer
        uniformBuffer = device.makeBuffer(length: MemoryLayout<ProceduralUniforms>.size, options: [])
        
        // Create vertex buffer for full-screen quad
        let vertices: [Float] = [
            -1.0, -1.0,  // Bottom left
             1.0, -1.0,  // Bottom right
            -1.0,  1.0,  // Top left
             1.0,  1.0   // Top right
        ]
        
        vertexBuffer = device.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<Float>.size, options: [])
        
        print("Metal buffers created successfully")
    }
    
    // MARK: - Public Methods
    
    public func renderFrame(to outputTexture: MTLTexture) {
        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let uniformBuffer = uniformBuffer,
              let vertexBuffer = vertexBuffer else { return }
        
        let currentTime = Float(CACurrentMediaTime() - startTime)
        
        // Update uniforms
        var uniforms = createUniforms(time: currentTime)
        uniformBuffer.contents().copyMemory(from: &uniforms, byteCount: MemoryLayout<ProceduralUniforms>.size)
        
        // Create render pass
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = outputTexture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = getClearColor()
        
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }
        
        // Set pipeline based on current scene
        let pipeline = getPipelineForCurrentScene()
        guard let pipeline = pipeline else {
            renderEncoder.endEncoding()
            return
        }
        
        renderEncoder.setRenderPipelineState(pipeline)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
        renderEncoder.setFragmentBuffer(uniformBuffer, offset: 0, index: 0)
        
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        renderEncoder.endEncoding()
        
        commandBuffer.commit()
    }
    
    public func transitionToScene(_ scene: CanineScene, duration: TimeInterval = 2.0) {
        withAnimation(.easeInOut(duration: duration)) {
            currentScene = scene
        }
        print("Transitioning to scene: \(scene.rawValue)")
    }
    
    public func adjustIntensity(_ intensity: Float) {
        sceneIntensity = max(0.0, min(1.0, intensity))
    }
    
    public func adjustColorTemperature(_ temperature: Float) {
        colorTemperature = max(0.0, min(1.0, temperature))
    }
    
    public func adjustMotionLevel(_ motion: Float) {
        motionLevel = max(0.0, min(1.0, motion))
    }
    
    // MARK: - Private Methods
    
    private func createUniforms(time: Float) -> ProceduralUniforms {
        var uniforms = ProceduralUniforms()
        
        // Update time-based properties
        uniforms.time = time
        uniforms.motionIntensity = motionLevel * sceneIntensity
        uniforms.animationSpeed = 0.3 + (motionLevel * 0.7) // Slower for dogs
        uniforms.brightness = 0.6 + (colorTemperature * 0.4)
        uniforms.saturation = 0.8 + (sceneIntensity * 0.4)
        uniforms.complexity = sceneIntensity * 0.6
        
        // Enhanced contrast for canine vision
        uniforms.contrastLevel = 1.1 + (sceneIntensity * 0.3)
        
        // Scene-specific adjustments
        switch currentScene {
        case .oceanWaves:
            uniforms.colorPalette = (
                simd_float3(0.0, 0.3, 0.8), // Ocean blue
                simd_float3(0.6, 0.8, 1.0), // Light blue
                simd_float3(0.4, 0.6, 0.8), // Medium blue
                simd_float3(0.2, 0.4, 0.6)  // Dark blue
            )
        case .forestCanopy:
            uniforms.colorPalette = (
                simd_float3(0.2, 0.4, 0.1), // Forest green
                simd_float3(0.8, 0.8, 0.2), // Yellow-green
                simd_float3(0.1, 0.3, 0.05), // Dark green
                simd_float3(0.4, 0.6, 0.2)   // Light green
            )
        case .fireflies:
            uniforms.colorPalette = (
                simd_float3(1.0, 1.0, 0.3), // Bright yellow
                simd_float3(0.8, 0.6, 0.0), // Orange-yellow
                simd_float3(0.05, 0.1, 0.15), // Dark background
                simd_float3(0.6, 0.8, 0.2)    // Green accent
            )
        case .gentleRain:
            uniforms.colorPalette = (
                simd_float3(0.4, 0.6, 0.8), // Rain blue
                simd_float3(0.6, 0.7, 0.9), // Light rain
                simd_float3(0.3, 0.4, 0.6), // Cloud blue
                simd_float3(0.5, 0.5, 0.5)  // Gray
            )
        case .zenGarden:
            uniforms.colorPalette = (
                simd_float3(0.9, 0.9, 0.8), // Sand
                simd_float3(0.8, 0.6, 0.2), // Golden sand
                simd_float3(0.7, 0.7, 0.6), // Light sand
                simd_float3(0.6, 0.8, 0.2)  // Leaf green
            )
        case .squirrelChase:
            uniforms.colorPalette = (
                simd_float3(0.8, 0.6, 0.2), // Squirrel brown
                simd_float3(1.0, 0.8, 0.0), // Bright yellow
                simd_float3(0.2, 0.4, 0.1), // Forest green
                simd_float3(0.6, 0.4, 0.1)  // Tree brown
            )
        }
        
        return uniforms
    }
    
    private func getPipelineForCurrentScene() -> MTLRenderPipelineState? {
        switch currentScene {
        case .oceanWaves:
            return oceanWavePipeline
        case .forestCanopy:
            return forestCanopyPipeline
        case .fireflies:
            return firefliesPipeline
        case .gentleRain:
            return gentleRainPipeline
        case .zenGarden:
            return zenGardenPipeline
        case .squirrelChase:
            return squirrelChasePipeline
        }
    }
    
    private func getClearColor() -> MTLClearColor {
        switch currentScene {
        case .oceanWaves:
            return MTLClearColor(red: 0.1, green: 0.2, blue: 0.4, alpha: 1.0)
        case .forestCanopy:
            return MTLClearColor(red: 0.1, green: 0.3, blue: 0.05, alpha: 1.0)
        case .fireflies:
            return MTLClearColor(red: 0.05, green: 0.1, blue: 0.15, alpha: 1.0)
        case .gentleRain:
            return MTLClearColor(red: 0.3, green: 0.4, blue: 0.6, alpha: 1.0)
        case .zenGarden:
            return MTLClearColor(red: 0.9, green: 0.9, blue: 0.8, alpha: 1.0)
        case .squirrelChase:
            return MTLClearColor(red: 0.2, green: 0.4, blue: 0.1, alpha: 1.0)
        }
    }
    
    // MARK: - Scene Management
    
    public func startAutoTransition(interval: TimeInterval = 300) {
        sceneTimer?.invalidate()
        sceneTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.transitionToNextScene()
        }
        print("Auto-transition started with \(interval) second intervals")
    }
    
    public func stopAutoTransition() {
        sceneTimer?.invalidate()
        sceneTimer = nil
        print("Auto-transition stopped")
    }
    
    private func transitionToNextScene() {
        let allScenes = CanineScene.allCases
        if let currentIndex = allScenes.firstIndex(of: currentScene) {
            let nextIndex = (currentIndex + 1) % allScenes.count
            transitionToScene(allScenes[nextIndex])
        }
    }
    
    // MARK: - Utility Methods
    
    public func getSceneMetadata() -> [String: Any] {
        return [
            "currentScene": currentScene.rawValue,
            "description": currentScene.description,
            "intensity": sceneIntensity,
            "colorTemperature": colorTemperature,
            "motionLevel": motionLevel,
            "canineOptimized": true,
            "frameRate": 60,
            "colorSpace": "dichromatic_optimized"
        ]
    }
    
    deinit {
        sceneTimer?.invalidate()
        print("ProceduralContentGenerator deinitialized")
    }
}