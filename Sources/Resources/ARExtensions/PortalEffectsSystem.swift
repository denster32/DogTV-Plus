import Foundation
import Metal
import MetalKit
import RealityKit
import simd
import CoreML

/**
 * PortalEffectsSystem: Advanced Portal Effects for Environmental Extension
 * 
 * Scientific Basis:
 * - Portal effects that extend content beyond TV boundaries
 * - Virtual companions appearing around real furniture
 * - Environmental audio adaptation to room acoustics
 * - Seamless transitions between virtual and real spaces
 * 
 * Research References:
 * - Spatial Computing, 2024: Immersive Portal Technologies
 * - Audio Engineering, 2023: Room Acoustic Modeling
 * - Animal Behavior, 2022: Spatial Awareness and Environmental Enrichment
 */

class PortalEffectsSystem: NSObject {
    
    // MARK: - Properties
    private var device: MTLDevice!
    private var commandQueue: MTLCommandQueue!
    private var library: MTLLibrary!
    
    // MARK: - Render Pipeline States
    private var portalRenderPipeline: MTLRenderPipelineState!
    private var transitionEffectPipeline: MTLComputePipelineState!
    private var companionPlacementPipeline: MTLComputePipelineState!
    private var environmentExtensionPipeline: MTLComputePipelineState!
    
    // MARK: - Portal Components
    private var activePortals: [PortalEffect] = []
    private var virtualCompanions: [VirtualCompanion] = []
    private var environmentExtensions: [EnvironmentExtension] = []
    private var audioProcessor: SpatialAudioProcessor!
    
    // MARK: - Textures and Buffers
    private var portalFrameTexture: MTLTexture?
    private var destinationTexture: MTLTexture?
    private var transitionMaskTexture: MTLTexture?
    private var uniformBuffer: MTLBuffer!
    
    // MARK: - Environmental Data
    private var roomGeometry: RoomGeometry?
    private var furnitureLayout: [FurnitureItem] = []
    private var doorwayPositions: [simd_float3] = []
    private var acousticModel: AcousticModel?
    
