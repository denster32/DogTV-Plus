import Foundation
import Combine
import Network

/// A comprehensive network manager for DogTV+ with API communication and offline support
public class NetworkManager: ObservableObject {
    @Published public var isConnected: Bool = false
    @Published public var isReachable: Bool = false
    @Published public var connectionType: ConnectionType = .unknown
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
    
    /// Fetch content from API
    public func fetchContent() async throws -> [VideoContent] {
        let endpoint = APIEndpoint.content
        let request = try createRequest(for: endpoint)
        
        return try await performRequest(request)
    }
    
    /// Upload analytics data
    public func uploadAnalytics(_ data: AnalyticsData) async throws {
        let endpoint = APIEndpoint.analytics
        var request = try createRequest(for: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(data)
        
        try await performRequest(request)
    }
    
    /// Download content for offline viewing
    public func downloadContent(_ content: VideoContent) async throws -> URL {
        guard let url = URL(string: content.videoURL) else {
            throw NetworkError.invalidURL
        }
        
        let request = URLRequest(url: url)
        let (data, _) = try await session.data(for: request)
        
        // Save to local storage
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = "\(content.id).mp4"
        let fileURL = documentsPath.appendingPathComponent(fileName)
        
        try data.write(to: fileURL)
        return fileURL
    }
    
    /// Sync user data with server
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
    public func checkForUpdates() async throws -> UpdateInfo {
        let endpoint = APIEndpoint.updates
        let request = try createRequest(for: endpoint)
        
        return try await performRequest(request)
    }
    
    /// Stream content
    public func streamContent(url: URL) -> AnyPublisher<Data, NetworkError> {
        let request = URLRequest(url: url)
        
        return session.dataTaskPublisher(for: request)
            .map(\.data)
            .mapError { error in
                NetworkError.requestFailed(error.localizedDescription)
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
    
    private func performRequest<T: Decodable>(_ request: URLRequest) async throws -> T {
        guard isConnected else {
            throw NetworkError.noConnection
        }
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            guard 200...299 ~= httpResponse.statusCode else {
                throw NetworkError.httpError(httpResponse.statusCode)
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            return try decoder.decode(T.self, from: data)
            
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.requestFailed(error.localizedDescription)
        }
    }
    
    private func performRequest(_ request: URLRequest) async throws {
        guard isConnected else {
            throw NetworkError.noConnection
        }
        
        do {
            let (_, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            guard 200...299 ~= httpResponse.statusCode else {
                throw NetworkError.httpError(httpResponse.statusCode)
            }
            
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.requestFailed(error.localizedDescription)
        }
    }
}

// MARK: - Supporting Types

public enum ConnectionType {
    case wifi
    case cellular
    case ethernet
    case unknown
}

public enum NetworkError: Error, LocalizedError {
    case noConnection
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case requestFailed(String)
    case decodingFailed(String)
    case serverError(String)
    
    public var errorDescription: String? {
        switch self {
        case .noConnection:
            return "No internet connection available"
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .requestFailed(let message):
            return "Request failed: \(message)"
        case .decodingFailed(let message):
            return "Failed to decode response: \(message)"
        case .serverError(let message):
            return "Server error: \(message)"
        }
    }
}

private enum APIEndpoint {
    case content
    case analytics
    case sync
    case updates
    
    var path: String {
        switch self {
        case .content:
            return "/api/v1/content"
        case .analytics:
            return "/api/v1/analytics"
        case .sync:
            return "/api/v1/sync"
        case .updates:
            return "/api/v1/updates"
        }
    }
}

// MARK: - Data Models

public struct AnalyticsData: Codable {
    public let userId: String
    public let eventType: String
    public let eventData: [String: String]
    public let timestamp: Date
    public let sessionId: String
    
    public init(userId: String, eventType: String, eventData: [String: String], timestamp: Date = Date(), sessionId: String) {
        self.userId = userId
        self.eventType = eventType
        self.eventData = eventData
        self.timestamp = timestamp
        self.sessionId = sessionId
    }
}

public struct UserData: Codable {
    public let user: User
    public let dogs: [DogProfile]
    public let preferences: UserPreferences
    public let lastSync: Date
    
    public init(user: User, dogs: [DogProfile], preferences: UserPreferences, lastSync: Date = Date()) {
        self.user = user
        self.dogs = dogs
        self.preferences = preferences
        self.lastSync = lastSync
    }
}

public struct UpdateInfo: Codable {
    public let hasUpdates: Bool
    public let lastUpdate: Date
    public let version: String
    public let changelog: String
    
    public init(hasUpdates: Bool, lastUpdate: Date, version: String, changelog: String) {
        self.hasUpdates = hasUpdates
        self.lastUpdate = lastUpdate
        self.version = version
        self.changelog = changelog
    }
}

// MARK: - Network Status View

public struct NetworkStatusView: View {
    @ObservedObject var networkManager: NetworkManager
    
    public init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }
    
    public var body: some View {
        HStack {
            Image(systemName: networkManager.isConnected ? "wifi" : "wifi.slash")
                .foregroundColor(networkManager.isConnected ? .green : .red)
            
            Text(networkManager.isConnected ? "Connected" : "Offline")
                .font(.caption)
                .foregroundColor(networkManager.isConnected ? .green : .red)
            
            if networkManager.isConnected {
                Text("(\(networkManager.connectionType.rawValue))")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// MARK: - Offline Mode Handler

public class OfflineModeHandler: ObservableObject {
    @Published public var isOfflineMode: Bool = false
    @Published public var cachedContent: [VideoContent] = []
    
    private let networkManager: NetworkManager
    private let contentManager: ContentDeliverySystem
    
    public init(networkManager: NetworkManager, contentManager: ContentDeliverySystem) {
        self.networkManager = networkManager
        self.contentManager = contentManager
        
        setupOfflineMode()
    }
    
    private func setupOfflineMode() {
        networkManager.$isConnected
            .sink { [weak self] isConnected in
                DispatchQueue.main.async {
                    self?.isOfflineMode = !isConnected
                    if !isConnected {
                        self?.loadCachedContent()
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    private func loadCachedContent() {
        // Load content from local cache
        cachedContent = contentManager.downloadedContent
    }
    
    private var cancellables = Set<AnyCancellable>()
}

// MARK: - Network Retry Handler

public class NetworkRetryHandler {
    private let maxRetries: Int
    private let retryDelay: TimeInterval
    
    public init(maxRetries: Int = 3, retryDelay: TimeInterval = 2.0) {
        self.maxRetries = maxRetries
        self.retryDelay = retryDelay
    }
    
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
        
        throw lastError ?? NetworkError.requestFailed("Max retries exceeded")
    }
} 