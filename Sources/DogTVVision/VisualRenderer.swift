import SwiftUI
import Metal
import MetalKit
import DogTVCore

/// Visual renderer for canine-optimized visual effects and rendering
public class VisualRenderer: ObservableObject {
    
    // MARK: - Metal Components
    
    private var device: MTLDevice
    private var commandQueue: MTLCommandQueue
    private var library: MTLLibrary
    
    // MARK: - Visual Settings
    
    @Published public var brightness: Float = 0.8
    @Published public var contrast: Float = 0.6
    @Published public var saturation: Float = 0.7
    @Published public var motionSensitivity: DogTVCore.MotionSensitivity = .moderate
    @Published public var colorEnhancement: Bool = true
    
    // MARK: - Canine Vision Parameters
    
    /// Canine vision parameters based on scientific research
    public struct CanineVisionParameters {
        /// Dogs see primarily in blue and yellow
        public static let primaryColors: [SIMD3<Float>] = [
            SIMD3<Float>(0.0, 0.0, 1.0),  // Blue
            SIMD3<Float>(1.0, 1.0, 0.0)   // Yellow
        ]
        
        /// Dogs have reduced color sensitivity compared to humans
        public static let colorSensitivity: Float = 0.3
        
        /// Dogs are more sensitive to motion
        public static let motionSensitivity: Float = 1.5
        
        /// Dogs have better night vision
        public static let nightVisionEnhancement: Float = 1.2
        
        /// Dogs see better in low light
        public static let lowLightEnhancement: Float = 1.3
    }
    
    // MARK: - Initialization
    
    public init() {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Metal is not supported on this device")
        }
        
        self.device = device
        self.commandQueue = device.makeCommandQueue()!
        
