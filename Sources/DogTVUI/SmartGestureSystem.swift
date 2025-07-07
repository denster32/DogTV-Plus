import SwiftUI
import DogTVCore

/// Smart gesture system for advanced interaction recognition
public class SmartGestureSystem: ObservableObject {
    
    // MARK: - Swipe Gesture Recognizer
    
    /// Swipe gesture recognizer for quick navigation
    public struct SwipeGestureRecognizer: ViewModifier {
        let direction: SwipeDirection
        let action: () -> Void
        let threshold: CGFloat
        
        public enum SwipeDirection {
            case left, right, up, down
        }
        
        public init(
            direction: SwipeDirection,
            threshold: CGFloat = 50,
            action: @escaping () -> Void
        ) {
            self.direction = direction
            self.threshold = threshold
            self.action = action
        }
        
        public func body(content: Content) -> some View {
            content
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            let distance = value.translation
                            let velocity = value.velocity
                            
                            switch direction {
                            case .left:
                                if distance.width < -threshold && abs(velocity.width) > 500 {
                                    action()
                                }
                            case .right:
                                if distance.width > threshold && abs(velocity.width) > 500 {
                                    action()
                                }
                            case .up:
                                if distance.height < -threshold && abs(velocity.height) > 500 {
                                    action()
                                }
                            case .down:
                                if distance.height > threshold && abs(velocity.height) > 500 {
                                    action()
                                }
                            }
                        }
                )
        }
    }
    
    // MARK: - Pinch Zoom View
    
    /// Pinch to zoom functionality with constraints
    public struct PinchZoomView<Content: View>: View {
        @State private var scale: CGFloat = 1.0
        @State private var lastScale: CGFloat = 1.0
        @State private var offset: CGSize = .zero
        @State private var lastOffset: CGSize = .zero
        
        let content: Content
        let minScale: CGFloat
        let maxScale: CGFloat
        let onZoomChange: ((CGFloat) -> Void)?
        
        public init(
            minScale: CGFloat = 0.5,
            maxScale: CGFloat = 3.0,
            onZoomChange: ((CGFloat) -> Void)? = nil,
            @ViewBuilder content: () -> Content
        ) {
            self.minScale = minScale
            self.maxScale = maxScale
            self.onZoomChange = onZoomChange
            self.content = content()
        }
        
        public var body: some View {
            content
                .scaleEffect(scale)
                .offset(offset)
                .gesture(
                    SimultaneousGesture(
                        MagnificationGesture()
                            .onChanged { value in
                                let delta = value / lastScale
                                lastScale = value
                                
                                let newScale = scale * delta
                                scale = min(max(newScale, minScale), maxScale)
                                onZoomChange?(scale)
                            }
                            .onEnded { _ in
                                lastScale = 1.0
                            },
                        DragGesture()
                            .onChanged { value in
                                let delta = CGSize(
                                    width: value.translation.width - lastOffset.width,
                                    height: value.translation.height - lastOffset.height
                                )
                                lastOffset = value.translation
                                offset = CGSize(
                                    width: offset.width + delta.width,
                                    height: offset.height + delta.height
                                )
                            }
                            .onEnded { _ in
                                lastOffset = .zero
                            }
                    )
                )
                .onTapGesture(count: 2) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        if scale > 1.0 {
                            scale = 1.0
                            offset = .zero
                        } else {
                            scale = 2.0
                        }
                        onZoomChange?(scale)
                    }
                }
        }
    }
    
    // MARK: - Long Press Menu
    
    /// Long press context menu with options
    public struct LongPressMenu<Content: View>: View {
        let content: Content
        let menuItems: [MenuItem]
        let duration: Double
        
        public struct MenuItem {
            let title: String
            let icon: String
            let action: () -> Void
            let isDestructive: Bool
            
            public init(
                title: String,
                icon: String,
                isDestructive: Bool = false,
                action: @escaping () -> Void
            ) {
                self.title = title
                self.icon = icon
                self.isDestructive = isDestructive
                self.action = action
            }
        }
        
        public init(
            duration: Double = 0.5,
            menuItems: [MenuItem],
            @ViewBuilder content: () -> Content
        ) {
            self.duration = duration
            self.menuItems = menuItems
            self.content = content()
        }
        
        public var body: some View {
            content
                .contextMenu {
                    ForEach(menuItems.indices, id: \.self) { index in
                        let item = menuItems[index]
                        Button(action: item.action) {
                            Label(item.title, systemImage: item.icon)
                        }
                        .foregroundColor(item.isDestructive ? .red : .primary)
                    }
                }
        }
    }
    
    // MARK: - Adaptive Interface Manager
    
    /// Manages dynamic UI changes based on gesture patterns
    public class AdaptiveInterfaceManager: ObservableObject {
        @Published public var currentInteractionMode: InteractionMode = .normal
        @Published public var gestureHistory: [GestureType] = []
        
        public enum InteractionMode {
            case normal
            case quick
            case precise
            case accessibility
        }
        
        public enum GestureType {
            case tap
            case doubleTap
            case longPress
            case swipe
            case pinch
            case drag
        }
        
        public init() {}
        
        /// Record a gesture and adapt the interface
        public func recordGesture(_ gesture: GestureType) {
            gestureHistory.append(gesture)
            
            // Keep only last 10 gestures
            if gestureHistory.count > 10 {
                gestureHistory.removeFirst()
            }
            
            // Analyze gesture patterns and adapt
            adaptInterface()
        }
        
        /// Adapt interface based on gesture patterns
        private func adaptInterface() {
            let recentGestures = Array(gestureHistory.suffix(5))
            
            // Quick mode: rapid taps and swipes
            let quickGestures = recentGestures.filter { gesture in
                gesture == .tap || gesture == .swipe
            }
            
            if quickGestures.count >= 3 {
                currentInteractionMode = .quick
                return
            }
            
            // Precise mode: pinch and drag gestures
            let preciseGestures = recentGestures.filter { gesture in
                gesture == .pinch || gesture == .drag
            }
            
            if preciseGestures.count >= 2 {
                currentInteractionMode = .precise
                return
            }
            
            // Accessibility mode: long presses
            let accessibilityGestures = recentGestures.filter { gesture in
                gesture == .longPress
            }
            
            if accessibilityGestures.count >= 2 {
                currentInteractionMode = .accessibility
                return
            }
            
            // Default to normal mode
            currentInteractionMode = .normal
        }
        
        /// Get appropriate animation for current mode
        public func getAnimationForMode() -> Animation {
            switch currentInteractionMode {
            case .normal:
                return .easeInOut(duration: 0.3)
            case .quick:
                return .easeOut(duration: 0.15)
            case .precise:
                return .easeInOut(duration: 0.5)
            case .accessibility:
                return .easeInOut(duration: 0.8)
            }
        }
        
        /// Get appropriate haptic feedback for current mode
        public func getHapticForMode() {
            switch currentInteractionMode {
            case .normal:
                hapticManager.lightImpact()
            case .quick:
                hapticManager.mediumImpact()
            case .precise:
                hapticManager.softImpact()
            case .accessibility:
                hapticManager.heavyImpact()
            }
        }
    }
    
    // MARK: - Multi-Touch Recognition
    
    /// Multi-touch gesture recognizer
    public struct MultiTouchRecognizer: ViewModifier {
        let onTouchCountChanged: ((Int) -> Void)?
        let onMultiTouchGesture: ((MultiTouchGesture) -> Void)?
        
        public enum MultiTouchGesture {
            case twoFingerTap
            case threeFingerTap
            case twoFingerSwipe(direction: SwipeDirection)
            case threeFingerSwipe(direction: SwipeDirection)
        }
        
        public enum SwipeDirection {
            case left, right, up, down
        }
        
        public init(
            onTouchCountChanged: ((Int) -> Void)? = nil,
            onMultiTouchGesture: ((MultiTouchGesture) -> Void)? = nil
        ) {
            self.onTouchCountChanged = onTouchCountChanged
            self.onMultiTouchGesture = onMultiTouchGesture
        }
        
        public func body(content: Content) -> some View {
            content
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            // This is a simplified implementation
                            // In a real app, you'd use UIKit gesture recognizers
                            // for proper multi-touch support
                        }
                )
        }
    }
    
    // MARK: - Gesture Feedback
    
    /// Provides feedback for gesture recognition
    public struct GestureFeedback: ViewModifier {
        let gestureType: String
        let feedback: FeedbackType
        
        public enum FeedbackType {
            case haptic
            case sound
            case visual
            case all
        }
        
        public init(gestureType: String, feedback: FeedbackType = .all) {
            self.gestureType = gestureType
            self.feedback = feedback
        }
        
        public func body(content: Content) -> some View {
            content
                .onTapGesture {
                    provideFeedback()
                }
        }
        
        private func provideFeedback() {
            switch feedback {
            case .haptic:
                hapticManager.lightImpact()
            case .sound:
                soundEffectPlayer.playTapSound()
            case .visual:
                // Visual feedback is handled by the gesture itself
                break
            case .all:
                hapticManager.lightImpact()
                soundEffectPlayer.playTapSound()
            }
        }
    }
}

