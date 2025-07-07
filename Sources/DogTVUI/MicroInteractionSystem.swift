import SwiftUI
import DogTVCore
import UIKit

/// Micro-interaction system for engaging user feedback
public class MicroInteractionSystem: ObservableObject {
    
    // MARK: - Ripple Effect
    
    /// Ripple effect view with spreading animation
    public struct RippleEffectView: View {
        @State private var isAnimating = false
        let color: Color
        let duration: Double
        
        public init(color: Color = .blue, duration: Double = 0.5) {
            self.color = color
            self.duration = duration
        }
        
        public var body: some View {
            Circle()
                .fill(color.opacity(0.3))
                .scaleEffect(isAnimating ? 2.0 : 0.0)
                .opacity(isAnimating ? 0.0 : 1.0)
                .animation(
                    Animation.easeOut(duration: duration),
                    value: isAnimating
                )
                .onAppear {
                    isAnimating = true
                }
        }
    }
    
    /// Ripple effect modifier
    public struct RippleEffectModifier: ViewModifier {
        @State private var rippleLocation: CGPoint = .zero
        @State private var showRipple = false
        let color: Color
        let duration: Double
        
        public init(color: Color = .blue, duration: Double = 0.5) {
            self.color = color
            self.duration = duration
        }
        
        public func body(content: Content) -> some View {
            content
                .overlay(
                    ZStack {
                        if showRipple {
                            RippleEffectView(color: color, duration: duration)
                                .position(rippleLocation)
                        }
                    }
                )
                .onTapGesture { location in
                    rippleLocation = location
                    showRipple = true
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                        showRipple = false
                    }
                }
        }
    }
    
    // MARK: - Haptic Feedback
    
    /// Haptic feedback manager for tactile feedback
    public class HapticManager {
        private let lightImpact = UIImpactFeedbackGenerator(style: .light)
        private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
        private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
        private let softImpact = UIImpactFeedbackGenerator(style: .soft)
        private let rigidImpact = UIImpactFeedbackGenerator(style: .rigid)
        private let notificationFeedback = UINotificationFeedbackGenerator()
        private let selectionFeedback = UISelectionFeedbackGenerator()
        
        public init() {
            // Prepare generators for immediate use
            lightImpact.prepare()
            mediumImpact.prepare()
            heavyImpact.prepare()
            softImpact.prepare()
            rigidImpact.prepare()
            notificationFeedback.prepare()
            selectionFeedback.prepare()
        }
        
        /// Light impact feedback
        public func lightImpact() {
            lightImpact.impactOccurred()
        }
        
        /// Medium impact feedback
        public func mediumImpact() {
            mediumImpact.impactOccurred()
        }
        
        /// Heavy impact feedback
        public func heavyImpact() {
            heavyImpact.impactOccurred()
        }
        
        /// Soft impact feedback
        public func softImpact() {
            softImpact.impactOccurred()
        }
        
        /// Rigid impact feedback
        public func rigidImpact() {
            rigidImpact.impactOccurred()
        }
        
        /// Success notification feedback
        public func successNotification() {
            notificationFeedback.notificationOccurred(.success)
        }
        
        /// Warning notification feedback
        public func warningNotification() {
            notificationFeedback.notificationOccurred(.warning)
        }
        
        /// Error notification feedback
        public func errorNotification() {
            notificationFeedback.notificationOccurred(.error)
        }
        
        /// Selection feedback
        public func selectionChanged() {
            selectionFeedback.selectionChanged()
        }
    }
    
    // MARK: - Sound Effects
    
    /// Sound effect player for audio feedback
    public class SoundEffectPlayer: ObservableObject {
        private var audioPlayers: [String: AVAudioPlayer] = [:]
        
        public init() {}
        
        /// Play a sound effect
        public func playSound(_ soundName: String, volume: Float = 0.5) {
            guard let url = Bundle.main.url(forResource: soundName, withExtension: "wav") else {
                // Fallback to system sound
                AudioServicesPlaySystemSound(SystemSoundID(1104)) // Default system sound
                return
            }
            
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.volume = volume
                player.prepareToPlay()
                player.play()
                audioPlayers[soundName] = player
            } catch {
                print("Error playing sound: \(error)")
            }
        }
        
        /// Play tap sound
        public func playTapSound() {
            playSound("tap", volume: 0.3)
        }
        
        /// Play success sound
        public func playSuccessSound() {
            playSound("success", volume: 0.4)
        }
        
        /// Play error sound
        public func playErrorSound() {
            playSound("error", volume: 0.4)
        }
        
        /// Play selection sound
        public func playSelectionSound() {
            playSound("selection", volume: 0.3)
        }
    }
    
    // MARK: - Visual Feedback
    
    /// Visual feedback modifier for immediate color changes, scaling, and shadow effects
    public struct VisualFeedbackModifier: ViewModifier {
        @State private var isPressed = false
        let pressedColor: Color?
        let pressedScale: CGFloat
        let pressedShadow: Shadow?
        
        public struct Shadow {
            let color: Color
            let radius: CGFloat
            let x: CGFloat
            let y: CGFloat
        }
        
        public init(
            pressedColor: Color? = nil,
            pressedScale: CGFloat = 0.95,
            pressedShadow: Shadow? = nil
        ) {
            self.pressedColor = pressedColor
            self.pressedScale = pressedScale
            self.pressedShadow = pressedShadow
        }
        
        public func body(content: Content) -> some View {
            content
                .scaleEffect(isPressed ? pressedScale : 1.0)
                .background(
                    Group {
                        if let color = pressedColor {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(color)
                                .opacity(isPressed ? 0.1 : 0.0)
                        }
                    }
                )
                .shadow(
                    color: pressedShadow?.color ?? Color.clear,
                    radius: isPressed ? (pressedShadow?.radius ?? 0) : 0,
                    x: isPressed ? (pressedShadow?.x ?? 0) : 0,
                    y: isPressed ? (pressedShadow?.y ?? 0) : 0
                )
                .animation(.easeInOut(duration: 0.1), value: isPressed)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = true
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.easeInOut(duration: 0.1)) {
                            isPressed = false
                        }
                    }
                }
        }
    }
    
    // MARK: - Pulse Animation
    
    /// Pulse animation for attention-grabbing elements
    public struct PulseAnimation: ViewModifier {
        @State private var isPulsing = false
        let color: Color
        let duration: Double
        
        public init(color: Color = .blue, duration: Double = 1.0) {
            self.color = color
            self.duration = duration
        }
        
        public func body(content: Content) -> some View {
            content
                .overlay(
                    Circle()
                        .stroke(color, lineWidth: 2)
                        .scaleEffect(isPulsing ? 1.5 : 1.0)
                        .opacity(isPulsing ? 0.0 : 1.0)
                        .animation(
                            Animation.easeOut(duration: duration)
                                .repeatForever(autoreverses: false),
                            value: isPulsing
                        )
                )
                .onAppear {
                    isPulsing = true
                }
        }
    }
    
    // MARK: - Shake Animation
    
    /// Shake animation for error states
    public struct ShakeAnimation: ViewModifier {
        @State private var isShaking = false
        let intensity: CGFloat
        
        public init(intensity: CGFloat = 10) {
            self.intensity = intensity
        }
        
        public func body(content: Content) -> some View {
            content
                .offset(x: isShaking ? intensity : 0)
                .animation(
                    Animation.easeInOut(duration: 0.1)
                        .repeatCount(3, autoreverses: true),
                    value: isShaking
                )
                .onTapGesture {
                    isShaking = true
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        isShaking = false
                    }
                }
        }
    }
    
    // MARK: - Bounce Animation
    
    /// Bounce animation for successful actions
    public struct BounceAnimation: ViewModifier {
        @State private var isBouncing = false
        
        public func body(content: Content) -> some View {
            content
                .scaleEffect(isBouncing ? 1.1 : 1.0)
                .animation(
                    Animation.spring(response: 0.3, dampingFraction: 0.6)
                        .repeatCount(1, autoreverses: true),
                    value: isBouncing
                )
                .onTapGesture {
                    isBouncing = true
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        isBouncing = false
                    }
                }
        }
    }
}

