import Foundation
import Network
import Combine
import SwiftUI

/// A comprehensive network manager for DogTV+ with API communication and offline support
@available(macOS 10.15, *)
public class NetworkManager: ObservableObject {
    @Published public var isConnected: Bool = false
    @Published public var isReachable: Bool = false
    @Published public var connectionType: AdvancedNetworkingSystem.ConnectionType = .unknown
    @Published public var networkQuality: NetworkQuality = .unknown
    @Published public var error: NetworkError?
    
    private var cancellables = Set<AnyCancellable>()
    private let monitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "NetworkMonitor")
    private let session: URLSession
    private let cache = URLCache.shared
    
    // API Configuration
    private let baseURL = "https://api.dogtv-plus.com" // Replace with actual API URL
    private let apiKey = "your-api-key" // Replace with actual API key
    
    public init() {
        // Configure URLSession
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 300
        config.requestCachePolicy = .returnCacheDataElseLoad
        config.urlCache = cache
        
        session = URLSession(configuration: config)
        
        setupNetworkMonitoring()
    }
    
    deinit {
        monitor.cancel()
    }
    
    // MARK: - Public Methods
    
    /// Fetch scene configurations from API
    @available(macOS 10.15, *)
    public func fetchSceneConfigurations() async throws -> [SceneConfiguration] {
        let endpoint = APIEndpoint.content
        let request = try createRequest(for: endpoint)
        
        return try await performRequest(request)
    }
    
    /// Upload analytics data
    @available(macOS 10.15, *)
    public func uploadAnalytics(_ data: AnalyticsData) async throws {
        let endpoint = APIEndpoint.analytics
        var request = try createRequest(for: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(data)
        
        try await performRequest(request)
    }
    
    /// Download scene configuration for offline use
    @available(macOS 10.15, *)
    public func downloadSceneConfiguration(_ config: SceneConfiguration) async throws -> URL {
        let encoder = JSONEncoder()
        let data = try encoder.encode(config)
        
        // Save to local storage
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = "\(config.id).json"
        let fileURL = documentsPath.appendingPathComponent(fileName)
        
        try data.write(to: fileURL)
        return fileURL
    }
    
    /// Sync user data with server
    @available(macOS 10.15, *)
    public func syncUserData(_ userData: UserData) async throws {
        let endpoint = APIEndpoint.sync
        var request = try createRequest(for: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(userData)
        
        try await performRequest(request)
    }
    
    /// Check for content updates
    @available(macOS 10.15, *)
    public func checkForUpdates() async throws -> UpdateInfo {
        let endpoint = APIEndpoint.updates
        let request = try createRequest(for: endpoint)
        
        return try await performRequest(request)
    }
    
    /// Stream content
    @available(macOS 10.15, *)
    public func streamContent(url: URL) -> AnyPublisher<Data, NetworkError> {
        let request = URLRequest(url: url)
        
        return session.dataTaskPublisher(for: request)
            .map(\.data)
            .mapError { error in
                NetworkError.requestFailed(error)
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Private Methods
    
    private func setupNetworkMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.updateNetworkStatus(path)
            }
        }
        monitor.start(queue: monitorQueue)
    }
    
    @available(macOS 10.15, *)
    private func updateNetworkStatus(_ path: NWPath) {
        isConnected = path.status == .satisfied
        isReachable = path.status == .satisfied
        
        switch path.usesInterfaceType(.wifi) {
        case true:
            connectionType = .wifi
        case false:
            if path.usesInterfaceType(.cellular) {
                connectionType = .cellular
            } else if path.usesInterfaceType(.wiredEthernet) {
                connectionType = .ethernet
            } else {
                connectionType = .unknown
            }
        }
    }
    
    private func createRequest(for endpoint: APIEndpoint) throws -> URLRequest {
        guard let url = URL(string: baseURL + endpoint.path) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("DogTV+/1.0", forHTTPHeaderField: "User-Agent")
        
        return request
    }
    
    @available(macOS 10.15, *)
    private func performRequest<T: Decodable>(_ request: URLRequest) async throws -> T {
        guard isConnected else {
            throw NetworkError.noConnection
        }
        
        do {
            // Use older API for compatibility
            let (data, response): (Data, URLResponse) = try await withCheckedThrowingContinuation { continuation in
                let task = session.dataTask(with: request) { data, response, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: (data ?? Data(), response ?? URLResponse()))
                    }
                }
                task.resume()
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            guard 200...299 ~= httpResponse.statusCode else {
                throw NetworkError.httpError(httpResponse.statusCode)
            }
            
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.requestFailed(error)
        }
    }
    
    @available(macOS 10.15, *)
    private func performRequest(_ request: URLRequest) async throws {
        guard isConnected else {
            throw NetworkError.noConnection
        }
        
        do {
            // Use older API for compatibility
            let (_, response): (Data, URLResponse) = try await withCheckedThrowingContinuation { continuation in
                let task = session.dataTask(with: request) { data, response, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: (data ?? Data(), response ?? URLResponse()))
                    }
                }
                task.resume()
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            guard 200...299 ~= httpResponse.statusCode else {
                throw NetworkError.httpError(httpResponse.statusCode)
            }
        } catch {
            throw NetworkError.requestFailed(error)
        }
    }
}

// MARK: - Supporting Types

public enum NetworkQuality: String, CaseIterable, Codable {
    case excellent = "Excellent"
    case good = "Good"
    case fair = "Fair"
    case poor = "Poor"
    case unknown = "Unknown"
}

