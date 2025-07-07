import XCTest
import Foundation
import Security
import CryptoKit

@testable import DogTV_

/**
 * SecureDataStorageSystemTests: Comprehensive testing for secure data storage
 * 
 * Focuses on:
 * - Encryption and decryption
 * - Data storage and retrieval
 * - Error handling
 * - Performance
 * - Security edge cases
 */
class SecureDataStorageSystemTests: XCTestCase {
    
    // MARK: - Test Properties
    
    private var secureDataStorageSystem: SecureDataStorageSystem!
    
    // MARK: - Setup and Teardown
    
    override func setUp() {
        super.setUp()
        
        // Create in-memory test container
        let testContainer = NSPersistentContainer(name: "SecureDataModels")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        testContainer.persistentStoreDescriptions = [description]
        
        testContainer.loadPersistentStores { description, error in
            if let error = error {
                XCTFail("Failed to load test store: \(error)")
            }
        }
        
        do {
            secureDataStorageSystem = try SecureDataStorageSystem(container: testContainer)
        } catch {
            XCTFail("Failed to initialize SecureDataStorageSystem: \(error)")
        }
    }
    
    override func tearDown() {
        secureDataStorageSystem = nil
        super.tearDown()
    }
    
    // MARK: - Basic Storage and Retrieval Tests
    
    /// Test storing and retrieving user profile data
    func testUserProfileDataStorage() {
        let testData = "Test User Profile Data".data(using: .utf8)!
        let config = SecureDataStorageSystem.EncryptionConfig(
            category: .userProfile,
            encryptionLevel: .high
        )
        
        do {
            // Store data
            try secureDataStorageSystem.storeData(testData, config: config)
            
            // Retrieve data
            let retrievedData = try secureDataStorageSystem.retrieveData(
                category: .userProfile,
                config: config
            )
            
            XCTAssertEqual(testData, retrievedData, "Retrieved data should match original")
        } catch {
            XCTFail("User profile data storage failed: \(error)")
        }
    }
    
    /// Test storing and retrieving behavioral data
    func testBehavioralDataStorage() {
        let testData = "Complex Behavioral Analysis Data".data(using: .utf8)!
        let config = SecureDataStorageSystem.EncryptionConfig(
            category: .behavioralData,
            encryptionLevel: .maximum,
            isCloudSyncEnabled: true
        )
        
        do {
            // Store data
            try secureDataStorageSystem.storeData(testData, config: config)
            
            // Retrieve data
            let retrievedData = try secureDataStorageSystem.retrieveData(
                category: .behavioralData,
                config: config
            )
            
            XCTAssertEqual(testData, retrievedData, "Retrieved behavioral data should match original")
        } catch {
            XCTFail("Behavioral data storage failed: \(error)")
        }
    }
    
    // MARK: - Encryption Level Tests
    
    /// Test different encryption levels
    func testEncryptionLevels() {
        let testData = "Encryption Level Test Data".data(using: .utf8)!
        let encryptionLevels: [SecureDataStorageSystem.EncryptionLevel] = [
            .standard, .high, .maximum
        ]
        
        for level in encryptionLevels {
            let config = SecureDataStorageSystem.EncryptionConfig(
                category: .preferences,
                encryptionLevel: level
            )
            
            do {
                // Store data
                try secureDataStorageSystem.storeData(testData, config: config)
                
                // Retrieve data
                let retrievedData = try secureDataStorageSystem.retrieveData(
                    category: .preferences,
                    config: config
                )
                
                XCTAssertEqual(testData, retrievedData, "Retrieved data should match original for \(level)")
            } catch {
                XCTFail("Data storage failed for encryption level \(level): \(error)")
            }
        }
    }
    
    // MARK: - Error Handling Tests
    
    /// Test storing empty data
    func testEmptyDataStorage() {
        let emptyData = Data()
        let config = SecureDataStorageSystem.EncryptionConfig(
            category: .userProfile,
            encryptionLevel: .standard
        )
        
        XCTAssertThrowsError(
            try secureDataStorageSystem.storeData(emptyData, config: config),
            "Storing empty data should throw an error"
        ) { error in
            XCTAssertTrue(
                error is SecureDataStorageSystem.SecureStorageError,
                "Error should be a SecureStorageError"
            )
        }
    }
    
    /// Test retrieving non-existent data
    func testRetrieveNonExistentData() {
        let config = SecureDataStorageSystem.EncryptionConfig(
            category: .medicalHistory,
            encryptionLevel: .high
        )
        
        XCTAssertThrowsError(
            try secureDataStorageSystem.retrieveData(
                category: .medicalHistory,
                config: config
            ),
            "Retrieving non-existent data should throw an error"
        ) { error in
            XCTAssertTrue(
                error is SecureDataStorageSystem.SecureStorageError,
                "Error should be a SecureStorageError"
            )
        }
    }
    
    // MARK: - Performance Tests
    
