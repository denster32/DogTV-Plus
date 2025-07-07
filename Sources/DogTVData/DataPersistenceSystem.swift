import Foundation
import SwiftUI
import Combine
import CloudKit

/// A comprehensive data persistence and synchronization system for DogTV+
public class DataPersistenceSystem: ObservableObject {
    @Published public var isSyncing: Bool = false
    @Published public var lastSyncDate: Date?
    @Published public var syncProgress: Double = 0.0
    @Published public var syncError: DataError?
    @Published public var isCloudAvailable: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    private let userDefaults = UserDefaults.standard
    private let fileManager = FileManager.default
    private let cloudKitContainer = CKContainer.default()
    
    public init() {
        checkCloudAvailability()
        setupSyncMonitoring()
    }
    
    // MARK: - Public Methods
    
    /// Save user data to persistent storage
    public func saveUserData(_ data: UserData) async throws {
        do {
            // Save to local storage
            try saveToLocalStorage(data)
            
            // Sync to iCloud if available
            if isCloudAvailable {
                try await syncToCloud(data)
            }
            
            await MainActor.run {
                self.lastSyncDate = Date()
                self.syncError = nil
            }
            
        } catch {
            await MainActor.run {
                self.syncError = .saveFailed(error.localizedDescription)
            }
            throw error
        }
    }
    
    /// Sync data with iCloud
    public func syncWithCloud() async throws {
        guard isCloudAvailable else {
            throw DataError.cloudNotAvailable
        }
        
        await MainActor.run {
            isSyncing = true
            syncProgress = 0.0
            syncError = nil
        }
        
        do {
            // Load local data
            let localData = try loadFromLocalStorage()
            
            // Upload to CloudKit
            try await uploadToCloudKit(localData)
            
            // Download any cloud changes
            let cloudData = try await downloadFromCloudKit()
            
            // Merge data
            let mergedData = mergeData(local: localData, cloud: cloudData)
            
            // Save merged data
            try saveToLocalStorage(mergedData)
            
            await MainActor.run {
                isSyncing = false
                syncProgress = 1.0
                lastSyncDate = Date()
            }
            
        } catch {
            await MainActor.run {
                isSyncing = false
                syncError = .syncFailed(error.localizedDescription)
            }
            throw error
        }
    }
    
    /// Load user data from persistent storage
    public func loadUserData() async throws -> UserData {
        return try loadFromLocalStorage()
    }
    
    /// Create data backup
    public func createBackup() async throws -> URL {
        let data = try loadFromLocalStorage()
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        let backupData = try encoder.encode(data)
        
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let backupFileName = "DogTV_Backup_\(Date().timeIntervalSince1970).json"
        let backupURL = documentsPath.appendingPathComponent(backupFileName)
        
        try backupData.write(to: backupURL)
        return backupURL
    }
    
    /// Restore data from backup
    public func restoreFromBackup(_ backupURL: URL) async throws {
        let backupData = try Data(contentsOf: backupURL)
        let decoder = JSONDecoder()
        let restoredData = try decoder.decode(UserData.self, from: backupData)
        
        try saveToLocalStorage(restoredData)
        
        if isCloudAvailable {
            try await syncWithCloud()
        }
    }
    
    /// Export data for user
    public func exportData() async throws -> URL {
        let data = try loadFromLocalStorage()
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        let exportData = try encoder.encode(data)
        
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let exportFileName = "DogTV_Export_\(Date().timeIntervalSince1970).json"
        let exportURL = documentsPath.appendingPathComponent(exportFileName)
        
        try exportData.write(to: exportURL)
        return exportURL
    }
    
    /// Clear all data
    public func clearAllData() async throws {
        // Clear local storage
        try clearLocalStorage()
        
        // Clear cloud data if available
        if isCloudAvailable {
            try await clearCloudData()
        }
        
        await MainActor.run {
            lastSyncDate = nil
            syncError = nil
        }
    }
    
    /// Validate data integrity
    public func validateDataIntegrity() async throws -> DataIntegrityReport {
        let data = try loadFromLocalStorage()
        var issues: [DataIssue] = []
        
        // Check user data
        if data.user.name.isEmpty {
            issues.append(DataIssue(type: .missingData, description: "User name is missing"))
        }
        
        if data.user.email.isEmpty {
            issues.append(DataIssue(type: .missingData, description: "User email is missing"))
        }
        
        // Check dog profiles
        for (index, dog) in data.dogs.enumerated() {
            if dog.name.isEmpty {
                issues.append(DataIssue(type: .missingData, description: "Dog \(index + 1) name is missing"))
            }
            
            if dog.age <= 0 {
                issues.append(DataIssue(type: .invalidData, description: "Dog \(index + 1) age is invalid"))
            }
        }
        
        // Check for duplicate data
        let duplicateDogs = findDuplicateDogs(data.dogs)
        if !duplicateDogs.isEmpty {
            issues.append(DataIssue(type: .duplicateData, description: "Found \(duplicateDogs.count) duplicate dog profiles"))
        }
        
        return DataIntegrityReport(
            isValid: issues.isEmpty,
            issues: issues,
            totalRecords: data.dogs.count + 1, // +1 for user
            lastValidation: Date()
        )
    }
    