public enum NetworkError: Error, LocalizedError {
    case noConnection
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case requestFailed(Error)
    case decodingFailed(Error)
    
    public var errorDescription: String? {
        switch self {
        case .noConnection:
            return "No network connection available"
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .requestFailed(let error):
            return "Request failed: \(error.localizedDescription)"
        case .decodingFailed(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        }
    }
}

// Add missing type definitions
struct SceneConfiguration: Codable {
    let id: String
    let name: String
    let description: String
    let parameters: [String: String]
}

struct AnalyticsData: Codable {
    let userId: String
    let sessionId: String
    let events: [AnalyticsEvent]
    let timestamp: Date
}

struct AnalyticsEvent: Codable {
    let name: String
    let parameters: [String: String]
    let timestamp: Date
}

struct UserData: Codable {
    let userId: String
    let preferences: [String: String]
    let lastSync: Date
}

struct UpdateInfo: Codable {
    let version: String
    let isAvailable: Bool
    let downloadURL: URL?
    let releaseNotes: String
}

enum APIEndpoint {
    case content
    case analytics
    case sync
    case updates
    
    var path: String {
        switch self {
        case .content:
            return "/content"
        case .analytics:
            return "/analytics"
        case .sync:
            return "/sync"
        case .updates:
            return "/updates"
        }
    }
}

// MARK: - Network Status View
@available(macOS 11.0, *)
public struct NetworkStatusView: View {
    @ObservedObject var networkManager: NetworkManager
    
    public init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }
    
    public var body: some View {
        HStack {
            Image(systemName: networkManager.isConnected ? "wifi" : "wifi.slash")
                .foregroundColor(networkManager.isConnected ? .green : .red)
            
            VStack(alignment: .leading) {
                Text(networkManager.connectionType.rawValue)
                    .font(.caption)
                Text(networkManager.networkQuality.rawValue)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.secondary.opacity(0.2))
        .cornerRadius(8)
    }
}

// MARK: - Offline Mode Handler

@available(macOS 10.15, *)
public class OfflineModeHandler: ObservableObject {
    @Published public var isOfflineMode: Bool = false
    @Published public var cachedSceneConfigs: [SceneConfiguration] = []
    
    private let networkManager: NetworkManager
    
    public init(networkManager: NetworkManager) {
        self.networkManager = networkManager
        
        setupOfflineMode()
    }
    
    private func setupOfflineMode() {
        networkManager.$isConnected
            .sink { [weak self] isConnected in
                DispatchQueue.main.async {
                    self?.isOfflineMode = !isConnected
                    if !isConnected {
                        self?.loadCachedSceneConfigs()
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    @available(macOS 10.15, *)
    private func loadCachedSceneConfigs() {
        // Load scene configurations from local cache
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let configPath = documentsPath.appendingPathComponent("cached_scenes.json")
        
        do {
            let data = try Data(contentsOf: configPath)
            let decoder = JSONDecoder()
            let configs = try decoder.decode([SceneConfiguration].self, from: data)
            
            cachedSceneConfigs = configs
        } catch {
            print("Failed to load cached scene configurations: \(error)")
            cachedSceneConfigs = []
        }
    }
    
    private var cancellables = Set<AnyCancellable>()
}

// MARK: - Scene Configuration

public struct SceneConfiguration: Codable, Identifiable {
    public let id: UUID
    public let name: String
    public let description: String
    public let visualParameters: VisualParameters
    public let audioParameters: AudioParameters
    public let version: String
    public let createdAt: Date
    
    public init(id: UUID = UUID(), name: String, description: String, visualParameters: VisualParameters, audioParameters: AudioParameters, version: String = "1.0") {
        self.id = id
        self.name = name
        self.description = description
        self.visualParameters = visualParameters
        self.audioParameters = audioParameters
        self.version = version
        self.createdAt = Date()
    }
}

public struct VisualParameters: Codable {
    public let colorPalette: [String]
    public let motionIntensity: Float
    public let contrastLevel: Float
    public let brightness: Float
    public let saturation: Float
    
    public init(colorPalette: [String], motionIntensity: Float, contrastLevel: Float, brightness: Float, saturation: Float) {
        self.colorPalette = colorPalette
        self.motionIntensity = motionIntensity
        self.contrastLevel = contrastLevel
        self.brightness = brightness
        self.saturation = saturation
    }
}

public struct AudioParameters: Codable {
    public let volume: Float
    public let frequencyRange: String
    public let therapeuticFrequencies: [Float]
    
    public init(volume: Float, frequencyRange: String, therapeuticFrequencies: [Float]) {
        self.volume = volume
        self.frequencyRange = frequencyRange
        self.therapeuticFrequencies = therapeuticFrequencies
    }
}

// MARK: - Network Retry Handler

@available(macOS 10.15, *)
public class NetworkRetryHandler {
    private let maxRetries: Int
    private let retryDelay: TimeInterval
    
    public init(maxRetries: Int = 3, retryDelay: TimeInterval = 1.0) {
        self.maxRetries = maxRetries
        self.retryDelay = retryDelay
    }
    
    @available(macOS 10.15, *)
    public func retry<T>(_ operation: @escaping () async throws -> T) async throws -> T {
        var lastError: Error?
        
        for attempt in 1...maxRetries {
            do {
                return try await operation()
            } catch {
                lastError = error
                
                if attempt < maxRetries {
                    try await Task.sleep(nanoseconds: UInt64(retryDelay * 1_000_000_000))
                }
            }
        }
        
        throw lastError ?? NetworkError.requestFailed(NSError(domain: "NetworkRetry", code: -1, userInfo: nil))
    }
} 