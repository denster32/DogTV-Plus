import Foundation

// MARK: - FrequencyRange

/// Represents different frequency ranges tailored for canine hearing.
public enum FrequencyRange: String, Codable, Sendable, CaseIterable, Identifiable {
    case low = "low"         // 0-10 kHz
    case mid = "mid"         // 10-20 kHz
    case high = "high"       // 20-45 kHz
    case ultraHigh = "ultra-high" // 45-65 kHz

    public var id: String { self.rawValue }

    /// Returns the corresponding frequency range in Hertz.
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

/// Defines equalizer settings with bands for detailed audio customization.
public struct EqualizerSettings: Codable, Sendable, Hashable {
    /// Gain for low frequencies (e.g., bass). Value from -12.0 to 12.0 dB.
    public var lowGain: Float

    /// Gain for mid frequencies. Value from -12.0 to 12.0 dB.
    public var midGain: Float

    /// Gain for high frequencies (e.g., treble). Value from -12.0 to 12.0 dB.
    public var highGain: Float

    /// Default flat equalizer settings.
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

/// Encapsulates all audio-related settings for the application.
public struct AudioSettings: Codable, Sendable, Hashable {
    public var volume: Float
    public var isEnabled: Bool
    public var frequencyRange: FrequencyRange
    public var includeNatureSounds: Bool
    public var equalizerSettings: EqualizerSettings

    /// Default audio settings.
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
        // Defer equalizer validation to the EqualizerSettings struct itself
        try equalizerSettings.validate()
    }
}
