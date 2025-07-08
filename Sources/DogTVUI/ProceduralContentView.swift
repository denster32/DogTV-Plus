import SwiftUI
import MetalKit
import DogTVVision

/// ProceduralContentView: Main view for displaying real-time procedural content optimized for dogs
public struct ProceduralContentView: View {
    @StateObject private var contentGenerator = ProceduralContentGenerator()
    @StateObject private var sceneManager = CanineSceneManager()
    @State private var showControls = false
    @State private var controlsTimer: Timer?
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // Main procedural content view
            MetalRenderView(contentGenerator: contentGenerator)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    toggleControls()
                }
            
            // Overlay controls (minimal, non-intrusive)
            if showControls {
                VStack {
                    Spacer()
                    
                    // Scene controls
                    HStack {
                        // Scene selection
                        Menu {
                            ForEach(ProceduralContentGenerator.CanineScene.allCases, id: \.self) { scene in
                                Button(action: {
                                    contentGenerator.transitionToScene(scene)
                                    sceneManager.selectScene(scene)
                                }) {
                                    Label(scene.rawValue, systemImage: scene.icon)
                                }
                            }
                        } label: {
                            HStack {
                                Image(systemName: contentGenerator.currentScene.icon)
                                Text(contentGenerator.currentScene.rawValue)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(20)
                        }
                        
                        Spacer()
                        
                        // Auto-transition toggle
                        Button(action: {
                            sceneManager.toggleAutoTransition()
                        }) {
                            Image(systemName: sceneManager.isAutoTransitioning ? "timer" : "timer.square")
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.black.opacity(0.6))
                                .cornerRadius(16)
                        }
                        
                        // Settings button
                        Button(action: {
                            // Future: Show settings
                        }) {
                            Image(systemName: "gearshape.fill")
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.black.opacity(0.6))
                                .cornerRadius(16)
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 30)
                    
                    // Intensity controls
                    VStack(spacing: 16) {
                        // Scene intensity
                        HStack {
                            Image(systemName: "dial.min")
                                .foregroundColor(.white)
                            
                            Slider(value: $contentGenerator.sceneIntensity, in: 0...1)
                                .accentColor(.white)
                            
                            Image(systemName: "dial.max.fill")
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 40)
                        
                        // Motion level
                        HStack {
                            Image(systemName: "tortoise")
                                .foregroundColor(.white)
                            
                            Slider(value: $contentGenerator.motionLevel, in: 0...1)
                                .accentColor(.white)
                            
                            Image(systemName: "hare.fill")
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 40)
                    }
                    .padding(.bottom, 20)
                }
                .transition(.opacity)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.3)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
        .onAppear {
            startInitialScene()
        }
        .onDisappear {
            stopControlsTimer()
        }
    }
    
    // MARK: - Private Methods
    
    private func toggleControls() {
        withAnimation(.easeInOut(duration: 0.3)) {
            showControls.toggle()
        }
        
        if showControls {
            startControlsTimer()
        } else {
            stopControlsTimer()
        }
    }
    
    private func startControlsTimer() {
        stopControlsTimer()
        controlsTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { _ in
            withAnimation(.easeInOut(duration: 0.3)) {
                showControls = false
            }
        }
    }
    
    private func stopControlsTimer() {
        controlsTimer?.invalidate()
        controlsTimer = nil
    }
    
    private func startInitialScene() {
        // Start with ocean waves as the default calming scene
        contentGenerator.transitionToScene(.oceanWaves)
        sceneManager.startAutoTransition()
    }
}

/// CanineSceneManager: Manages scene transitions and preferences
public class CanineSceneManager: ObservableObject {
    @Published public var isAutoTransitioning: Bool = true
    @Published public var sceneDuration: TimeInterval = 300.0 // 5 minutes per scene
    @Published public var currentSceneIndex: Int = 0
    
    private var autoTransitionTimer: Timer?
    private let allScenes = ProceduralContentGenerator.CanineScene.allCases
    
    public init() {}
    
    public func startAutoTransition() {
        isAutoTransitioning = true
        scheduleNextTransition()
    }
    
    public func stopAutoTransition() {
        isAutoTransitioning = false
        autoTransitionTimer?.invalidate()
        autoTransitionTimer = nil
    }
    
    public func toggleAutoTransition() {
        if isAutoTransitioning {
            stopAutoTransition()
        } else {
            startAutoTransition()
        }
    }
    
    public func selectScene(_ scene: ProceduralContentGenerator.CanineScene) {
        if let index = allScenes.firstIndex(of: scene) {
            currentSceneIndex = index
        }
        
        // Restart auto-transition if enabled
        if isAutoTransitioning {
            scheduleNextTransition()
        }
    }
    
    private func scheduleNextTransition() {
        autoTransitionTimer?.invalidate()
        autoTransitionTimer = Timer.scheduledTimer(withTimeInterval: sceneDuration, repeats: false) { [weak self] _ in
            self?.transitionToNextScene()
        }
    }
    
    private func transitionToNextScene() {
        guard isAutoTransitioning else { return }
        
        currentSceneIndex = (currentSceneIndex + 1) % allScenes.count
        // Note: The actual scene transition will be handled by ProceduralContentGenerator
        
        scheduleNextTransition()
    }
    
    deinit {
        autoTransitionTimer?.invalidate()
    }
}

/// MetalRenderView: UIViewRepresentable wrapper for MTKView
struct MetalRenderView: UIViewRepresentable {
    let contentGenerator: ProceduralContentGenerator
    
    func makeUIView(context: Context) -> MTKView {
        let mtkView = MTKView()
        mtkView.device = MTLCreateSystemDefaultDevice()
        mtkView.delegate = context.coordinator
        mtkView.framebufferOnly = false
        mtkView.enableSetNeedsDisplay = false
        mtkView.isPaused = false
        mtkView.preferredFramesPerSecond = 60
        mtkView.colorPixelFormat = .bgra8Unorm
        
        // Configure for Apple TV
        mtkView.contentScaleFactor = UIScreen.main.scale
        
        return mtkView
    }
    
    func updateUIView(_ uiView: MTKView, context: Context) {
        // Updates are handled by the delegate
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MTKViewDelegate {
        let parent: MetalRenderView
        
        init(_ parent: MetalRenderView) {
            self.parent = parent
        }
        
        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
            // Handle size changes if needed
        }
        
        func draw(in view: MTKView) {
            guard let drawable = view.currentDrawable else { return }
            
            // Render procedural content
            parent.contentGenerator.renderFrame(to: drawable.texture)
            
            // Present the drawable
            if let commandBuffer = view.device?.makeCommandQueue()?.makeCommandBuffer() {
                commandBuffer.present(drawable)
                commandBuffer.commit()
            }
        }
    }
}

#if DEBUG
struct ProceduralContentView_Previews: PreviewProvider {
    static var previews: some View {
        ProceduralContentView()
            .previewDevice("Apple TV 4K")
    }
}
#endif