    /// Performance test for data storage and retrieval
    func testStoragePerformance() {
        let testData = Data(repeating: 0x41, count: 1024 * 1024) // 1MB of data
        let config = SecureDataStorageSystem.EncryptionConfig(
            category: .behavioralData,
            encryptionLevel: .high
        )
        
        measure {
            do {
                try secureDataStorageSystem.storeData(testData, config: config)
                _ = try secureDataStorageSystem.retrieveData(
                    category: .behavioralData,
                    config: config
                )
            } catch {
                XCTFail("Performance test failed: \(error)")
            }
        }
    }
    
    // MARK: - Data Deletion Tests
    
    /// Test data deletion
    func testDataDeletion() {
        let testData = "Data to be deleted".data(using: .utf8)!
        let config = SecureDataStorageSystem.EncryptionConfig(
            category: .preferences
        )
        
        do {
            // Store data
            try secureDataStorageSystem.storeData(testData, config: config)
            
            // Delete data
            try secureDataStorageSystem.deleteData(category: .preferences)
            
            // Attempt to retrieve deleted data should fail
            XCTAssertThrowsError(
                try secureDataStorageSystem.retrieveData(
                    category: .preferences,
                    config: config
                ),
                "Retrieving deleted data should throw an error"
            )
        } catch {
            XCTFail("Data deletion test failed: \(error)")
        }
    }
    
    // MARK: - Thread Safety Tests
    
    /// Test concurrent read/write operations with thread safety verification
    func testConcurrentAccess() throws {
        let testQueue = DispatchQueue(
            label: "test.concurrent",
            attributes: .concurrent
        )
        let testData = "Concurrent Test Data".data(using: .utf8)!
        let config = SecureDataStorageSystem.EncryptionConfig(
            category: .userProfile,
            encryptionLevel: .high
        )
        
        let group = DispatchGroup()
        let iterations = 100
        
        // Clear any existing metrics
        _ = secureDataStorageSystem.getThreadSafetyMetrics()
        
        // Concurrent operations
        for i in 0..<iterations {
            group.enter()
            testQueue.async {
                defer { group.leave() }
                
                if i % 3 == 0 {
                    // Write operation
                    let uniqueData = "\(i)-\(testData)".data(using: .utf8)!
                    try? self.secureDataStorageSystem.storeData(
                        uniqueData,
                        config: config
                    )
                } else {
                    // Read operation
                    _ = try? self.secureDataStorageSystem.retrieveData(
                        category: .userProfile,
                        config: config
                    )
                }
            }
        }
        
        group.wait()
        
        // Verify thread safety metrics
        let metrics = secureDataStorageSystem.getThreadSafetyMetrics()
        XCTAssertFalse(metrics.isEmpty, "Should track thread operations")
        XCTAssertGreaterThan(metrics.count, 1, "Should track multiple operations")
        
        // Verify final state
        let retrievedData = try secureDataStorageSystem.retrieveData(
            category: .userProfile,
            config: config
        )
        XCTAssertNotNil(retrievedData, "System should maintain consistency under concurrent access")
        
        print("Thread Safety Metrics:")
        metrics.forEach { print("\($0.key): \($0.value)s") }
    }
    
    // MARK: - Cloud Sync Tests
    
    /// Test cloud sync configuration
    func testCloudSyncConfiguration() {
        let testData = "Cloud Sync Test Data".data(using: .utf8)!
        let cloudSyncConfigs: [Bool] = [true, false]
        
        for isCloudSyncEnabled in cloudSyncConfigs {
            let config = SecureDataStorageSystem.EncryptionConfig(
                category: .userProfile,
                encryptionLevel: .standard,
                isCloudSyncEnabled: isCloudSyncEnabled
            )
            
            do {
                // Store data
                try secureDataStorageSystem.storeData(testData, config: config)
                
                // Retrieve data
                let retrievedData = try secureDataStorageSystem.retrieveData(
                    category: .userProfile,
                    config: config
                )
                
                XCTAssertEqual(testData, retrievedData, "Retrieved data should match original")
            } catch {
                XCTFail("Cloud sync configuration test failed for sync = \(isCloudSyncEnabled): \(error)")
            }
        }
    }
    
    // MARK: - CloudKit Sync Tests
    