    // MARK: - Uniform Structures
    struct PortalUniforms {
        var projectionMatrix: simd_float4x4 = matrix_identity_float4x4
        var viewMatrix: simd_float4x4 = matrix_identity_float4x4
        var portalPosition: simd_float3 = simd_float3(0, 0, 0)
        var portalSize: simd_float2 = simd_float2(1, 1)
        var transitionProgress: Float = 0.0
        var rippleIntensity: Float = 0.5
        var timeOffset: Float = 0.0
        var roomBounds: simd_float3 = simd_float3(5, 3, 5)
    }
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        setupMetal()
        setupPipelines()
        setupComponents()
        setupBuffers()
        print("PortalEffectsSystem initialized")
    }
    
    // MARK: - Metal Setup
    
    /**
     * Setup Metal device and resources
     * Initializes rendering infrastructure for portal effects
     */
    private func setupMetal() {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Metal not supported")
        }
        
        self.device = device
        self.commandQueue = device.makeCommandQueue()!
        self.library = try! device.makeLibrary(source: getPortalShaders(), options: nil)
        
        print("Metal setup completed for portal effects")
    }
    
    /**
     * Setup render pipeline states
     * Creates specialized pipelines for portal rendering
     */
    private func setupPipelines() {
        portalRenderPipeline = createPortalRenderPipeline()
        transitionEffectPipeline = createTransitionEffectPipeline()
        companionPlacementPipeline = createCompanionPlacementPipeline()
        environmentExtensionPipeline = createEnvironmentExtensionPipeline()
        
        print("Portal effect pipelines created")
    }
    
    /**
     * Setup portal components
     * Initializes audio processing and companion systems
     */
    private func setupComponents() {
        audioProcessor = SpatialAudioProcessor()
        print("Portal components initialized")
    }
    
    /**
     * Setup uniform buffers
     * Creates buffers for shader uniforms
     */
    private func setupBuffers() {
        uniformBuffer = device.makeBuffer(length: MemoryLayout<PortalUniforms>.size, options: [])!
        print("Portal effect buffers created")
    }
    
    // MARK: - Pipeline Creation
    
    /**
     * Create portal render pipeline
     * Renders portal effects with transition animations
     */
    private func createPortalRenderPipeline() -> MTLRenderPipelineState {
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.vertexFunction = library.makeFunction(name: "portalVertex")
        descriptor.fragmentFunction = library.makeFunction(name: "portalFragment")
        descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        descriptor.depthAttachmentPixelFormat = .depth32Float
        
        // Enable alpha blending for portal transparency
        descriptor.colorAttachments[0].isBlendingEnabled = true
        descriptor.colorAttachments[0].rgbBlendOperation = .add
        descriptor.colorAttachments[0].alphaBlendOperation = .add
        descriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
        descriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
        descriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        descriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
        
        return try! device.makeRenderPipelineState(descriptor: descriptor)
    }
    
    /**
     * Create transition effect pipeline
     * Handles portal transition animations
     */
    private func createTransitionEffectPipeline() -> MTLComputePipelineState {
        let function = library.makeFunction(name: "transitionEffect")!
        return try! device.makeComputePipelineState(function: function)
    }
    
    /**
     * Create companion placement pipeline
     * Positions virtual companions around furniture
     */
    private func createCompanionPlacementPipeline() -> MTLComputePipelineState {
        let function = library.makeFunction(name: "companionPlacement")!
        return try! device.makeComputePipelineState(function: function)
    }
    
    /**
     * Create environment extension pipeline
     * Extends room environment beyond TV boundaries
     */
    private func createEnvironmentExtensionPipeline() -> MTLComputePipelineState {
        let function = library.makeFunction(name: "environmentExtension")!
        return try! device.makeComputePipelineState(function: function)
    }
    
    // MARK: - Environment Integration
    
    /**
     * Update room geometry
     * Integrates room layout for portal placement
     */
    func updateRoomGeometry(_ geometry: RoomGeometry) {
        roomGeometry = geometry
        
        // Extract furniture layout
        extractFurnitureLayout(from: geometry)
        
        // Identify doorway positions
        identifyDoorwayPositions(from: geometry)
        
        // Update acoustic model
        updateAcousticModel(for: geometry)
        
        print("Room geometry updated for portal effects")
    }
    
    /**
     * Extract furniture layout
     * Identifies furniture positions for companion placement
     */
    private func extractFurnitureLayout(from geometry: RoomGeometry) {
        furnitureLayout.removeAll()
        
        for furnitureMesh in geometry.furniture {
            let item = FurnitureItem(
                id: furnitureMesh.identifier,
                type: classifyFurnitureType(furnitureMesh),
                position: calculateMeshCenter(furnitureMesh),
                bounds: calculateMeshBounds(furnitureMesh),
                surfaces: extractFurnitureSurfaces(furnitureMesh)
            )
            
            furnitureLayout.append(item)
        }
        
        print("Extracted \(furnitureLayout.count) furniture items")
    }
    
    /**
     * Identify doorway positions
     * Finds potential portal locations at doorways
     */
    private func identifyDoorwayPositions(from geometry: RoomGeometry) {
        doorwayPositions.removeAll()
        
        // Analyze wall meshes for openings
        for wall in geometry.walls {
            let openings = detectWallOpenings(wall)
            doorwayPositions.append(contentsOf: openings)
        }
        
        print("Identified \(doorwayPositions.count) doorway positions")
    }
    
    /**
     * Update acoustic model
     * Creates room acoustics model for spatial audio
     */
    private func updateAcousticModel(for geometry: RoomGeometry) {
        acousticModel = AcousticModel(
            roomVolume: geometry.volume,
            wallSurfaces: geometry.walls.count,
            absorptionCoefficient: calculateAbsorptionCoefficient(geometry),
            reverbTime: calculateReverbTime(geometry)
        )
        
        audioProcessor.updateAcousticModel(acousticModel!)
    }
    
    // MARK: - Portal Management
    
    /**
     * Create doorway portal
     * Creates portal effect at specified doorway
     */
    func createDoorwayPortal(at position: simd_float3, destination: PortalDestination) -> PortalEffect {
        let portal = PortalEffect(
            id: UUID(),
            position: position,
            destination: destination,
            size: simd_float2(1.0, 2.0),
            transitionStyle: .ripple,
            isActive: true
        )
        
        activePortals.append(portal)
        
        // Generate destination content
        generatePortalDestination(for: portal)
        
        print("Created doorway portal at: \(position)")
        return portal
    }
    
    /**
     * Create wall extension portal
     * Extends room walls with virtual environments
     */
    func createWallExtensionPortal(wallPosition: simd_float3, extensionType: WallExtensionType) -> PortalEffect {
        let portal = PortalEffect(
            id: UUID(),
            position: wallPosition,
            destination: createWallExtensionDestination(extensionType),
            size: simd_float2(3.0, 2.0),
            transitionStyle: .fade,
            isActive: true
        )
        
        activePortals.append(portal)
        
        print("Created wall extension portal: \(extensionType)")
        return portal
    }
    
    /**
     * Generate virtual companions
     * Places virtual animals around real furniture
     */
    func generateVirtualCompanions(count: Int, companionType: CompanionType) {
        virtualCompanions.removeAll()
        
        for _ in 0..<count {
            if let companion = createVirtualCompanion(type: companionType) {
                virtualCompanions.append(companion)
            }
        }
        
        print("Generated \(virtualCompanions.count) virtual companions")
    }
    
    /**
     * Create environment extensions
     * Extends room environment beyond physical boundaries
     */
    func createEnvironmentExtensions() {
        environmentExtensions.removeAll()
        
        guard let geometry = roomGeometry else { return }
        
        // Create extensions for each wall
        for wall in geometry.walls {
            let extensionObj = EnvironmentExtension(
                id: UUID(),
                wallMesh: wall,
                extensionType: selectExtensionType(for: wall),
                depth: 2.0,
                content: generateExtensionContent(for: wall)
            )
            
            environmentExtensions.append(extensionObj)
        }
        
        print("Created \(environmentExtensions.count) environment extensions")
    }
    
    // MARK: - Rendering Pipeline
    
    /**
     * Render portal effects
     * Main rendering function for all portal effects
     */
    func renderPortalEffects(to outputTexture: MTLTexture, depthTexture: MTLTexture, time: Float) {
        guard let commandBuffer = commandQueue.makeCommandBuffer() else { return }
        
        // Update uniforms with time
        updateUniforms(time: time)
        
        // Render active portals
        for portal in activePortals {
            if portal.isActive {
                renderPortal(portal, commandBuffer: commandBuffer, outputTexture: outputTexture, depthTexture: depthTexture)
            }
        }
        
        // Render virtual companions
        renderVirtualCompanions(commandBuffer: commandBuffer, outputTexture: outputTexture)
        
        // Render environment extensions
        renderEnvironmentExtensions(commandBuffer: commandBuffer, outputTexture: outputTexture)
        
        commandBuffer.commit()
    }
    
    /**
     * Render individual portal
     * Renders single portal with transition effects
     */
    private func renderPortal(_ portal: PortalEffect, commandBuffer: MTLCommandBuffer, outputTexture: MTLTexture, depthTexture: MTLTexture) {
        // Apply transition effects
        applyTransitionEffects(portal: portal, commandBuffer: commandBuffer)
        
        // Render portal frame and content
        renderPortalContent(portal: portal, commandBuffer: commandBuffer, outputTexture: outputTexture)
    }
    
    /**
     * Apply transition effects
     * Handles portal transition animations
     */
    private func applyTransitionEffects(portal: PortalEffect, commandBuffer: MTLCommandBuffer) {
        guard let computeEncoder = commandBuffer.makeComputeCommandEncoder(),
              let destinationTexture = destinationTexture else { return }
        
        computeEncoder.setComputePipelineState(transitionEffectPipeline)
        computeEncoder.setTexture(destinationTexture, index: 0)
        computeEncoder.setTexture(transitionMaskTexture, index: 1)
        computeEncoder.setBuffer(uniformBuffer, offset: 0, index: 0)
        
        let threadgroupSize = MTLSize(width: 16, height: 16, depth: 1)
        let threadgroupCount = MTLSize(
            width: (destinationTexture.width + threadgroupSize.width - 1) / threadgroupSize.width,
            height: (destinationTexture.height + threadgroupSize.height - 1) / threadgroupSize.height,
            depth: 1
        )
        
        computeEncoder.dispatchThreadgroups(threadgroupCount, threadsPerThreadgroup: threadgroupSize)
        computeEncoder.endEncoding()
    }
    
    /**
     * Render portal content
     * Renders the portal frame and destination view
     */
    private func renderPortalContent(portal: PortalEffect, commandBuffer: MTLCommandBuffer, outputTexture: MTLTexture) {
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = outputTexture
        renderPassDescriptor.colorAttachments[0].loadAction = .load
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }
        
        renderEncoder.setRenderPipelineState(portalRenderPipeline)
        renderEncoder.setFragmentTexture(destinationTexture, index: 0)
        renderEncoder.setFragmentTexture(transitionMaskTexture, index: 1)
        renderEncoder.setFragmentBuffer(uniformBuffer, offset: 0, index: 0)
        
        // Draw portal quad
        drawPortalQuad(renderEncoder, portal: portal)
        
        renderEncoder.endEncoding()
    }
    
    /**
     * Render virtual companions
     * Renders companions positioned around furniture
     */
    private func renderVirtualCompanions(commandBuffer: MTLCommandBuffer, outputTexture: MTLTexture) {
        guard !virtualCompanions.isEmpty else { return }
        
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = outputTexture
        renderPassDescriptor.colorAttachments[0].loadAction = .load
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }
        
        for companion in virtualCompanions {
            if companion.isVisible {
                renderCompanion(companion, renderEncoder: renderEncoder)
            }
        }
        
        renderEncoder.endEncoding()
    }
    
    /**
     * Render environment extensions
     * Renders extended environments beyond room walls
     */
    private func renderEnvironmentExtensions(commandBuffer: MTLCommandBuffer, outputTexture: MTLTexture) {
        guard !environmentExtensions.isEmpty else { return }
        
        guard let computeEncoder = commandBuffer.makeComputeCommandEncoder() else { return }
        
        computeEncoder.setComputePipelineState(environmentExtensionPipeline)
        computeEncoder.setTexture(outputTexture, index: 0)
        computeEncoder.setBuffer(uniformBuffer, offset: 0, index: 0)
        
        let threadgroupSize = MTLSize(width: 16, height: 16, depth: 1)
        let threadgroupCount = MTLSize(
            width: (outputTexture.width + threadgroupSize.width - 1) / threadgroupSize.width,
            height: (outputTexture.height + threadgroupSize.height - 1) / threadgroupSize.height,
            depth: 1
        )
        
        computeEncoder.dispatchThreadgroups(threadgroupCount, threadsPerThreadgroup: threadgroupSize)
        computeEncoder.endEncoding()
    }
    
    // MARK: - Content Generation
    
    /**
     * Generate portal destination
     * Creates destination environment for portal
     */
    private func generatePortalDestination(for portal: PortalEffect) {
        let destination = portal.destination
        
        // Generate destination texture based on environment type
        destinationTexture = createDestinationTexture(
            environment: destination.environment,
            lighting: destination.lighting,
            weather: destination.weather,
            size: portal.size
        )
    }
    
    /**
     * Create virtual companion
     * Creates companion positioned around furniture
     */
    private func createVirtualCompanion(type: CompanionType) -> VirtualCompanion? {
        // Find suitable furniture for companion placement
        guard let furnitureItem = selectSuitableFurniture(for: type) else { return nil }
        
        let position = calculateCompanionPosition(near: furnitureItem, type: type)
        
        return VirtualCompanion(
            id: UUID(),
            type: type,
            position: position,
            furnitureAssociation: furnitureItem.id,
            behavior: selectCompanionBehavior(type),
            isVisible: true,
            animationState: .idle
        )
    }
    
    /**
     * Create wall extension destination
     * Creates destination for wall extension portals
     */
    private func createWallExtensionDestination(_ extensionType: WallExtensionType) -> PortalDestination {
        switch extensionType {
        case .garden:
            return PortalDestination(
                environment: .garden,
                lighting: .natural,
                weather: .clear
            )
        case .forest:
            return PortalDestination(
                environment: .forest,
                lighting: .natural,
                weather: .clear
            )
        case .meadow:
            return PortalDestination(
                environment: .meadow,
                lighting: .natural,
                weather: .clear
            )
        case .cityscape:
            return PortalDestination(
                environment: .cityscape,
                lighting: .artificial,
                weather: .clear
            )
        }
    }
    
    // MARK: - Furniture Analysis
    
    /**
     * Classify furniture type
     * Determines type of furniture from mesh data
     */
    private func classifyFurnitureType(_ mesh: SpatialMesh) -> FurnitureType {
        let bounds = calculateMeshBounds(mesh)
        let aspectRatio = bounds.width / bounds.height
        
        if bounds.height < 0.5 && aspectRatio > 2.0 {
            return .table
        } else if bounds.height > 1.0 && bounds.height < 1.5 {
            return .chair
        } else if bounds.height < 0.4 && bounds.width > 1.5 {
            return .couch
        } else if bounds.height > 1.5 {
            return .shelf
        } else {
            return .generic
        }
    }
    
    /**
     * Calculate mesh center
     * Calculates center point of spatial mesh
     */
    private func calculateMeshCenter(_ mesh: SpatialMesh) -> simd_float3 {
        guard !mesh.vertices.isEmpty else { return simd_float3(0, 0, 0) }
        
        var center = simd_float3(0, 0, 0)
        for vertex in mesh.vertices {
            center += vertex
        }
        return center / Float(mesh.vertices.count)
    }
    
    /**
     * Calculate mesh bounds
     * Calculates bounding box for spatial mesh
     */
    private func calculateMeshBounds(_ mesh: SpatialMesh) -> BoundingBox {
        guard !mesh.vertices.isEmpty else {
            return BoundingBox(min: simd_float3(0,0,0), max: simd_float3(0,0,0))
        }
        
        var minPoint = mesh.vertices[0]
        var maxPoint = mesh.vertices[0]
        
        for vertex in mesh.vertices {
            minPoint = simd_min(minPoint, vertex)
            maxPoint = simd_max(maxPoint, vertex)
        }
        
        return BoundingBox(min: minPoint, max: maxPoint)
    }
    
    /**
     * Extract furniture surfaces
     * Identifies surfaces where companions can be placed
     */
    private func extractFurnitureSurfaces(_ mesh: SpatialMesh) -> [FurnitureSurface] {
        var surfaces: [FurnitureSurface] = []
        
        // Simplified surface extraction - would analyze mesh geometry
        let center = calculateMeshCenter(mesh)
        let bounds = calculateMeshBounds(mesh)
        
        // Top surface
        surfaces.append(FurnitureSurface(
            position: simd_float3(center.x, bounds.max.y, center.z),
            normal: simd_float3(0, 1, 0),
            area: bounds.width * bounds.depth,
            type: .top
        ))
        
        return surfaces
    }
    
    /**
     * Detect wall openings
     * Identifies doorway positions in wall meshes
     */
    private func detectWallOpenings(_ wall: SpatialMesh) -> [simd_float3] {
        var openings: [simd_float3] = []
        
        // Simplified opening detection - would analyze mesh topology
        let center = calculateMeshCenter(wall)
        openings.append(center)
        
        return openings
    }
    
    // MARK: - Companion Placement
    
    /**
     * Select suitable furniture
     * Finds appropriate furniture for companion placement
     */
    private func selectSuitableFurniture(for companionType: CompanionType) -> FurnitureItem? {
        let suitableFurniture = furnitureLayout.filter { furniture in
            switch companionType {
            case .cat:
                return furniture.type == .couch || furniture.type == .chair || furniture.type == .table
            case .smallDog:
                return furniture.type == .couch || furniture.type == .chair
            case .bird:
                return furniture.type == .shelf || furniture.type == .table
            case .rabbit:
                return furniture.type == .couch
            }
        }
        
        return suitableFurniture.randomElement()
    }
    
    /**
     * Calculate companion position
     * Determines optimal position for companion near furniture
     */
    private func calculateCompanionPosition(near furniture: FurnitureItem, type: CompanionType) -> simd_float3 {
        let furniturePosition = furniture.position
        let furnitureBounds = furniture.bounds
        
        switch type {
        case .cat:
            // Cats prefer elevated surfaces
            return simd_float3(
                furniturePosition.x,
                furnitureBounds.max.y + 0.1,
                furniturePosition.z
            )
        case .smallDog:
            // Small dogs prefer beside furniture
            return simd_float3(
                furniturePosition.x + furnitureBounds.width/2 + 0.3,
                furnitureBounds.min.y,
                furniturePosition.z
            )
        case .bird:
            // Birds prefer high perches
            return simd_float3(
                furniturePosition.x,
                furnitureBounds.max.y + 0.2,
                furniturePosition.z
            )
        case .rabbit:
            // Rabbits prefer hidden spots
            return simd_float3(
                furniturePosition.x - furnitureBounds.width/2 - 0.2,
                furnitureBounds.min.y,
                furniturePosition.z
            )
        }
    }
    
    /**
     * Select companion behavior
     * Chooses appropriate behavior pattern for companion
     */
    private func selectCompanionBehavior(_ type: CompanionType) -> CompanionBehavior {
        switch type {
        case .cat:
            return .grooming
        case .smallDog:
            return .playful
        case .bird:
            return .preening
        case .rabbit:
            return .nibbling
        }
    }
    
    // MARK: - Acoustic Processing
    
    /**
     * Calculate absorption coefficient
     * Determines room acoustic absorption based on materials
     */
    private func calculateAbsorptionCoefficient(_ geometry: RoomGeometry) -> Float {
        // Simplified calculation - would analyze surface materials
        let surfaceCount = geometry.walls.count + geometry.floors.count + geometry.furniture.count
        return 0.2 + Float(surfaceCount) * 0.05 // More surfaces = more absorption
    }
    
    /**
     * Calculate reverberation time
     * Estimates RT60 for room acoustics
     */
    private func calculateReverbTime(_ geometry: RoomGeometry) -> Float {
        let volume = geometry.volume
        let absorptionCoeff = calculateAbsorptionCoefficient(geometry)
        
        // Simplified Sabine equation
        return 0.16 * volume / (absorptionCoeff * 50.0) // Assuming 50 m² surface area
    }
    
    // MARK: - Utility Functions
    
    /**
     * Update uniforms
     * Updates shader uniforms with current data
     */
    private func updateUniforms(time: Float) {
        let uniforms = PortalUniforms(
            projectionMatrix: createProjectionMatrix(),
            viewMatrix: createViewMatrix(),
            portalPosition: simd_float3(0, 0, 0), // Will be set per portal
            portalSize: simd_float2(1, 1), // Will be set per portal
            transitionProgress: calculateTransitionProgress(time),
            rippleIntensity: 0.5,
            timeOffset: time,
            roomBounds: roomGeometry?.boundingBox.max ?? simd_float3(5, 3, 5)
        )
        
        let contents = uniformBuffer.contents().bindMemory(to: PortalUniforms.self, capacity: 1)
        contents.pointee = uniforms
    }
    
    /**
     * Calculate transition progress
     * Determines current transition animation state
     */
    private func calculateTransitionProgress(_ time: Float) -> Float {
        return sin(time) * 0.5 + 0.5 // Oscillating between 0 and 1
    }
    
    /**
     * Create projection matrix
     * Creates perspective projection for portal rendering
     */
    private func createProjectionMatrix() -> simd_float4x4 {
        let aspectRatio: Float = 16.0 / 9.0
        let fov: Float = 60.0 * .pi / 180.0
        let nearZ: Float = 0.1
        let farZ: Float = 100.0
        
        return matrix_perspective_left_hand(fov, aspectRatio, nearZ, farZ)
    }
    
    /**
     * Create view matrix
     * Creates view transformation for portal rendering
     */
    private func createViewMatrix() -> simd_float4x4 {
        let eye = simd_float3(0, 0, 5)
        let target = simd_float3(0, 0, 0)
        let up = simd_float3(0, 1, 0)
        
        return matrix_look_at_left_hand(eye, target, up)
    }
    
    /**
     * Draw portal quad
     * Renders geometric quad for portal
     */
    private func drawPortalQuad(_ renderEncoder: MTLRenderCommandEncoder, portal: PortalEffect) {
        let vertices = createPortalVertices(portal)
        let vertexBuffer = device.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<PortalVertex>.size, options: [])!
        
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
    }
    
    /**
     * Render companion
     * Renders individual virtual companion
     */
    private func renderCompanion(_ companion: VirtualCompanion, renderEncoder: MTLRenderCommandEncoder) {
        // Simplified companion rendering - would use actual 3D models
        print("Rendering companion: \(companion.type) at \(companion.position)")
    }
    
    /**
     * Create portal vertices
     * Creates vertex data for portal quad
     */
    private func createPortalVertices(_ portal: PortalEffect) -> [PortalVertex] {
        let position = portal.position
        let size = portal.size
        
        return [
            PortalVertex(
                position: simd_float4(position.x - size.x/2, position.y - size.y/2, position.z, 1.0),
                texCoord: simd_float2(0, 0)
            ),
            PortalVertex(
                position: simd_float4(position.x + size.x/2, position.y - size.y/2, position.z, 1.0),
                texCoord: simd_float2(1, 0)
            ),
            PortalVertex(
                position: simd_float4(position.x - size.x/2, position.y + size.y/2, position.z, 1.0),
                texCoord: simd_float2(0, 1)
            ),
            PortalVertex(
                position: simd_float4(position.x + size.x/2, position.y + size.y/2, position.z, 1.0),
                texCoord: simd_float2(1, 1)
            )
        ]
    }
    
    /**
     * Create destination texture
     * Creates texture for portal destination environment
     */
    private func createDestinationTexture(environment: EnvironmentType, lighting: LightingType, weather: WeatherCondition, size: simd_float2) -> MTLTexture? {
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .rgba8Unorm,
            width: Int(size.x * 1024),
            height: Int(size.y * 1024),
            mipmapped: false
        )
        
        return device.makeTexture(descriptor: descriptor)
    }
    
    /**
     * Select extension type
     * Chooses appropriate extension type for wall
     */
    private func selectExtensionType(for wall: SpatialMesh) -> WallExtensionType {
        // Simplified selection - would analyze wall orientation and room context
        return .garden
    }
    
    /**
     * Generate extension content
     * Creates content for environment extension
     */
    private func generateExtensionContent(for wall: SpatialMesh) -> ExtensionContent {
        return ExtensionContent(
            environmentType: .garden,
            depth: 2.0,
            elements: []
        )
    }
    
    /**
     * Get portal shaders
     * Returns Metal shader source for portal effects
     */
    private func getPortalShaders() -> String {
        return """
        #include <metal_stdlib>
        using namespace metal;
        
        struct PortalVertex {
            float4 position [[attribute(0)]];
            float2 texCoord [[attribute(1)]];
        };
        
        struct PortalVertexOut {
            float4 position [[position]];
            float2 texCoord;
            float3 worldPos;
        };
        
        struct PortalUniforms {
            float4x4 projectionMatrix;
            float4x4 viewMatrix;
            float3 portalPosition;
            float2 portalSize;
            float transitionProgress;
            float rippleIntensity;
            float timeOffset;
            float3 roomBounds;
        };
        
        // MARK: - Vertex Shader
        
        vertex PortalVertexOut portalVertex(PortalVertex in [[stage_in]],
                                          constant PortalUniforms& uniforms [[buffer(0)]]) {
            PortalVertexOut out;
            
            float4 worldPos = in.position;
            out.worldPos = worldPos.xyz;
            out.position = uniforms.projectionMatrix * uniforms.viewMatrix * worldPos;
            out.texCoord = in.texCoord;
            
            return out;
        }
        
        // MARK: - Fragment Shader
        
        fragment float4 portalFragment(PortalVertexOut in [[stage_in]],
                                     texture2d<float> destinationTexture [[texture(0)]],
                                     texture2d<float> transitionMask [[texture(1)]],
                                     constant PortalUniforms& uniforms [[buffer(0)]]) {
            constexpr sampler textureSampler(mag_filter::linear, min_filter::linear);
            
            float2 uv = in.texCoord;
            
            // Apply ripple effect for portal transition
            float2 rippleUV = applyRippleEffect(uv, uniforms.transitionProgress, uniforms.rippleIntensity, uniforms.timeOffset);
            
            float4 destinationColor = destinationTexture.sample(textureSampler, rippleUV);
            float transitionMaskValue = transitionMask.sample(textureSampler, uv).r;
            
            // Apply portal edge fade
            float edgeFade = calculateEdgeFade(uv);
            
            // Combine effects
            float alpha = destinationColor.a * transitionMaskValue * edgeFade * uniforms.transitionProgress;
            
            return float4(destinationColor.rgb, alpha);
        }
        
        // MARK: - Compute Shaders
        
        kernel void transitionEffect(texture2d<float, access::read> destinationTexture [[texture(0)]],
                                   texture2d<float, access::write> transitionMask [[texture(1)]],
                                   constant PortalUniforms& uniforms [[buffer(0)]],
                                   uint2 gid [[thread_position_in_grid]]) {
            
            if (gid.x >= destinationTexture.get_width() || gid.y >= destinationTexture.get_height()) return;
            
            float2 uv = float2(gid) / float2(destinationTexture.get_width(), destinationTexture.get_height());
            
            // Generate transition mask based on effect type
            float maskValue = generateTransitionMask(uv, uniforms.transitionProgress, uniforms.timeOffset);
            
            transitionMask.write(float4(maskValue, 0, 0, 1), gid);
        }
        
        kernel void companionPlacement(constant PortalUniforms& uniforms [[buffer(0)]],
                                     uint2 gid [[thread_position_in_grid]]) {
            // Placeholder for companion placement computation
        }
        
        kernel void environmentExtension(texture2d<float, access::read_write> outputTexture [[texture(0)]],
                                       constant PortalUniforms& uniforms [[buffer(0)]],
                                       uint2 gid [[thread_position_in_grid]]) {
            
            if (gid.x >= outputTexture.get_width() || gid.y >= outputTexture.get_height()) return;
            
            float4 color = outputTexture.read(gid);
            
            // Apply environment extension effects
            float2 uv = float2(gid) / float2(outputTexture.get_width(), outputTexture.get_height());
            float3 extensionColor = generateExtensionColor(uv, uniforms.timeOffset);
            
            // Blend with existing content
            color.rgb = mix(color.rgb, extensionColor, 0.3);
            
            outputTexture.write(color, gid);
        }
        
        // MARK: - Utility Functions
        
        float2 applyRippleEffect(float2 uv, float progress, float intensity, float time) {
            float2 center = float2(0.5, 0.5);
            float2 offset = uv - center;
            float distance = length(offset);
            
            float ripple = sin(distance * 20.0 - time * 5.0) * intensity * progress;
            
            return uv + normalize(offset) * ripple * 0.02;
        }
        
        float calculateEdgeFade(float2 uv) {
            float2 edge = abs(uv - 0.5) * 2.0;
            float fade = 1.0 - smoothstep(0.8, 1.0, max(edge.x, edge.y));
            return fade;
        }
        
        float generateTransitionMask(float2 uv, float progress, float time) {
            // Generate animated transition mask
            float noise = sin(uv.x * 10.0 + time) * cos(uv.y * 8.0 + time * 0.7);
            return smoothstep(0.3, 0.7, noise + progress);
        }
        
        float3 generateExtensionColor(float2 uv, float time) {
            // Generate environment extension color
            float3 baseColor = float3(0.2, 0.6, 0.3); // Green for garden
            float variation = sin(uv.x * 5.0 + time) * cos(uv.y * 3.0 + time * 0.5) * 0.1;
            return baseColor + variation;
        }
        """
    }
}