// MARK: - View Extensions

extension View {
    /// Apply ripple effect
    public func rippleEffect(color: Color = .blue, duration: Double = 0.5) -> some View {
        modifier(MicroInteractionSystem.RippleEffectModifier(color: color, duration: duration))
    }
    
    /// Apply visual feedback
    public func visualFeedback(
        pressedColor: Color? = nil,
        pressedScale: CGFloat = 0.95,
        pressedShadow: MicroInteractionSystem.VisualFeedbackModifier.Shadow? = nil
    ) -> some View {
        modifier(MicroInteractionSystem.VisualFeedbackModifier(
            pressedColor: pressedColor,
            pressedScale: pressedScale,
            pressedShadow: pressedShadow
        ))
    }
    
    /// Apply pulse animation
    public func pulseAnimation(color: Color = .blue, duration: Double = 1.0) -> some View {
        modifier(MicroInteractionSystem.PulseAnimation(color: color, duration: duration))
    }
    
    /// Apply shake animation
    public func shakeAnimation(intensity: CGFloat = 10) -> some View {
        modifier(MicroInteractionSystem.ShakeAnimation(intensity: intensity))
    }
    
    /// Apply bounce animation
    public func bounceAnimation() -> some View {
        modifier(MicroInteractionSystem.BounceAnimation())
    }
}

// MARK: - Global Instances

/// Global haptic manager instance
public let hapticManager = MicroInteractionSystem.HapticManager()

/// Global sound effect player instance
public let soundEffectPlayer = MicroInteractionSystem.SoundEffectPlayer() 