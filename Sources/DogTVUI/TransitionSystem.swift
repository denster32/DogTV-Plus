import SwiftUI
import DogTVCore

/// Cinematic transition system for smooth page transitions and content loading
public class TransitionSystem: ObservableObject {
    
    // MARK: - Transition Types
    
    /// Available transition types
    public enum TransitionType: String, CaseIterable {
        case slide = "Slide"
        case fade = "Fade"
        case zoom = "Zoom"
        case morph = "Morph"
        case dissolve = "Dissolve"
        case flip = "Flip"
    }
    
    // MARK: - Transition Presets
    
    /// Slide transition from right
    public static let slideFromRight = AnyTransition.asymmetric(
        insertion: .move(edge: .trailing).combined(with: .opacity),
        removal: .move(edge: .leading).combined(with: .opacity)
    )
    
    /// Slide transition from left
    public static let slideFromLeft = AnyTransition.asymmetric(
        insertion: .move(edge: .leading).combined(with: .opacity),
        removal: .move(edge: .trailing).combined(with: .opacity)
    )
    
    /// Fade transition
    public static let fadeTransition = AnyTransition.opacity.combined(with: .scale(scale: 0.95))
    
    /// Zoom transition
    public static let zoomTransition = AnyTransition.scale(scale: 0.8).combined(with: .opacity)
    
    /// Morph transition
    public static let morphTransition = AnyTransition.asymmetric(
        insertion: .scale(scale: 0.9).combined(with: .opacity).combined(with: .blur(radius: 5)),
        removal: .scale(scale: 1.1).combined(with: .opacity).combined(with: .blur(radius: 5))
    )
    
    /// Dissolve transition
    public static let dissolveTransition = AnyTransition.opacity.combined(with: .blur(radius: 3))
    
    /// Flip transition
    public static let flipTransition = AnyTransition.asymmetric(
        insertion: .modifier(
            active: FlipModifier(angle: 90),
            identity: FlipModifier(angle: 0)
        ),
        removal: .modifier(
            active: FlipModifier(angle: -90),
            identity: FlipModifier(angle: 0)
        )
    )
    
    // MARK: - Skeleton Loading
    
    /// Skeleton view with shimmer effect
    public struct SkeletonView: View {
        @State private var isAnimating = false
        
        public init() {}
        
        public var body: some View {
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.gray.opacity(0.3),
                            Color.gray.opacity(0.1),
                            Color.gray.opacity(0.3)
                        ]),
                        startPoint: isAnimating ? .leading : .trailing,
                        endPoint: isAnimating ? .trailing : .leading
                    )
                )
                .onAppear {
                    withAnimation(
                        Animation.linear(duration: 1.5)
                            .repeatForever(autoreverses: false)
                    ) {
                        isAnimating = true
                    }
                }
        }
    }
    
    // MARK: - Focus Ring Animation
    
    /// Focus ring for Apple TV remote navigation
    public struct FocusRingView: ViewModifier {
        @State private var isFocused = false
        let color: Color
        
        public init(color: Color = .blue) {
            self.color = color
        }
        
        public func body(content: Content) -> some View {
            content
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color, lineWidth: isFocused ? 3 : 0)
                        .scaleEffect(isFocused ? 1.05 : 1.0)
                        .opacity(isFocused ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 0.2), value: isFocused)
                )
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isFocused = true
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isFocused = false
                        }
                    }
                }
        }
    }
    
    // MARK: - Vision Mode Transition
    
    /// Smooth transition between human and dog vision modes
    public struct VisionModeTransition: ViewModifier {
        let isDogVision: Bool
        let animation: Animation
        
        public init(isDogVision: Bool, animation: Animation = .easeInOut(duration: 0.5)) {
            self.isDogVision = isDogVision
            self.animation = animation
        }
        
        public func body(content: Content) -> some View {
            content
                .scaleEffect(isDogVision ? 1.1 : 1.0)
                .brightness(isDogVision ? 0.2 : 0.0)
                .contrast(isDogVision ? 1.3 : 1.0)
                .saturation(isDogVision ? 0.7 : 1.0)
                .animation(animation, value: isDogVision)
        }
    }
    
    // MARK: - Content Loading Animation
    
    /// Content loading animation with progressive disclosure
    public struct ContentLoadingView: View {
        @State private var isLoading = true
        let content: AnyView
        
        public init<Content: View>(@ViewBuilder content: () -> Content) {
            self.content = AnyView(content())
        }
        
        public var body: some View {
            ZStack {
                if isLoading {
                    VStack(spacing: 16) {
                        SkeletonView()
                            .frame(height: 200)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            SkeletonView()
                                .frame(height: 20)
                            SkeletonView()
                                .frame(height: 16)
                            SkeletonView()
                                .frame(width: 150, height: 16)
                        }
                    }
                    .padding()
                } else {
                    content
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        isLoading = false
                    }
                }
            }
        }
    }
    
    // MARK: - Page Transition Manager
    
    /// Manages page transitions with smooth animations
    public class PageTransitionManager: ObservableObject {
        @Published public var currentPage: Int = 0
        @Published public var isTransitioning = false
        
        public init() {}
        
        /// Navigate to a specific page with transition
        public func navigate(to page: Int, transition: TransitionType = .slide) {
            guard page != currentPage else { return }
            
            isTransitioning = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(self.animationFor(transition)) {
                    self.currentPage = page
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.isTransitioning = false
                }
            }
        }
        
        /// Get animation for transition type
        private func animationFor(_ transition: TransitionType) -> Animation {
            switch transition {
            case .slide:
                return .easeInOut(duration: 0.4)
            case .fade:
                return .easeInOut(duration: 0.3)
            case .zoom:
                return .spring(response: 0.4, dampingFraction: 0.8)
            case .morph:
                return .easeInOut(duration: 0.5)
            case .dissolve:
                return .easeInOut(duration: 0.4)
            case .flip:
                return .easeInOut(duration: 0.6)
            }
        }
    }
}

// MARK: - Flip Modifier

/// Custom modifier for flip transitions
public struct FlipModifier: ViewModifier {
    let angle: Double
    
    public func body(content: Content) -> some View {
        content
            .rotation3DEffect(
                .degrees(angle),
                axis: (x: 0, y: 1, z: 0)
            )
    }
}

// MARK: - View Extensions

extension View {
    /// Apply focus ring animation
    public func focusRing(color: Color = .blue) -> some View {
        modifier(TransitionSystem.FocusRingView(color: color))
    }
    
    /// Apply vision mode transition
    public func visionModeTransition(isDogVision: Bool, animation: Animation = .easeInOut(duration: 0.5)) -> some View {
        modifier(TransitionSystem.VisionModeTransition(isDogVision: isDogVision, animation: animation))
    }
    
    /// Wrap content in loading animation
    public func contentLoading<Content: View>(@ViewBuilder content: @escaping () -> Content) -> some View {
        TransitionSystem.ContentLoadingView {
            content()
        }
    }
    
    /// Apply skeleton loading
    public func skeletonLoading() -> some View {
        TransitionSystem.SkeletonView()
    }
} 