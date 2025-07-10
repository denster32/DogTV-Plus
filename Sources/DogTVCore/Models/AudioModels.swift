import Foundation

// MARK: - FrequencyRange
public enum FrequencyRange: String, Codable, Sendable, CaseIterable, Identifiable {
    case low = "low"
    case mid = "mid"
    case high = "high"
    case ultraHigh = "ultra-high"

    public var id: String { self.rawValue }

    public var hertzRange: ClosedRange<Double> {
        switch self {
        case .low:
            return 0...10_000
        case .mid:
            return 10_001...20_000
        case .high:
            return 20_001...45_000
        case .ultraHigh:
            return 45_001...65_000
        }
    }
}

// MARK: - EqualizerSettings
public struct EqualizerSettings: Codable, Sendable, Hashable {
    public var lowGain: Float
    public var midGain: Float
    public var highGain: Float

    public static let `default` = EqualizerSettings()

    public init(lowGain: Float, midGain: Float, highGain: Float) {
        self.lowGain = lowGain
        self.midGain = midGain
        self.highGain = highGain
    }

    public init() {
        self.lowGain = 0.0
        self.midGain = 0.0
        self.highGain = 0.0
    }

    public func validate() throws {
        let gainRange: ClosedRange<Float> = -12.0...12.0
        if !gainRange.contains(lowGain) {
            throw ValidationError.invalidValue("lowGain", "must be between \(gainRange.lowerBound) and \(gainRange.upperBound) dB")
        }
        if !gainRange.contains(midGain) {
            throw ValidationError.invalidValue("midGain", "must be between \(gainRange.lowerBound) and \(gainRange.upperBound) dB")
        }
        if !gainRange.contains(highGain) {
            throw ValidationError.invalidValue("highGain", "must be between \(gainRange.lowerBound) and \(gainRange.upperBound) dB")
        }
    }
}

// MARK: - AudioSettings
public struct AudioSettings: Codable, Sendable, Hashable {
    public var volume: Float
    public var isEnabled: Bool
    public var frequencyRange: FrequencyRange
    public var includeNatureSounds: Bool
    public var equalizerSettings: EqualizerSettings

    public static let `default` = AudioSettings()

    public init(volume: Float, isEnabled: Bool, frequencyRange: FrequencyRange, includeNatureSounds: Bool, equalizerSettings: EqualizerSettings) {
        self.volume = volume
        self.isEnabled = isEnabled
        self.frequencyRange = frequencyRange
        self.includeNatureSounds = includeNatureSounds
        self.equalizerSettings = equalizerSettings
    }

    public init() {
        self.volume = 0.8
        self.isEnabled = true
        self.frequencyRange = .high
        self.includeNatureSounds = true
        self.equalizerSettings = .default
    }

    public func validate() throws {
        if !(0.0...1.0).contains(volume) {
            throw ValidationError.invalidValue("volume", "must be between 0.0 and 1.0")
        }
        try equalizerSettings.validate()
    }
} 