        // Load Metal shader library
        do {
            self.library = try device.makeDefaultLibrary()
        } catch {
            fatalError("Failed to load Metal shader library: \(error)")
        }
    }
    
    // MARK: - Visual Effects
    
    /// Apply canine vision filter to image
    public func applyCanineVisionFilter(to image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        
        let width = cgImage.width
        let height = cgImage.height
        let bytesPerRow = width * 4
        
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return nil }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        guard let data = context.data else { return nil }
        
        let buffer = data.bindMemory(to: UInt8.self, capacity: width * height * 4)
        
        // Apply canine vision processing
        processPixelsForCanineVision(buffer, width: width, height: height)
        
        guard let processedCGImage = context.makeImage() else { return nil }
        return UIImage(cgImage: processedCGImage)
    }
    
    /// Process pixels for canine vision
    private func processPixelsForCanineVision(_ buffer: UnsafeMutablePointer<UInt8>, width: Int, height: Int) {
        for y in 0..<height {
            for x in 0..<width {
                let index = (y * width + x) * 4
                
                let r = Float(buffer[index]) / 255.0
                let g = Float(buffer[index + 1]) / 255.0
                let b = Float(buffer[index + 2]) / 255.0
                
                // Convert to canine vision (blue-yellow dichromacy)
                let canineR = r * 0.3 + g * 0.7
                let canineG = r * 0.3 + g * 0.7
                let canineB = b * 1.0
                
                // Apply brightness and contrast
                let adjustedR = (canineR - 0.5) * contrast + 0.5 + brightness
                let adjustedG = (canineG - 0.5) * contrast + 0.5 + brightness
                let adjustedB = (canineB - 0.5) * contrast + 0.5 + brightness
                
                // Clamp values
                buffer[index] = UInt8(max(0, min(255, adjustedR * 255)))
                buffer[index + 1] = UInt8(max(0, min(255, adjustedG * 255)))
                buffer[index + 2] = UInt8(max(0, min(255, adjustedB * 255)))
            }
        }
    }
    
    // MARK: - Motion Enhancement
    
    /// Enhance motion for canine vision
    public func enhanceMotion(in view: UIView) {
        // Apply motion enhancement based on sensitivity level
        let enhancementFactor: Float
        
        switch motionSensitivity {
        case .low:
            enhancementFactor = 1.0
        case .moderate:
            enhancementFactor = 1.2
        case .high:
            enhancementFactor = 1.5
        }
        
        // Apply motion enhancement using Core Animation
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.duration = 0.1
        animation.fromValue = 1.0
        animation.toValue = 1.0 + (enhancementFactor - 1.0) * 0.1
        animation.autoreverses = true
        animation.repeatCount = 1
        
        view.layer.add(animation, forKey: "motionEnhancement")
    }
    
    // MARK: - Color Enhancement
    
    /// Enhance colors for canine vision
    public func enhanceColors(for view: UIView) {
        guard colorEnhancement else { return }
        
        // Apply color enhancement filter
        let filter = CIFilter(name: "CIColorControls")
        filter?.setValue(1.2, forKey: "inputSaturation") // Increase saturation
        filter?.setValue(1.1, forKey: "inputContrast")    // Increase contrast
        filter?.setValue(0.1, forKey: "inputBrightness")  // Slight brightness increase
        
        // Apply filter to view
        if let filter = filter {
            view.layer.filters = [filter]
        }
    }
    
    // MARK: - Night Vision Mode
    
    /// Enable night vision mode for better low-light visibility
    public func enableNightVision(for view: UIView) {
        // Apply night vision enhancement
        let filter = CIFilter(name: "CIColorControls")
        filter?.setValue(1.5, forKey: "inputBrightness")  // Increase brightness
        filter?.setValue(1.3, forKey: "inputContrast")    // Increase contrast
        filter?.setValue(0.8, forKey: "inputSaturation")  // Reduce saturation for night vision
        
        // Apply blue tint for night vision effect
        let colorMatrix = CIFilter(name: "CIColorMatrix")
        colorMatrix?.setValue(CIVector(x: 0.3, y: 0.3, z: 1.0, w: 0), forKey: "inputRVector")
        colorMatrix?.setValue(CIVector(x: 0.3, y: 0.3, z: 1.0, w: 0), forKey: "inputGVector")
        colorMatrix?.setValue(CIVector(x: 0.3, y: 0.3, z: 1.0, w: 0), forKey: "inputBVector")
        
        if let filter = filter, let colorMatrix = colorMatrix {
            view.layer.filters = [filter, colorMatrix]
        }
    }
    
    // MARK: - Focus Enhancement
    
    /// Enhance focus for canine attention
    public func enhanceFocus(for view: UIView) {
        // Apply focus enhancement using blur and sharpening
        let blurFilter = CIFilter(name: "CIGaussianBlur")
        blurFilter?.setValue(2.0, forKey: "inputRadius")
        
        let sharpenFilter = CIFilter(name: "CISharpenLuminance")
        sharpenFilter?.setValue(0.5, forKey: "inputSharpness")
        
        if let blurFilter = blurFilter, let sharpenFilter = sharpenFilter {
            view.layer.filters = [blurFilter, sharpenFilter]
        }
    }
    
    // MARK: - Visual Feedback
    
    /// Provide visual feedback for interactions
    public func provideVisualFeedback(for view: UIView, type: VisualFeedbackType) {
        switch type {
        case .attention:
            // Flash effect to grab attention
            let flashAnimation = CABasicAnimation(keyPath: "opacity")
            flashAnimation.duration = 0.2
            flashAnimation.fromValue = 1.0
            flashAnimation.toValue = 0.3
            flashAnimation.autoreverses = true
            flashAnimation.repeatCount = 2
            view.layer.add(flashAnimation, forKey: "attentionFlash")
            
        case .success:
            // Green glow effect
            let glowAnimation = CABasicAnimation(keyPath: "shadowOpacity")
            glowAnimation.duration = 0.5
            glowAnimation.fromValue = 0.0
            glowAnimation.toValue = 0.8
            glowAnimation.autoreverses = true
            view.layer.shadowColor = UIColor.green.cgColor
            view.layer.shadowRadius = 10.0
            view.layer.add(glowAnimation, forKey: "successGlow")
            
        case .warning:
            // Yellow pulse effect
            let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
            pulseAnimation.duration = 0.3
            pulseAnimation.fromValue = 1.0
            pulseAnimation.toValue = 1.1
            pulseAnimation.autoreverses = true
            pulseAnimation.repeatCount = 3
            view.layer.add(pulseAnimation, forKey: "warningPulse")
        }
    }
    
    // MARK: - Visual Calibration
    
    /// Calibrate visual settings for specific dog breed
    public func calibrateForBreed(_ breed: String) {
        // Adjust visual parameters based on breed characteristics
        switch breed.lowercased() {
        case "retriever", "labrador":
            // Retrievers have good vision, standard settings
            brightness = 0.8
            contrast = 0.6
            saturation = 0.7
            
        case "border collie", "australian shepherd":
            // Herding dogs have excellent vision, enhance details
            brightness = 0.9
            contrast = 0.8
            saturation = 0.8
            motionSensitivity = .high
            
        case "bulldog", "pug":
            // Brachycephalic breeds may have vision issues, enhance brightness
            brightness = 1.0
            contrast = 0.7
            saturation = 0.6
            
        case "german shepherd", "malinois":
            // Working dogs, enhance motion detection
            brightness = 0.8
            contrast = 0.7
            saturation = 0.7
            motionSensitivity = .high
            
        default:
            // Default settings for unknown breeds
            brightness = 0.8
            contrast = 0.6
            saturation = 0.7
        }
    }
    
    // MARK: - Performance Optimization
    
    /// Optimize rendering performance
    public func optimizePerformance() {
        // Enable Metal performance optimizations
        device.setMaxCommandBufferCount(3)
        
        // Configure command queue for optimal performance
        commandQueue.setLabel("DogTVVisualRenderer")
    }
}

