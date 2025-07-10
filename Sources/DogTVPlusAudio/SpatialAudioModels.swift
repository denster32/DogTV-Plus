// swiftlint:disable import_organization mark_usage
import Foundation
import simd
// swiftlint:enable import_organization

// MARK: - Spatial Audio Models

/// Audio environment types for spatial audio
public enum AudioEnvironment: String, Codable, CaseIterable, Sendable {
    case forest = "forest"
    case ocean = "ocean"
    case mountains = "mountains"
    case indoor = "indoor"
    case outdoor = "outdoor"
    
    public var description: String {
        switch self {
        case .forest:
            return "Immersive forest environment with natural acoustics"
        case .ocean:
            return "Ocean environment with wave reverb and spatial depth"
        case .mountains:
            return "Mountain environment with echo and vast spatial feel"
        case .indoor:
            return "Indoor environment with controlled acoustics"
        case .outdoor:
            return "Open outdoor environment with minimal reverb"
        }
    }
}

/// Room size configuration for spatial audio
public enum RoomSize: String, Codable, CaseIterable, Sendable {
    case small = "small"
    case medium = "medium"
    case large = "large"
    case extraLarge = "extra_large"
    
    public var dimensions: SIMD3<Float> {
        switch self {
        case .small:
            return SIMD3<Float>(3, 2.5, 4)      // Small living room
        case .medium:
            return SIMD3<Float>(5, 3, 6)        // Medium living room
        case .large:
            return SIMD3<Float>(8, 4, 10)       // Large living room
        case .extraLarge:
            return SIMD3<Float>(12, 5, 15)      // Open concept or theater room
        }
    }
}

/// Dog breed categories for audio optimization
public enum DogBreed: String, Codable, CaseIterable, Sendable {
    case small = "small"           // Chihuahua, Yorkshire Terrier
    case medium = "medium"         // Golden Retriever, Border Collie
    case large = "large"           // German Shepherd, Labrador
    case giant = "giant"           // Great Dane, Saint Bernard
    case shortEared = "short_eared" // Bulldog, Pug
    case longEared = "long_eared"   // Basset Hound, Bloodhound
    case pointedEared = "pointed_eared" // German Shepherd, Husky
    
    public var hearingCharacteristics: HearingCharacteristics {
        switch self {
        case .small:
            return HearingCharacteristics(
                frequencyRange: (50, 65000),
                sensitivity: 0.9,
                spatialAccuracy: 0.8
            )
        case .medium:
            return HearingCharacteristics(
                frequencyRange: (40, 60000),
                sensitivity: 0.85,
                spatialAccuracy: 0.85
            )
        case .large:
            return HearingCharacteristics(
                frequencyRange: (35, 55000),
                sensitivity: 0.8,
                spatialAccuracy: 0.9
            )
        case .giant:
            return HearingCharacteristics(
                frequencyRange: (30, 50000),
                sensitivity: 0.75,
                spatialAccuracy: 0.85
            )
        case .shortEared:
            return HearingCharacteristics(
                frequencyRange: (45, 55000),
                sensitivity: 0.7,
                spatialAccuracy: 0.7
            )
        case .longEared:
            return HearingCharacteristics(
                frequencyRange: (40, 60000),
                sensitivity: 0.9,
                spatialAccuracy: 0.6
            )
        case .pointedEared:
            return HearingCharacteristics(
                frequencyRange: (35, 65000),
                sensitivity: 0.95,
                spatialAccuracy: 0.95
            )
        }
    }
}

/// Dog age categories for hearing optimization
public enum DogAge: String, Codable, CaseIterable, Sendable {
    case puppy = "puppy"           // 0-1 years
    case young = "young"           // 1-3 years
    case adult = "adult"           // 3-7 years
    case senior = "senior"         // 7-10 years
    case elderly = "elderly"       // 10+ years
    
    public var hearingAdjustment: Float {
        switch self {
        case .puppy:
            return 1.1  // Enhanced sensitivity
        case .young:
            return 1.0  // Peak hearing
        case .adult:
            return 0.95 // Slight reduction
        case .senior:
            return 0.85 // Noticeable reduction
        case .elderly:
            return 0.7  // Significant reduction
        }
    }
}

