import Foundation
import SwiftUI
import Combine

/// A comprehensive content delivery system for DogTV+ with local and remote content support
public class ContentDeliverySystem: ObservableObject {
    @Published public var contentItems: [VideoContent] = []
    @Published public var categories: [ContentCategory] = []
    @Published public var isLoading: Bool = false
    @Published public var error: ContentError?
    @Published public var downloadedContent: [VideoContent] = []
    @Published public var recommendations: [VideoContent] = []
    
    private var cancellables = Set<AnyCancellable>()
    private let contentCache = NSCache<NSString, VideoContent>()
    
    public init() {
        loadLocalContent()
        setupContentObservers()
    }
    
    // MARK: - Public Methods
    
    /// Load content from local bundle or remote source
    public func loadContent() async throws {
        isLoading = true
        error = nil
        
        do {
            // Load local content first
            let localContent = try await loadLocalContentAsync()
            
            // Load remote content if available
            let remoteContent = try await loadRemoteContent()
            
            // Combine and sort content
            let allContent = localContent + remoteContent
            await MainActor.run {
                self.contentItems = allContent.sorted { $0.title < $1.title }
                self.isLoading = false
            }
            
            // Generate recommendations
            generateRecommendations()
            
        } catch {
            await MainActor.run {
                self.error = .loadingFailed(error.localizedDescription)
                self.isLoading = false
            }
        }
    }
    
    /// Download content for offline viewing
    public func downloadContent(_ content: VideoContent) async throws {
        guard !downloadedContent.contains(where: { $0.id == content.id }) else {
            return // Already downloaded
        }
        
        // Simulate download process
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        await MainActor.run {
            downloadedContent.append(content)
        }
        
        // Save to local storage
        try saveDownloadedContent()
    }
    
    /// Search content by title, category, or tags
    public func searchContent(query: String) -> [VideoContent] {
        guard !query.isEmpty else { return contentItems }
        
        return contentItems.filter { content in
            content.title.localizedCaseInsensitiveContains(query) ||
            content.category.rawValue.localizedCaseInsensitiveContains(query) ||
            content.tags.contains { $0.localizedCaseInsensitiveContains(query) }
        }
    }
    
    /// Get content by category
    public func getContentByCategory(_ category: ContentCategory) -> [VideoContent] {
        return contentItems.filter { $0.category == category }
    }
    
    /// Get recommendations based on dog breed
    public func getRecommendationsForBreed(_ breed: DogBreed) -> [VideoContent] {
        return recommendations.filter { content in
            content.metadata.breedCompatibility.contains(breed.rawValue)
        }
    }
    
    // MARK: - Private Methods
    
    private func loadLocalContent() {
        // Load sample content for initial deployment
        let sampleContent = createSampleContent()
        contentItems = sampleContent
        categories = ContentCategory.allCases
        generateRecommendations()
    }
    
    private func loadLocalContentAsync() async throws -> [VideoContent] {
        // In a real implementation, this would load from local bundle
        return createSampleContent()
    }
    
    private func loadRemoteContent() async throws -> [VideoContent] {
        // In a real implementation, this would fetch from API
        // For now, return empty array
        return []
    }
    
    private func setupContentObservers() {
        // Observe content changes for analytics
        $contentItems
            .sink { [weak self] items in
                self?.trackContentAnalytics(items)
            }
            .store(in: &cancellables)
    }
    
    private func generateRecommendations() {
        // Generate recommendations based on content metadata and user preferences
        recommendations = contentItems
            .filter { $0.metadata.energyLevel == .medium || $0.metadata.energyLevel == .low }
            .prefix(10)
            .map { $0 }
    }
    
    private func trackContentAnalytics(_ items: [VideoContent]) {
        // Track content loading analytics
        let analytics = ContentAnalytics(
            totalContent: items.count,
            categories: Set(items.map { $0.category }),
            averageDuration: items.map { $0.duration }.reduce(0, +) / Double(items.count)
        )
        
        // Send to analytics system
        print("Content Analytics: \(analytics)")
    }
    
