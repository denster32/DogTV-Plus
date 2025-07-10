import MetalKit
import DogTVCore

enum MetalError: Error {
    case deviceNotSupported
    case commandQueueCreationFailed
}

class MetalRenderer {
    private let device: MTLDevice
    private let commandQueue: MTLCommandQueue
    private let library: MTLLibrary
    private var pipelineStates: [SceneType: MTLRenderPipelineState] = [:]
    private var vertexBuffer: MTLBuffer?
    private var time: Float = 0

    init() throws {
        guard let device = MTLCreateSystemDefaultDevice() else {
            throw MetalError.deviceNotSupported
        }
        self.device = device
        guard let commandQueue = device.makeCommandQueue() else {
            throw MetalError.commandQueueCreationFailed
        }
        self.commandQueue = commandQueue
        self.library = try device.makeDefaultLibrary(bundle: .main)
        buildVertices()
        try buildPipelines()
    }

    private func buildVertices() {
        let vertices: [Vertex] = [
            Vertex(position: SIMD2<Float>(x: -1, y: -1), texCoord: SIMD2<Float>(x: 0, y: 1)),
            Vertex(position: SIMD2<Float>(x: 1, y: -1), texCoord: SIMD2<Float>(x: 1, y: 1)),
            Vertex(position: SIMD2<Float>(x: -1, y: 1), texCoord: SIMD2<Float>(x: 0, y: 0)),
            Vertex(position: SIMD2<Float>(x: 1, y: 1), texCoord: SIMD2<Float>(x: 1, y: 0))
        ]
        vertexBuffer = device.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<Vertex>.stride, options: [])
    }

    private func buildPipelines() throws {
        for sceneType in SceneType.allCases {
            let pipelineDescriptor = MTLRenderPipelineDescriptor()
            pipelineDescriptor.vertexFunction = library.makeFunction(name: "vertex_shader")

            let fragmentFunctionName: String
            switch sceneType {
            case .ocean:
                fragmentFunctionName = "ocean_fragment_shader"
            case .forest:
                fragmentFunctionName = "forest_fragment_shader"
            case .fireflies:
                fragmentFunctionName = "fireflies_fragment_shader"
            case .rain:
                fragmentFunctionName = "rain_fragment_shader"
            case .sunset:
                fragmentFunctionName = "sunset_fragment_shader"
            case .stars:
                fragmentFunctionName = "stars_fragment_shader"
            // Add other cases here as shaders are created
            default:
                fragmentFunctionName = "fragment_shader" // Basic shader
            }

            if let fragmentFunction = library.makeFunction(name: fragmentFunctionName) {
                pipelineDescriptor.fragmentFunction = fragmentFunction
            } else {
                print("Warning: Fragment function '\(fragmentFunctionName)' not found. Using default.")
                pipelineDescriptor.fragmentFunction = library.makeFunction(name: "fragment_shader")
            }

            let vertexDescriptor = MTLVertexDescriptor()
            vertexDescriptor.attributes[0].format = .float2
            vertexDescriptor.attributes[0].offset = 0
            vertexDescriptor.attributes[0].bufferIndex = 0
            vertexDescriptor.attributes[1].format = .float2
            vertexDescriptor.attributes[1].offset = MemoryLayout<SIMD2<Float>>.stride
            vertexDescriptor.attributes[1].bufferIndex = 0
            vertexDescriptor.layouts[0].stride = MemoryLayout<Vertex>.stride

            pipelineDescriptor.vertexDescriptor = vertexDescriptor
            pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm

            pipelineStates[sceneType] = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        }
    }

    func render(sceneType: SceneType, in view: MTKView) {
        guard let drawable = view.currentDrawable,
              let renderPassDescriptor = view.currentRenderPassDescriptor,
              let pipelineState = pipelineStates[sceneType] else {
            return
        }

        time += 0.01

        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            return
        }

        commandEncoder.setRenderPipelineState(pipelineState)
        commandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        commandEncoder.setFragmentBytes(&time, length: MemoryLayout<Float>.stride, index: 0)
        commandEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)

        commandEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }

    func resize(size: CGSize) {
        // Handle view resize
    }
}