/// Hearing characteristics for different dog types
public struct HearingCharacteristics: Codable, Sendable {
    public let frequencyRange: (Float, Float)  // Hz min/max
    public let sensitivity: Float              // 0.0 - 1.0
    public let spatialAccuracy: Float          // 0.0 - 1.0
    
    public init(frequencyRange: (Float, Float), sensitivity: Float, spatialAccuracy: Float) {
        self.frequencyRange = frequencyRange
        self.sensitivity = sensitivity
        self.spatialAccuracy = spatialAccuracy
    }
}

/// Spatial audio configuration
public struct SpatialConfiguration: Codable, Sendable {
    public let reverbLevel: Float
    public let obstruction: Float
    public let occlusion: Float
    public let highFrequencyGain: Float
    public let lowFrequencyGain: Float
    public let playbackRate: Float
    
    public static let `default` = SpatialConfiguration(
        reverbLevel: 0.3,
        obstruction: 0.0,
        occlusion: 0.0,
        highFrequencyGain: 0.0,
        lowFrequencyGain: 0.0,
        playbackRate: 1.0
    )
    
    public static func forRoom(size: RoomSize) -> SpatialConfiguration {
        switch size {
        case .small:
            return SpatialConfiguration(
                reverbLevel: 0.2,
                obstruction: 0.1,
                occlusion: 0.05,
                highFrequencyGain: -2.0,
                lowFrequencyGain: 1.0,
                playbackRate: 1.0
            )
        case .medium:
            return SpatialConfiguration(
                reverbLevel: 0.3,
                obstruction: 0.05,
                occlusion: 0.02,
                highFrequencyGain: 0.0,
                lowFrequencyGain: 0.0,
                playbackRate: 1.0
            )
        case .large:
            return SpatialConfiguration(
                reverbLevel: 0.4,
                obstruction: 0.02,
                occlusion: 0.01,
                highFrequencyGain: 1.0,
                lowFrequencyGain: -1.0,
                playbackRate: 1.0
            )
        case .extraLarge:
            return SpatialConfiguration(
                reverbLevel: 0.6,
                obstruction: 0.0,
                occlusion: 0.0,
                highFrequencyGain: 2.0,
                lowFrequencyGain: -2.0,
                playbackRate: 1.0
            )
        }
    }
    
    public init(reverbLevel: Float, obstruction: Float, occlusion: Float, highFrequencyGain: Float, lowFrequencyGain: Float, playbackRate: Float) {
        self.reverbLevel = reverbLevel
        self.obstruction = obstruction
        self.occlusion = occlusion
        self.highFrequencyGain = highFrequencyGain
        self.lowFrequencyGain = lowFrequencyGain
        self.playbackRate = playbackRate
    }
}

/// Canine audio optimization settings
public struct CanineOptimization: Codable, Sendable {
    public let breed: DogBreed
    public let age: DogAge
    public let frequencyEmphasis: FrequencyEmphasis
    public let spatialEnhancement: Bool
    public let environmentalAdaptation: Bool
    
    public static let `default` = CanineOptimization(
        breed: .medium,
        age: .adult,
        frequencyEmphasis: .balanced,
        spatialEnhancement: true,
        environmentalAdaptation: true
    )
    
    public static func forDog(breed: DogBreed, age: DogAge) -> CanineOptimization {
        return CanineOptimization(
            breed: breed,
            age: age,
            frequencyEmphasis: .canineOptimized,
            spatialEnhancement: true,
            environmentalAdaptation: true
        )
    }
    
    public init(breed: DogBreed, age: DogAge, frequencyEmphasis: FrequencyEmphasis, spatialEnhancement: Bool, environmentalAdaptation: Bool) {
        self.breed = breed
        self.age = age
        self.frequencyEmphasis = frequencyEmphasis
        self.spatialEnhancement = spatialEnhancement
        self.environmentalAdaptation = environmentalAdaptation
    }
}

/// Frequency emphasis options
public enum FrequencyEmphasis: String, Codable, CaseIterable, Sendable {
    case flat = "flat"
    case balanced = "balanced"
    case canineOptimized = "canine_optimized"
    case highFrequency = "high_frequency"
    case naturalSounds = "natural_sounds"
    
    public var description: String {
        switch self {
        case .flat:
            return "No frequency emphasis - natural audio"
        case .balanced:
            return "Gentle emphasis on mid frequencies"
        case .canineOptimized:
            return "Optimized for canine hearing (1-8kHz emphasis)"
        case .highFrequency:
            return "Enhanced high frequencies for alerts"
        case .naturalSounds:
            return "Emphasized natural environmental sounds"
        }
    }
}

