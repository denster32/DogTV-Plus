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
            content.recommendedBreeds.contains(breed)
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
        // Generate recommendations based on popularity and user preferences
        recommendations = contentItems
            .filter { $0.isPopular }
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
                id: "relaxation_1",
                title: "Calming Forest Walk",
                description: "A peaceful walk through a serene forest with gentle sounds of nature",
                category: .relaxation,
                duration: 1800, // 30 minutes
                thumbnailURL: "forest_walk_thumb",
                videoURL: "forest_walk_video",
                tags: ["nature", "calming", "forest", "peaceful"],
                recommendedBreeds: [.goldenRetriever, .labrador, .borderCollie],
                isPopular: true,
                rating: 4.8
            ),
            VideoContent(
                id: "stimulation_1",
                title: "Playful Squirrels",
                description: "Exciting footage of playful squirrels in the park",
                category: .stimulation,
                duration: 900, // 15 minutes
                thumbnailURL: "squirrels_thumb",
                videoURL: "squirrels_video",
                tags: ["squirrels", "playful", "park", "exciting"],
                recommendedBreeds: [.jackRussell, .beagle, .australianShepherd],
                isPopular: true,
                rating: 4.6
            ),
            VideoContent(
                id: "training_1",
                title: "Basic Obedience Training",
                description: "Step-by-step guide to basic obedience commands",
                category: .training,
                duration: 1200, // 20 minutes
                thumbnailURL: "training_thumb",
                videoURL: "training_video",
                tags: ["training", "obedience", "commands", "education"],
                recommendedBreeds: [.germanShepherd, .borderCollie, .goldenRetriever],
                isPopular: false,
                rating: 4.9
            ),
            VideoContent(
                id: "relaxation_2",
                title: "Ocean Waves",
                description: "Soothing ocean waves with calming blue visuals",
                category: .relaxation,
                duration: 2400, // 40 minutes
                thumbnailURL: "ocean_thumb",
                videoURL: "ocean_video",
                tags: ["ocean", "waves", "blue", "soothing"],
                recommendedBreeds: [.greatDane, .berneseMountainDog, .newfoundland],
                isPopular: true,
                rating: 4.7
            ),
            VideoContent(
                id: "stimulation_2",
                title: "Bird Watching",
                description: "Colorful birds in their natural habitat",
                category: .stimulation,
                duration: 600, // 10 minutes
                thumbnailURL: "birds_thumb",
                videoURL: "birds_video",
                tags: ["birds", "colorful", "nature", "watching"],
                recommendedBreeds: [.cat, .terrier, .spaniel],
                isPopular: false,
                rating: 4.4
            )
        ]
    }
}

// MARK: - Data Models

public struct VideoContent: Identifiable, Codable, Equatable {
    public let id: String
    public let title: String
    public let description: String
    public let category: ContentCategory
    public let duration: Double // in seconds
    public let thumbnailURL: String
    public let videoURL: String
    public let tags: [String]
    public let recommendedBreeds: [DogBreed]
    public let isPopular: Bool
    public let rating: Double
    
    public init(id: String, title: String, description: String, category: ContentCategory, duration: Double, thumbnailURL: String, videoURL: String, tags: [String], recommendedBreeds: [DogBreed], isPopular: Bool, rating: Double) {
        self.id = id
        self.title = title
        self.description = description
        self.category = category
        self.duration = duration
        self.thumbnailURL = thumbnailURL
        self.videoURL = videoURL
        self.tags = tags
        self.recommendedBreeds = recommendedBreeds
        self.isPopular = isPopular
        self.rating = rating
    }
}

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