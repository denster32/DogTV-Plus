import Foundation
import SwiftUI

/// Core business logic module for DogTV+
/// This module coordinates between all other modules and contains the main app functionality
public struct DogTVCore {
    
    /// Main app coordinator that manages the overall application state
    @available(macOS 10.15, *)
    public class AppCoordinator: ObservableObject {
        @Published public var currentView: AppView = .landing
        @Published public var isVisionModeEnabled: Bool = false
        @Published public var isAudioEnabled: Bool = true
        @Published public var currentContent: ContentItem?
        
        public init() {}
        
        /// Navigate to a specific view
        public func navigate(to view: AppView) {
            if #available(macOS 10.15, *) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    currentView = view
                }
            } else {
                currentView = view
            }
        }
        
        /// Toggle vision mode between human and dog vision
        public func toggleVisionMode() {
            if #available(macOS 10.15, *) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isVisionModeEnabled.toggle()
                }
            } else {
                isVisionModeEnabled.toggle()
            }
        }
        
        /// Toggle audio playback
        public func toggleAudio() {
            isAudioEnabled.toggle()
        }
    }
    
    /// Available app views
    public enum AppView: String, CaseIterable {
        case landing = "Landing"
        case content = "Content"
        case settings = "Settings"
        case analytics = "Analytics"
        case behavior = "Behavior"
        case privacy = "Privacy"
    }
    
    /// Content item model
    public struct ContentItem: Identifiable, Codable {
        public let id: UUID
        public let title: String
        public let description: String
        public let category: ContentCategory
        public let duration: TimeInterval
        public let isScientific: Bool
        public let tags: [String]
        
        public init(
            id: UUID = UUID(),
            title: String,
            description: String,
            category: ContentCategory,
            duration: TimeInterval,
            isScientific: Bool = false,
            tags: [String] = []
        ) {
            self.id = id
            self.title = title
            self.description = description
            self.category = category
            self.duration = duration
            self.isScientific = isScientific
            self.tags = tags
        }
    }
    
    /// Content categories
    public enum ContentCategory: String, CaseIterable, Codable {
        case relaxation = "Relaxation"
        case stimulation = "Stimulation"
        case training = "Training"
        case entertainment = "Entertainment"
        case scientific = "Scientific"
    }
    
    /// User preferences model
    public struct UserPreferences: Codable {
        public var breed: String?
        public var age: Int?
        public var behaviorSensitivity: BehaviorSensitivity
        public var audioPreferences: AudioPreferences
        public var visualPreferences: VisualPreferences
        
        public init(
            breed: String? = nil,
            age: Int? = nil,
            behaviorSensitivity: BehaviorSensitivity = .moderate,
            audioPreferences: AudioPreferences = AudioPreferences(),
            visualPreferences: VisualPreferences = VisualPreferences()
        ) {
            self.breed = breed
            self.age = age
            self.behaviorSensitivity = behaviorSensitivity
            self.audioPreferences = audioPreferences
            self.visualPreferences = visualPreferences
        }
    }
    
    /// Behavior sensitivity levels
    public enum BehaviorSensitivity: String, CaseIterable, Codable {
        case low = "Low"
        case moderate = "Moderate"
        case high = "High"
        case veryHigh = "Very High"
    }
    
    /// Audio preferences
    public struct AudioPreferences: Codable {
        public var volume: Double
        public var frequencyRange: FrequencyRange
        public var includeNatureSounds: Bool
        
        public init(
            volume: Double = 0.7,
            frequencyRange: FrequencyRange = .full,
            includeNatureSounds: Bool = true
        ) {
            self.volume = volume
            self.frequencyRange = frequencyRange
            self.includeNatureSounds = includeNatureSounds
        }
    }
    
    /// Frequency ranges for audio
    public enum FrequencyRange: String, CaseIterable, Codable {
        case low = "Low (0-2000 Hz)"
        case medium = "Medium (2000-8000 Hz)"
        case high = "High (8000-20000 Hz)"
        case full = "Full Range"
    }
    
    /// Visual preferences
    public struct VisualPreferences: Codable {
        public var brightness: Double
        public var contrast: Double
        public var motionSensitivity: MotionSensitivity
        public var colorEnhancement: Bool
        
        public init(
            brightness: Double = 0.8,
            contrast: Double = 0.6,
            motionSensitivity: MotionSensitivity = .moderate,
            colorEnhancement: Bool = true
        ) {
            self.brightness = brightness
            self.contrast = contrast
            self.motionSensitivity = motionSensitivity
            self.colorEnhancement = colorEnhancement
        }
    }
    
    /// Motion sensitivity levels
    public enum MotionSensitivity: String, CaseIterable, Codable {
        case low = "Low"
        case moderate = "Moderate"
        case high = "High"
    }
}

// MARK: - Extensions

@available(macOS 10.15, *)
extension DogTVCore.AppCoordinator {
    /// Load user preferences
    public func loadPreferences() -> DogTVCore.UserPreferences {
        // This would typically load from UserDefaults or secure storage
        return DogTVCore.UserPreferences()
    }
    
    /// Save user preferences
    public func savePreferences(_ preferences: DogTVCore.UserPreferences) {
        // This would typically save to UserDefaults or secure storage
    }
    
    /// Get recommended content based on preferences
    public func getRecommendedContent(for preferences: DogTVCore.UserPreferences) -> [DogTVCore.ContentItem] {
        // This would typically query the content database
        return []
    }
} 