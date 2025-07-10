// swiftlint:disable import_organization mark_usage
import Foundation
// swiftlint:enable import_organization

// MARK: - SceneType Enum

/// Represents the different types of scenes available in the application.
public enum SceneType: String, Codable, Sendable, CaseIterable, Identifiable {
    case ocean
    case forest
    case fireflies
    case rain
    case sunset
    case stars

    public var id: String { self.rawValue }
}

// MARK: - SceneMetadata Struct

/// Holds metadata associated with a scene.
public struct SceneMetadata: Codable, Sendable, Hashable {
    /// The author or creator of the scene.
    public let author: String

    /// The date the scene was created or published.
    public let creationDate: Date

    /// A URL for a high-resolution version of the visual assets.
    public let highResVisualsURL: URL?

    /// A URL for the high-quality audio file.
    public let highQualityAudioURL: URL?

    public init(author: String, creationDate: Date, highResVisualsURL: URL? = nil, highQualityAudioURL: URL? = nil) {
        self.author = author
        self.creationDate = creationDate
        self.highResVisualsURL = highResVisualsURL
        self.highQualityAudioURL = highQualityAudioURL
    }
}

// MARK: - Scene Struct

/// Represents a single visual and auditory experience in the app.
public struct Scene: Identifiable, Codable, Sendable, Hashable {
    public let id: UUID
    public let name: String
    public let type: SceneType
    public let description: String
    public let duration: TimeInterval
    public let isActive: Bool
    public let metadata: SceneMetadata

    public init(name: String, type: SceneType, description: String, duration: TimeInterval, isActive: Bool, metadata: SceneMetadata, id: UUID = UUID()) throws {
        self.id = id
        self.name = name
        self.type = type
        self.description = description
        self.duration = duration
        self.isActive = isActive
        self.metadata = metadata

        try self.validate()
    }

    /// Validates the scene's properties to ensure they meet requirements.
    /// - Throws: `ValidationError` if any validation rule fails.
    public func validate() throws {
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw ValidationError.emptyOrWhitespace("name")
        }
        if description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw ValidationError.emptyOrWhitespace("description")
        }
        if duration <= 0 {
            throw ValidationError.invalidValue("duration", "must be positive")
        }
    }

    /// Custom coding keys to handle any potential future remapping.
    enum CodingKeys: String, CodingKey {
        case id, name, type, description, duration, isActive, metadata
    }
}

extension Scene {
    public static let example: Scene = try! Scene(
        name: "Sample Scene",
        type: .ocean,
        description: "A sample scene for preview.",
        duration: 300,
        isActive: true,
        metadata: SceneMetadata(author: "Preview", creationDate: Date()),
        id: UUID()
    )
}

// MARK: - Validation Error

/// An enumeration for validation errors.
public enum ValidationError: Error, LocalizedError, Equatable {
    case emptyOrWhitespace(String)
    case invalidValue(String, String)

    public var errorDescription: String? {
        switch self {
        case .emptyOrWhitespace(let field):
            return "Validation Error: The field '\(field)' cannot be empty or contain only whitespace."
        case .invalidValue(let (field, reason)):
            return "Validation Error: The field '\(field)' has an invalid value. Reason: \(reason)."
        }
    }
}
// swiftlint:enable mark_usage