// MARK: - View Extensions

extension View {
    /// Apply swipe gesture recognition
    public func swipeGesture(
        direction: SmartGestureSystem.SwipeGestureRecognizer.SwipeDirection,
        threshold: CGFloat = 50,
        action: @escaping () -> Void
    ) -> some View {
        modifier(SmartGestureSystem.SwipeGestureRecognizer(
            direction: direction,
            threshold: threshold,
            action: action
        ))
    }
    
    /// Apply pinch zoom functionality
    public func pinchZoom(
        minScale: CGFloat = 0.5,
        maxScale: CGFloat = 3.0,
        onZoomChange: ((CGFloat) -> Void)? = nil
    ) -> some View {
        SmartGestureSystem.PinchZoomView(
            minScale: minScale,
            maxScale: maxScale,
            onZoomChange: onZoomChange
        ) {
            self
        }
    }
    
    /// Apply long press menu
    public func longPressMenu(
        duration: Double = 0.5,
        menuItems: [SmartGestureSystem.LongPressMenu<AnyView>.MenuItem]
    ) -> some View {
        SmartGestureSystem.LongPressMenu(
            duration: duration,
            menuItems: menuItems
        ) {
            self
        }
    }
    
    /// Apply multi-touch recognition
    public func multiTouchRecognizer(
        onTouchCountChanged: ((Int) -> Void)? = nil,
        onMultiTouchGesture: ((SmartGestureSystem.MultiTouchRecognizer.MultiTouchGesture) -> Void)? = nil
    ) -> some View {
        modifier(SmartGestureSystem.MultiTouchRecognizer(
            onTouchCountChanged: onTouchCountChanged,
            onMultiTouchGesture: onMultiTouchGesture
        ))
    }
    
    /// Apply gesture feedback
    public func gestureFeedback(
        gestureType: String,
        feedback: SmartGestureSystem.GestureFeedback.FeedbackType = .all
    ) -> some View {
        modifier(SmartGestureSystem.GestureFeedback(
            gestureType: gestureType,
            feedback: feedback
        ))
    }
}

// MARK: - Global Instance

/// Global adaptive interface manager instance
public let adaptiveInterfaceManager = SmartGestureSystem.AdaptiveInterfaceManager() 