    /// Test end-to-end CloudKit synchronization
    func testCloudKitSyncIntegration() {
        let expectation = XCTestExpectation(description: "CloudKit sync completed")
        let testData = "CloudKit Sync Test Data".data(using: .utf8)!
        let config = SecureDataStorageSystem.EncryptionConfig(
            category: .behavioralData,
            encryptionLevel: .high,
            isCloudSyncEnabled: true
        )
        
        // 1. Store data locally
        do {
            try secureDataStorageSystem.storeData(testData, config: config)
        } catch {
            XCTFail("Failed to store test data: \(error)")
            return
        }
        
        // 2. Verify sync to CloudKit completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            do {
                // 3. Retrieve from CloudKit
                let cloudData = try self.secureDataStorageSystem.retrieveData(
                    category: .behavioralData,
                    config: config
                )
                
                XCTAssertEqual(testData, cloudData, "Cloud data should match original")
                
                // 4. Test conflict resolution
                let modifiedData = "Modified Cloud Data".data(using: .utf8)!
                try self.secureDataStorageSystem.storeData(modifiedData, config: config)
                
                // 5. Verify conflict resolution
                let resolvedData = try self.secureDataStorageSystem.retrieveData(
                    category: .behavioralData,
                    config: config
                )
                XCTAssertEqual(modifiedData, resolvedData, "Should resolve conflicts with latest version")
                
                expectation.fulfill()
            } catch {
                XCTFail("CloudKit sync test failed: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    // MARK: - Security Audit Tests
    
    /// Test security audit logging
    func testSecurityAuditLogging() {
        let testData = "Audit Test Data".data(using: .utf8)!
        let config = SecureDataStorageSystem.EncryptionConfig(
            category: .userProfile,
            encryptionLevel: .high
        )
        
        do {
            // Store data
            try secureDataStorageSystem.storeData(testData, config: config)
            
            // Retrieve data
            _ = try secureDataStorageSystem.retrieveData(
                category: .userProfile,
                config: config
            )
            
            // Delete data
            try secureDataStorageSystem.deleteData(category: .userProfile)
            
            // Verify audit logs were created
            let auditLog = SecurityAuditLogger.shared.getAuditLog()
            XCTAssertGreaterThanOrEqual(auditLog.count, 3, "Should log storage, retrieval and deletion events")
            
            let storageEvents = auditLog.filter { $0.type == .storage }
            XCTAssertEqual(storageEvents.count, 1, "Should log storage event")
            
            let retrievalEvents = auditLog.filter { $0.type == .retrieval }
            XCTAssertEqual(retrievalEvents.count, 1, "Should log retrieval event")
            
            let deletionEvents = auditLog.filter { $0.type == .deletion }
            XCTAssertEqual(deletionEvents.count, 1, "Should log deletion event")
        } catch {
            XCTFail("Security audit test failed: \(error)")
        }
    }
    
    // MARK: - Backup/Restore Tests
    
    /// Test local backup and restore functionality
    func testLocalBackupRestore() throws {
        let testData = "Backup Test Data".data(using: .utf8)!
        let config = SecureDataStorageSystem.EncryptionConfig(
            category: .userProfile,
            encryptionLevel: .high
        )
        
        // Store initial data
        try secureDataStorageSystem.storeData(testData, config: config)
        
        // Create backup
        let backupURL = try secureDataStorageSystem.createLocalBackup()
        XCTAssertTrue(FileManager.default.fileExists(atPath: backupURL.path))
        
        // Clear data
        try secureDataStorageSystem.deleteData(category: .userProfile)
        
        // Restore from backup
        try secureDataStorageSystem.restoreFromLocalBackup(backupURL)
        
        // Verify data restored
        let restoredData = try secureDataStorageSystem.retrieveData(
            category: .userProfile,
            config: config
        )
        XCTAssertEqual(testData, restoredData, "Restored data should match original")
    }
    
    /// Test cloud backup and restore functionality
    func testCloudBackupRestore() throws {
        let expectation = XCTestExpectation(description: "Cloud backup/restore completed")
        let testData = "Cloud Backup Test Data".data(using: .utf8)!
        let config = SecureDataStorageSystem.EncryptionConfig(
            category: .behavioralData,
            encryptionLevel: .high,
            isCloudSyncEnabled: true
        )
        
        // Store initial data
        try secureDataStorageSystem.storeData(testData, config: config)
        
        // Create cloud backup
        try secureDataStorageSystem.createCloudBackup()
        
        // Clear local data
        try secureDataStorageSystem.deleteData(category: .behavioralData)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            do {
                // Restore from cloud backup
                try self.secureDataStorageSystem.restoreFromCloudBackup()
                
                // Verify data restored
                let restoredData = try self.secureDataStorageSystem.retrieveData(
                    category: .behavioralData,
                    config: config
                )
                XCTAssertEqual(testData, restoredData, "Cloud restored data should match original")
                expectation.fulfill()
            } catch {
                XCTFail("Cloud backup/restore failed: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    // MARK: - Key Management Tests
    
    /// Test key rotation functionality
    func testKeyRotation() {
        let keychain = KeychainManager()
        let service = "test.service"
        let testKey = SymmetricKey(size: .bits256).withUnsafeBytes { Data($0) }
        
        do {
            // Store initial key
            try keychain.storeKey(testKey, for: service)
            
            // Force key rotation
            for _ in 0..<2 {
                try keychain.storeKey(testKey, for: service)
            }
            
            // Verify key rotation events were logged
            let auditLog = SecurityAuditLogger.shared.getAuditLog()
            let rotationEvents = auditLog.filter { $0.type == .rotation }
            XCTAssertGreaterThanOrEqual(rotationEvents.count, 1, "Should log key rotation events")
            
        } catch {
            XCTFail("Key rotation test failed: \(error)")
        }
    }
} 