/// Audio quality settings
public enum AudioQuality: String, Codable, CaseIterable, Sendable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case lossless = "lossless"
    
    public var sampleRate: Float {
        switch self {
        case .low: return 22050
        case .medium: return 44100
        case .high: return 48000
        case .lossless: return 96000
        }
    }
    
    public var bitDepth: Int {
        switch self {
        case .low: return 16
        case .medium: return 16
        case .high: return 24
        case .lossless: return 32
        }
    }
}

/// Real-time audio metrics
public struct AudioMetrics: Codable, Sendable {
    public let sampleRate: Double
    public let bitDepth: UInt32
    public let channels: Int
    public let latency: TimeInterval
    public let cpuUsage: Float
    public let memoryUsage: Float
    
    public static let `default` = AudioMetrics(
        sampleRate: 48000,
        bitDepth: 24,
        channels: 2,
        latency: 0.02,
        cpuUsage: 0.1,
        memoryUsage: 0.15
    )
    
    public init(sampleRate: Double, bitDepth: UInt32, channels: Int, latency: TimeInterval, cpuUsage: Float, memoryUsage: Float) {
        self.sampleRate = sampleRate
        self.bitDepth = bitDepth
        self.channels = channels
        self.latency = latency
        self.cpuUsage = cpuUsage
        self.memoryUsage = memoryUsage
    }
}

/// Spatial audio metrics
public struct SpatialMetrics: Codable, Sendable {
    public let activeSources: Int
    public let spatialAccuracy: Float
    public let environmentalComplexity: Float
    public let binauralProcessingLoad: Float
    public let listenerPosition: SIMD3<Float>
    
    public static let `default` = SpatialMetrics(
        activeSources: 0,
        spatialAccuracy: 0.9,
        environmentalComplexity: 0.5,
        binauralProcessingLoad: 0.2,
        listenerPosition: SIMD3<Float>(0, 0, 0)
    )
    
    public init(activeSources: Int, spatialAccuracy: Float, environmentalComplexity: Float, binauralProcessingLoad: Float, listenerPosition: SIMD3<Float>) {
        self.activeSources = activeSources
        self.spatialAccuracy = spatialAccuracy
        self.environmentalComplexity = environmentalComplexity
        self.binauralProcessingLoad = binauralProcessingLoad
        self.listenerPosition = listenerPosition
    }
}

/// Audio analytics for tracking usage patterns
public struct AudioAnalytics: Sendable {
    private var currentSession: AudioSession?
    
    public init() {}
    
    public mutating func startSession(scene: Scene, environment: AudioEnvironment) {
        currentSession = AudioSession(
            sessionID: UUID(),
            sceneID: scene.id,
            sceneName: scene.name,
            environment: environment,
            startTime: Date()
        )
    }
    
    public mutating func endSession() {
        guard var session = currentSession else { return }
        session.endTime = Date()
        session.duration = session.endTime?.timeIntervalSince(session.startTime) ?? 0
        
        // Analytics would be sent to tracking service here
        print("🎯 [AudioAnalytics] Session ended: \(session.duration)s")
        
        currentSession = nil
    }
    
    public func trackPositionChange(_ position: SIMD3<Float>) {
        guard let session = currentSession else { return }
        print("📍 [AudioAnalytics] Position changed: \(position) in session \(session.sessionID)")
    }
}

/// Audio session data for analytics
public struct AudioSession: Codable, Sendable {
    public let sessionID: UUID
    public let sceneID: UUID
    public let sceneName: String
    public let environment: AudioEnvironment
    public let startTime: Date
    public var endTime: Date?
    public var duration: TimeInterval = 0
    
    public init(sessionID: UUID, sceneID: UUID, sceneName: String, environment: AudioEnvironment, startTime: Date) {
        self.sessionID = sessionID
        self.sceneID = sceneID
        self.sceneName = sceneName
        self.environment = environment
        self.startTime = startTime
    }
}

// MARK: - Extensions

extension SIMD3<Float>: Codable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let x = try container.decode(Float.self)
        let y = try container.decode(Float.self)
        let z = try container.decode(Float.self)
        self.init(x, y, z)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(x)
        try container.encode(y)
        try container.encode(z)
    }
}