    // MARK: - Private Methods
    
    private func checkCloudAvailability() {
        cloudKitContainer.accountStatus { [weak self] status, error in
            DispatchQueue.main.async {
                self?.isCloudAvailable = status == .available
            }
        }
    }
    
    private func setupSyncMonitoring() {
        // Monitor for network changes to trigger sync
        NotificationCenter.default.publisher(for: .NSURLCacheMemoryCapacityDidChange)
            .sink { [weak self] _ in
                // Trigger sync when network becomes available
                Task {
                    try? await self?.syncWithCloud()
                }
            }
            .store(in: &cancellables)
    }
    
    private func saveToLocalStorage(_ data: UserData) throws {
        let encoder = JSONEncoder()
        let userData = try encoder.encode(data.user)
        let dogsData = try encoder.encode(data.dogs)
        let preferencesData = try encoder.encode(data.preferences)
        
        userDefaults.set(userData, forKey: "user_data")
        userDefaults.set(dogsData, forKey: "dogs_data")
        userDefaults.set(preferencesData, forKey: "preferences_data")
        userDefaults.set(Date(), forKey: "last_save_date")
    }
    
    private func loadFromLocalStorage() throws -> UserData {
        guard let userData = userDefaults.data(forKey: "user_data"),
              let dogsData = userDefaults.data(forKey: "dogs_data"),
              let preferencesData = userDefaults.data(forKey: "preferences_data") else {
            throw DataError.dataNotFound
        }
        
        let decoder = JSONDecoder()
        let user = try decoder.decode(User.self, from: userData)
        let dogs = try decoder.decode([DogProfile].self, from: dogsData)
        let preferences = try decoder.decode(UserPreferences.self, from: preferencesData)
        
        return UserData(user: user, dogs: dogs, preferences: preferences)
    }
    
    private func clearLocalStorage() throws {
        userDefaults.removeObject(forKey: "user_data")
        userDefaults.removeObject(forKey: "dogs_data")
        userDefaults.removeObject(forKey: "preferences_data")
        userDefaults.removeObject(forKey: "last_save_date")
    }
    
    private func syncToCloud(_ data: UserData) async throws {
        // Simulate cloud sync
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        // In a real implementation, this would use CloudKit
        // For now, we'll simulate the sync process
    }
    
    private func uploadToCloudKit(_ data: UserData) async throws {
        // Simulate CloudKit upload with progress
        for i in 1...10 {
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
            await MainActor.run {
                syncProgress = Double(i) / 10.0
            }
        }
    }
    
    private func downloadFromCloudKit() async throws -> UserData {
        // Simulate CloudKit download
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        return try loadFromLocalStorage() // Return local data for now
    }
    
    private func clearCloudData() async throws {
        // Simulate clearing cloud data
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
    }
    
    private func mergeData(local: UserData, cloud: UserData) -> UserData {
        // Simple merge strategy - prefer cloud data for conflicts
        let mergedUser = cloud.user
        let mergedDogs = cloud.dogs
        let mergedPreferences = cloud.preferences
        
        return UserData(
            user: mergedUser,
            dogs: mergedDogs,
            preferences: mergedPreferences,
            lastSync: Date()
        )
    }
    
    private func findDuplicateDogs(_ dogs: [DogProfile]) -> [DogProfile] {
        var seen: Set<String> = []
        var duplicates: [DogProfile] = []
        
        for dog in dogs {
            let key = "\(dog.name)_\(dog.breed.rawValue)"
            if seen.contains(key) {
                duplicates.append(dog)
            } else {
                seen.insert(key)
            }
        }
        
        return duplicates
    }
}

// MARK: - Data Models

public enum DataError: Error, LocalizedError {
    case saveFailed(String)
    case loadFailed(String)
    case syncFailed(String)
    case cloudNotAvailable
    case dataNotFound
    case invalidData
    case backupFailed(String)
    case restoreFailed(String)
    