// MARK: - Visual Feedback Types

/// Types of visual feedback for canine interactions
public enum VisualFeedbackType {
    case attention    // Flash effect to grab attention
    case success      // Green glow for successful actions
    case warning      // Yellow pulse for warnings
}

// MARK: - Visual Utilities

/// Visual utility functions for canine optimization
public struct VisualUtilities {
    
    /// Generate attention-grabbing visual pattern
    public static func generateAttentionPattern() -> [CGRect] {
        // Generate geometric patterns that attract canine attention
        return [
            CGRect(x: 0, y: 0, width: 100, height: 100),
            CGRect(x: 150, y: 0, width: 100, height: 100),
            CGRect(x: 300, y: 0, width: 100, height: 100)
        ]
    }
    
    /// Create motion trail effect
    public static func createMotionTrail(for view: UIView, duration: TimeInterval) {
        let trailLayer = CALayer()
        trailLayer.frame = view.bounds
        trailLayer.backgroundColor = view.backgroundColor?.cgColor
        trailLayer.opacity = 0.5
        
        view.layer.addSublayer(trailLayer)
        
        let fadeAnimation = CABasicAnimation(keyPath: "opacity")
        fadeAnimation.duration = duration
        fadeAnimation.fromValue = 0.5
        fadeAnimation.toValue = 0.0
        fadeAnimation.fillMode = .forwards
        fadeAnimation.isRemovedOnCompletion = true
        
        trailLayer.add(fadeAnimation, forKey: "fadeOut")
    }
    
    /// Apply depth of field effect
    public static func applyDepthOfField(to view: UIView, focusPoint: CGPoint) {
        let blurFilter = CIFilter(name: "CIGaussianBlur")
        blurFilter?.setValue(5.0, forKey: "inputRadius")
        
        if let blurFilter = blurFilter {
            view.layer.filters = [blurFilter]
        }
    }
}

// MARK: - Metal Shader Support

/// Metal shader support for advanced visual effects
public struct MetalShaderSupport {
    
    /// Compile Metal shader for visual effects
    public static func compileShader(named name: String, device: MTLDevice) -> MTLFunction? {
        do {
            let library = try device.makeDefaultLibrary()
            return library.makeFunction(name: name)
        } catch {
            print("Failed to compile shader \(name): \(error)")
            return nil
        }
    }
    
    /// Create render pipeline for visual effects
    public static func createRenderPipeline(device: MTLDevice, vertexFunction: MTLFunction, fragmentFunction: MTLFunction) -> MTLRenderPipelineState? {
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        do {
            return try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            print("Failed to create render pipeline: \(error)")
            return nil
        }
    }
} 