    private func saveDownloadedContent() throws {
        // Save downloaded content to local storage
        let encoder = JSONEncoder()
        let data = try encoder.encode(downloadedContent)
        
        if let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsPath.appendingPathComponent("downloaded_content.json")
            try data.write(to: fileURL)
        }
    }
    
    private func createSampleContent() -> [VideoContent] {
        return [
            VideoContent(
                title: "Calming Forest Walk",
                description: "A peaceful walk through a serene forest with gentle sounds of nature",
                category: .relaxation,
                duration: 1800, // 30 minutes
                tags: ["nature", "calming", "forest", "peaceful"],
                metadata: ContentMetadata(
                    breedCompatibility: ["Golden Retriever", "Labrador", "Border Collie"],
                    ageRange: .all,
                    energyLevel: .low,
                    moodType: .calm,
                    timeOfDay: .anytime,
                    seasonality: .yearRound
                ),
                url: URL(string: "https://example.com/forest_walk_video")!,
                thumbnailURL: URL(string: "https://example.com/forest_walk_thumb")
            ),
            VideoContent(
                title: "Playful Squirrels",
                description: "Exciting footage of playful squirrels in the park",
                category: .stimulation,
                duration: 900, // 15 minutes
                tags: ["squirrels", "playful", "park", "exciting"],
                metadata: ContentMetadata(
                    breedCompatibility: ["Jack Russell", "Beagle", "Australian Shepherd"],
                    ageRange: .young,
                    energyLevel: .high,
                    moodType: .excited,
                    timeOfDay: .afternoon,
                    seasonality: .yearRound
                ),
                url: URL(string: "https://example.com/squirrels_video")!,
                thumbnailURL: URL(string: "https://example.com/squirrels_thumb")
            ),
            VideoContent(
                title: "Basic Obedience Training",
                description: "Step-by-step guide to basic obedience commands",
                category: .training,
                duration: 1200, // 20 minutes
                tags: ["training", "obedience", "commands", "education"],
                metadata: ContentMetadata(
                    breedCompatibility: ["German Shepherd", "Border Collie", "Golden Retriever"],
                    ageRange: .puppy,
                    energyLevel: .medium,
                    moodType: .neutral,
                    timeOfDay: .morning,
                    seasonality: .yearRound
                ),
                url: URL(string: "https://example.com/training_video")!,
                thumbnailURL: URL(string: "https://example.com/training_thumb")
            ),
            VideoContent(
                title: "Ocean Waves",
                description: "Soothing ocean waves with calming blue visuals",
                category: .relaxation,
                duration: 2400, // 40 minutes
                tags: ["ocean", "waves", "blue", "soothing"],
                metadata: ContentMetadata(
                    breedCompatibility: ["Great Dane", "Bernese Mountain Dog", "Newfoundland"],
                    ageRange: .senior,
                    energyLevel: .low,
                    moodType: .calm,
                    timeOfDay: .evening,
                    seasonality: .yearRound
                ),
                url: URL(string: "https://example.com/ocean_video")!,
                thumbnailURL: URL(string: "https://example.com/ocean_thumb")
            ),
            VideoContent(
                title: "Bird Watching",
                description: "Colorful birds in their natural habitat",
                category: .stimulation,
                duration: 600, // 10 minutes
                tags: ["birds", "colorful", "nature", "watching"],
                metadata: ContentMetadata(
                    breedCompatibility: ["Cat", "Terrier", "Spaniel"],
                    ageRange: .adult,
                    energyLevel: .medium,
                    moodType: .playful,
                    timeOfDay: .afternoon,
                    seasonality: .spring
                ),
                url: URL(string: "https://example.com/birds_video")!,
                thumbnailURL: URL(string: "https://example.com/birds_thumb")
            )
        ]
    }
}

// MARK: - Data Models

// Using VideoContent from ContentRecommendationSystem for consistency

public enum ContentCategory: String, CaseIterable, Codable {
    case relaxation = "Relaxation"
    case stimulation = "Stimulation"
    case training = "Training"
    case entertainment = "Entertainment"
    case education = "Education"
    
    var icon: String {
        switch self {
        case .relaxation: return "leaf.fill"
        case .stimulation: return "bolt.fill"
        case .training: return "graduationcap.fill"
        case .entertainment: return "play.fill"
        case .education: return "book.fill"
        }
    }
    
    var color: String {
        switch self {
        case .relaxation: return "green"
        case .stimulation: return "orange"
        case .training: return "blue"
        case .entertainment: return "purple"
        case .education: return "indigo"
        }
    }
}

public enum DogBreed: String, CaseIterable, Codable {
    case goldenRetriever = "Golden Retriever"
    case labrador = "Labrador"
    case germanShepherd = "German Shepherd"
    case borderCollie = "Border Collie"
    case jackRussell = "Jack Russell"
    case beagle = "Beagle"
    case australianShepherd = "Australian Shepherd"
    case greatDane = "Great Dane"
    case berneseMountainDog = "Bernese Mountain Dog"
    case newfoundland = "Newfoundland"
    case cat = "Cat"
    case terrier = "Terrier"
    case spaniel = "Spaniel"
}

public enum ContentError: Error, LocalizedError {
    case loadingFailed(String)
    case downloadFailed(String)
    case networkError(String)
    case storageError(String)
    
    public var errorDescription: String? {
        switch self {
        case .loadingFailed(let message):
            return "Failed to load content: \(message)"
        case .downloadFailed(let message):
            return "Failed to download content: \(message)"
        case .networkError(let message):
            return "Network error: \(message)"
        case .storageError(let message):
            return "Storage error: \(message)"
        }
    }
}

public struct ContentAnalytics {
    let totalContent: Int
    let categories: Set<ContentCategory>
    let averageDuration: Double
} 