    public var errorDescription: String? {
        switch self {
        case .saveFailed(let message):
            return "Failed to save data: \(message)"
        case .loadFailed(let message):
            return "Failed to load data: \(message)"
        case .syncFailed(let message):
            return "Failed to sync data: \(message)"
        case .cloudNotAvailable:
            return "iCloud is not available"
        case .dataNotFound:
            return "No data found"
        case .invalidData:
            return "Data is invalid or corrupted"
        case .backupFailed(let message):
            return "Failed to create backup: \(message)"
        case .restoreFailed(let message):
            return "Failed to restore from backup: \(message)"
        }
    }
}

public struct DataIntegrityReport {
    public let isValid: Bool
    public let issues: [DataIssue]
    public let totalRecords: Int
    public let lastValidation: Date
    
    public init(isValid: Bool, issues: [DataIssue], totalRecords: Int, lastValidation: Date) {
        self.isValid = isValid
        self.issues = issues
        self.totalRecords = totalRecords
        self.lastValidation = lastValidation
    }
}

public struct DataIssue {
    public let type: DataIssueType
    public let description: String
    public let severity: DataIssueSeverity
    
    public init(type: DataIssueType, description: String, severity: DataIssueSeverity = .medium) {
        self.type = type
        self.description = description
        self.severity = severity
    }
}

public enum DataIssueType {
    case missingData
    case invalidData
    case duplicateData
    case corruptedData
    case inconsistentData
}

public enum DataIssueSeverity {
    case low
    case medium
    case high
    case critical
}

// MARK: - Data Views

public struct DataManagementView: View {
    @StateObject private var dataSystem = DataPersistenceSystem()
    @State private var showingBackupPicker = false
    @State private var showingExportSheet = false
    @State private var exportURL: URL?
    @State private var integrityReport: DataIntegrityReport?
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            List {
                Section(header: Text("Sync Status")) {
                    HStack {
                        Image(systemName: dataSystem.isCloudAvailable ? "icloud.fill" : "icloud.slash")
                            .foregroundColor(dataSystem.isCloudAvailable ? .blue : .gray)
                        
                        VStack(alignment: .leading) {
                            Text(dataSystem.isCloudAvailable ? "iCloud Available" : "iCloud Not Available")
                                .font(.headline)
                            if let lastSync = dataSystem.lastSyncDate {
                                Text("Last sync: \(lastSync, style: .relative)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        if dataSystem.isSyncing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        }
                    }
                    
                    if dataSystem.isCloudAvailable {
                        Button("Sync Now") {
                            Task {
                                try? await dataSystem.syncWithCloud()
                            }
                        }
                        .disabled(dataSystem.isSyncing)
                    }
                }
                
                Section(header: Text("Data Management")) {
                    Button("Create Backup") {
                        Task {
                            do {
                                let backupURL = try await dataSystem.createBackup()
                                print("Backup created at: \(backupURL)")
                            } catch {
                                print("Backup failed: \(error)")
                            }
                        }
                    }
                    
                    Button("Restore from Backup") {
                        showingBackupPicker = true
                    }
                    
                    Button("Export Data") {
                        Task {
                            do {
                                exportURL = try await dataSystem.exportData()
                                showingExportSheet = true
                            } catch {
                                print("Export failed: \(error)")
                            }
                        }
                    }
                }
                
                Section(header: Text("Data Integrity")) {
                    Button("Validate Data") {
                        Task {
                            integrityReport = try? await dataSystem.validateDataIntegrity()
                        }
                    }
                    
                    if let report = integrityReport {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: report.isValid ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                                    .foregroundColor(report.isValid ? .green : .orange)
                                Text(report.isValid ? "Data Valid" : "Issues Found")
                                    .font(.headline)
                            }
                            
                            Text("\(report.totalRecords) records")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            if !report.issues.isEmpty {
                                ForEach(report.issues, id: \.description) { issue in
                                    Text("• \(issue.description)")
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                Section(header: Text("Danger Zone")) {
                    Button("Clear All Data") {
                        // Show confirmation dialog
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Data Management")
            .fileImporter(
                isPresented: $showingBackupPicker,
                allowedContentTypes: [.json],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    if let url = urls.first {
                        Task {
                            try? await dataSystem.restoreFromBackup(url)
                        }
                    }
                case .failure(let error):
                    print("Backup import failed: \(error)")
                }
            }
            .sheet(isPresented: $showingExportSheet) {
                if let url = exportURL {
                    ShareSheet(items: [url])
                }
            }
        }
    }
}

public struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    public init(items: [Any]) {
        self.items = items
    }
    
    public func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    public func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
} 