import Foundation
import SwiftUI
import Combine

/// A simple data persistence system for DogTV+
@available(iOS 17.0, tvOS 17.0, macOS 10.15, *)
public class DataPersistenceSystem: ObservableObject {
    @Published public var isSyncing: Bool = false
    @Published public var lastSyncDate: Date?
    @Published public var syncProgress: Double = 0.0

    private let userDefaults = UserDefaults.standard

    public init() {}

    // MARK: - Data Persistence

    /// Save data to UserDefaults
    public func saveData<T: Codable>(_ data: T, key: String) throws {
        let encoder = JSONEncoder()
        let encodedData = try encoder.encode(data)
        userDefaults.set(encodedData, forKey: key)
    }

    /// Load data from UserDefaults
    public func loadData<T: Codable>(_ type: T.Type, key: String) throws -> T? {
        guard let data = userDefaults.data(forKey: key) else {
            return nil
        }

        let decoder = JSONDecoder()
        return try decoder.decode(type, from: data)
    }

    /// Delete data from UserDefaults
    public func deleteData(key: String) {
        userDefaults.removeObject(forKey: key)
    }

    /// Clear all data
    public func clearAllData() {
        guard let domain = Bundle.main.bundleIdentifier else {
            return
        }
        userDefaults.removePersistentDomain(forName: domain)
    }

    // MARK: - Sync Methods

    /// Sync data with cloud (placeholder implementation)
    public func syncWithCloud() async {
        isSyncing = true
        syncProgress = 0.0

        // Simulate sync process
        for i in 1...10 {
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
            syncProgress = Double(i) / 10.0
        }

        isSyncing = false
        lastSyncDate = Date()
    }
}
