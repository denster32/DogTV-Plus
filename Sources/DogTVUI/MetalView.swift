// swiftlint:disable import_organization availability_attributes
import Foundation
import SwiftUI
import MetalKit
import DogTVCore
import DogTVVision
// swiftlint:enable import_organization

@available(iOS 13.0, *)
struct MetalView: UIViewRepresentable {
    @State private var renderer: MetalRenderer
    let sceneType: SceneType

    init(sceneType: SceneType) {
        self.sceneType = sceneType
        do {
            _renderer = State(initialValue: try MetalRenderer())
        } catch {
            fatalError("Failed to create Metal renderer: \(error)")
        }
    }

    @MainActor
    func makeUIView(context: Context) -> MTKView {
        let mtkView = MTKView()
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Could not create Metal device")
        }
        mtkView.device = device
        mtkView.delegate = context.coordinator
        mtkView.clearColor = MTLClearColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 1.0)
        mtkView.enableSetNeedsDisplay = true
        return mtkView
    }

    @MainActor
    func updateUIView(_ uiView: MTKView, context: Context) {
        context.coordinator.sceneType = sceneType
        uiView.setNeedsDisplay(uiView.bounds)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self, renderer: renderer)
    }

    class Coordinator: NSObject, MTKViewDelegate {
        var parent: MetalView
        var renderer: MetalRenderer
        var sceneType: SceneType

        init(_ parent: MetalView, renderer: MetalRenderer) {
            self.parent = parent
            self.renderer = renderer
            self.sceneType = parent.sceneType
            super.init()
        }

        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
            renderer.resize(size: size)
        }

        func draw(in view: MTKView) {
            renderer.render(sceneType: sceneType, in: view)
        }
    }
}
// swiftlint:enable availability_attributes