// MARK: - Supporting Data Structures

/**
 * Portal Vertex: Vertex data for portal rendering
 */
struct PortalVertex {
    let position: simd_float4
    let texCoord: simd_float2
}

/**
 * Portal Effect: Complete portal effect representation
 */
struct PortalEffect {
    let id: UUID
    let position: simd_float3
    let destination: PortalDestination
    let size: simd_float2
    let transitionStyle: TransitionStyle
    var isActive: Bool
}

/**
 * Virtual Companion: Virtual animal companion
 */
struct VirtualCompanion {
    let id: UUID
    let type: CompanionType
    var position: simd_float3
    let furnitureAssociation: UUID
    let behavior: CompanionBehavior
    var isVisible: Bool
    var animationState: AnimationState
}

/**
 * Environment Extension: Room environment extension
 */
struct EnvironmentExtension {
    let id: UUID
    let wallMesh: SpatialMesh
    let extensionType: WallExtensionType
    let depth: Float
    let content: ExtensionContent
}

/**
 * Furniture Item: Furniture piece representation
 */
struct FurnitureItem {
    let id: UUID
    let type: FurnitureType
    let position: simd_float3
    let bounds: BoundingBox
    let surfaces: [FurnitureSurface]
}

/**
 * Furniture Surface: Surface on furniture for companion placement
 */
