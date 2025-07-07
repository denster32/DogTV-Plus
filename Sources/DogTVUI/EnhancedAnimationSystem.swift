import SwiftUI
import DogTVCore

/// Enhanced animation system with natural physics and cinematic effects
public class EnhancedAnimationSystem: ObservableObject {
    
    // MARK: - Animation Presets
    
    /// Spring animations with natural physics
    public static let naturalSpring = Animation.spring(
        response: 0.3,
        dampingFraction: 0.6,
        blendDuration: 0.1
    )
    
    /// Bouncy spring for playful elements
    public static let bouncySpring = Animation.spring(
        response: 0.4,
        dampingFraction: 0.4,
        blendDuration: 0.1
    )
    
    /// Smooth ease for transitions
    public static let smoothEase = Animation.easeInOut(duration: 0.4)
    
    /// Quick snap for immediate feedback
    public static let quickSnap = Animation.easeOut(duration: 0.15)
    
    // MARK: - Parallax Effects
    
    /// Parallax depth levels
    public enum ParallaxDepth: Double, CaseIterable {
        case foreground = 1.2
        case middle = 1.0
        case background = 0.8
    }
    
    /// Creates a parallax effect modifier
    public struct ParallaxView: ViewModifier {
        let depth: ParallaxDepth
        let offset: CGSize
        
        public init(depth: ParallaxDepth, offset: CGSize = .zero) {
            self.depth = depth
            self.offset = offset
        }
        
        public func body(content: Content) -> some View {
            content
                .scaleEffect(depth.rawValue)
                .offset(offset)
                .animation(.easeInOut(duration: 0.3), value: offset)
        }
    }
    
    // MARK: - Staggered Animations
    
    /// Staggered animation modifier for sequential animations
    public struct StaggeredAnimation: ViewModifier {
        let delay: Double
        let animation: Animation
        
        public init(delay: Double = 0.1, animation: Animation = .easeInOut(duration: 0.3)) {
            self.delay = delay
            self.animation = animation
        }
        
        public func body(content: Content) -> some View {
            content
                .opacity(0)
                .scaleEffect(0.8)
                .onAppear {
                    withAnimation(animation.delay(delay)) {
                        // This will be handled by the parent view
                    }
                }
        }
    }
    
    // MARK: - Morphing Transitions
    
    /// Morphing transition between states
    public struct MorphingTransition: ViewModifier {
        let isActive: Bool
        let animation: Animation
        
        public init(isActive: Bool, animation: Animation = .easeInOut(duration: 0.5)) {
            self.isActive = isActive
            self.animation = animation
        }
        
        public func body(content: Content) -> some View {
            content
                .scaleEffect(isActive ? 1.0 : 0.9)
                .opacity(isActive ? 1.0 : 0.7)
                .blur(radius: isActive ? 0 : 2)
                .animation(animation, value: isActive)
        }
    }
    
    // MARK: - Wagging Tail Animation
    
    /// Wagging tail effect for playful elements
    public struct WaggingTailView: View {
        @State private var isWagging = false
        let content: AnyView
        
        public init<Content: View>(@ViewBuilder content: () -> Content) {
            self.content = AnyView(content())
        }
        
        public var body: some View {
            content
                .rotationEffect(.degrees(isWagging ? 5 : -5))
                .animation(
                    Animation.easeInOut(duration: 0.3)
                        .repeatForever(autoreverses: true),
                    value: isWagging
                )
                .onAppear {
                    isWagging = true
                }
        }
    }
    
    // MARK: - Heart Beat Animation
    
    /// Heart beat effect for favorites
    public struct HeartBeatView: View {
        @State private var isBeating = false
        let content: AnyView
        
        public init<Content: View>(@ViewBuilder content: () -> Content) {
            self.content = AnyView(content())
        }
        
        public var body: some View {
            content
                .scaleEffect(isBeating ? 1.1 : 1.0)
                .animation(
                    Animation.easeInOut(duration: 0.6)
                        .repeatForever(autoreverses: true),
                    value: isBeating
                )
                .onAppear {
                    isBeating = true
                }
        }
    }
    
    // MARK: - Paw Print Trail
    
    /// Paw print trail for navigation
    public struct PawPrintTrail: ViewModifier {
        @State private var showTrail = false
        
        public func body(content: Content) -> some View {
            content
                .overlay(
                    Group {
                        if showTrail {
                            HStack(spacing: 8) {
                                ForEach(0..<3, id: \.self) { index in
                                    Image(systemName: "pawprint.fill")
                                        .foregroundColor(.orange.opacity(0.6))
                                        .scaleEffect(0.8)
                                        .animation(
                                            .easeInOut(duration: 0.3)
                                                .delay(Double(index) * 0.1),
                                            value: showTrail
                                        )
                                }
                            }
                            .offset(x: 20, y: 10)
                        }
                    }
                )
                .onAppear {
                    showTrail = true
                }
        }
    }
    
    // MARK: - Scientific Badge
    
    /// Scientific badge for research-backed content
    public struct ScientificBadgeView: View {
        public var body: some View {
            HStack(spacing: 4) {
                Image(systemName: "flask.fill")
                    .foregroundColor(.blue)
                Text("Research-Backed")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }
}

// MARK: - View Extensions

extension View {
    /// Apply parallax effect
    public func parallax(depth: EnhancedAnimationSystem.ParallaxDepth, offset: CGSize = .zero) -> some View {
        modifier(EnhancedAnimationSystem.ParallaxView(depth: depth, offset: offset))
    }
    
    /// Apply staggered animation
    public func staggeredAnimation(delay: Double = 0.1, animation: Animation = .easeInOut(duration: 0.3)) -> some View {
        modifier(EnhancedAnimationSystem.StaggeredAnimation(delay: delay, animation: animation))
    }
    
    /// Apply morphing transition
    public func morphingTransition(isActive: Bool, animation: Animation = .easeInOut(duration: 0.5)) -> some View {
        modifier(EnhancedAnimationSystem.MorphingTransition(isActive: isActive, animation: animation))
    }
    
    /// Apply paw print trail
    public func pawPrintTrail() -> some View {
        modifier(EnhancedAnimationSystem.PawPrintTrail())
    }
    
    /// Make view wag like a tail
    public func waggingTail() -> some View {
        EnhancedAnimationSystem.WaggingTailView {
            self
        }
    }
    
    /// Make view beat like a heart
    public func heartBeat() -> some View {
        EnhancedAnimationSystem.HeartBeatView {
            self
        }
    }
} 