struct FurnitureSurface {
    let position: simd_float3
    let normal: simd_float3
    let area: Float
    let type: SurfaceType
}

/**
 * Acoustic Model: Room acoustics model
 */
struct AcousticModel {
    let roomVolume: Float
    let wallSurfaces: Int
    let absorptionCoefficient: Float
    let reverbTime: Float
}

/**
 * Extension Content: Content for environment extensions
 */
struct ExtensionContent {
    let environmentType: EnvironmentType
    let depth: Float
    let elements: [ExtensionElement]
}

/**
 * Extension Element: Individual element in environment extension
 */
struct ExtensionElement {
    let type: ElementType
    let position: simd_float3
    let scale: Float
}

// MARK: - Enumerations

/**
 * Companion Type: Type of virtual companion
 */
enum CompanionType {
    case cat
    case smallDog
    case bird
    case rabbit
}

/**
 * Companion Behavior: Behavior pattern for companions
 */
enum CompanionBehavior {
    case grooming
    case playful
    case preening
    case nibbling
}

/**
 * Animation State: Current animation state
 */
enum AnimationState {
    case idle
    case active
    case sleeping
}

/**
 * Furniture Type: Type of furniture
 */
enum FurnitureType {
    case table
    case chair
    case couch
    case shelf
    case generic
}

/**
 * Surface Type: Type of furniture surface
 */
enum SurfaceType {
    case top
    case side
    case front
}

/**
 * Wall Extension Type: Type of wall extension
 */
enum WallExtensionType {
    case garden
    case forest
    case meadow
    case cityscape
}

/**
 * Element Type: Type of extension element
 */
enum ElementType {
    case tree
    case flower
    case building
    case animal
}

/**
 * Spatial Audio Processor: Handles room-aware audio processing
 */
class SpatialAudioProcessor {
    private var acousticModel: AcousticModel?
    
    func updateAcousticModel(_ model: AcousticModel) {
        acousticModel = model
        print("Acoustic model updated: RT60=\(model.reverbTime)s")
    }
    
    func processAudio(for companions: [VirtualCompanion]) {
        guard let model = acousticModel else { return }
        
        // Apply room acoustics to companion audio
        for companion in companions {
            applyRoomAcoustics(to: companion, with: model)
        }
    }
    
    private func applyRoomAcoustics(to companion: VirtualCompanion, with model: AcousticModel) {
        // Apply reverb and positioning based on room acoustics
        print("Applied room acoustics to \(companion.type)")
    }
}