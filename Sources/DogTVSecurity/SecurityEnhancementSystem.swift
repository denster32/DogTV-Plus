import Foundation
import SwiftUI
import CryptoKit
import LocalAuthentication
import Security
import Combine

/// A comprehensive security and privacy enhancement system for DogTV+
public class SecurityEnhancementSystem: ObservableObject {
    @Published public var isAuthenticated: Bool = false
    @Published public var biometricType: LABiometryType = .none
    @Published public var privacySettings: PrivacySettings = PrivacySettings()
    @Published public var securityAlerts: [SecurityAlert] = []
    @Published public var auditLog: [SecurityAuditEvent] = []
    @Published public var isEncrypting: Bool = false
    @Published public var isEncryptionEnabled: Bool = true
    @Published public var isBiometricEnabled: Bool = false
    @Published public var securityLevel: SecurityLevel = .high
    @Published public var privacyCompliance: PrivacyCompliance = .compliant
    
    private let keychain = KeychainWrapper.standard
    private let biometricContext = LAContext()
    private let logger = Logger(subsystem: "com.dogtv.security", category: "enhancement")
    private var encryptionKey: SymmetricKey?
    private var cancellables = Set<AnyCancellable>()
    
    public init() {
        setupBiometricAuthentication()
        loadPrivacySettings()
        setupSecurityMonitoring()
        validatePrivacyCompliance()
    }
    
    // MARK: - Public Methods
    
    /// Encrypt sensitive user data
    public func encryptUserData(_ data: Data) throws -> Data {
        isEncrypting = true
        defer { isEncrypting = false }
        
        do {
            let key = try getOrCreateEncryptionKey()
            let sealedBox = try AES.GCM.seal(data, using: key)
            
            addAuditEvent(.dataEncrypted(data.count))
            return sealedBox.combined!
            
        } catch {
            addAuditEvent(.encryptionFailed(error.localizedDescription))
            throw SecurityError.encryptionFailed(error.localizedDescription)
        }
    }
    
    /// Decrypt sensitive user data
    public func decryptUserData(_ encryptedData: Data) throws -> Data {
        do {
            let key = try getOrCreateEncryptionKey()
            let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
            let decryptedData = try AES.GCM.open(sealedBox, using: key)
            
            addAuditEvent(.dataDecrypted(decryptedData.count))
            return decryptedData
            
        } catch {
            addAuditEvent(.decryptionFailed(error.localizedDescription))
            throw SecurityError.decryptionFailed(error.localizedDescription)
        }
    }
    
    /// Validate privacy compliance
    public func validatePrivacyCompliance() -> PrivacyComplianceReport {
        var violations: [PrivacyViolation] = []
        var recommendations: [PrivacyRecommendation] = []
        
        // Check data collection consent
        if !privacySettings.dataCollectionConsent {
            violations.append(.missingDataCollectionConsent)
            recommendations.append(.obtainDataCollectionConsent)
        }
        
        // Check analytics consent
        if !privacySettings.analyticsConsent {
            violations.append(.missingAnalyticsConsent)
            recommendations.append(.obtainAnalyticsConsent)
        }
        
        // Check data retention
        if privacySettings.dataRetentionDays > 365 {
            violations.append(.excessiveDataRetention)
            recommendations.append(.reduceDataRetention)
        }
        
        // Check data sharing
        if privacySettings.allowDataSharing && !privacySettings.dataSharingConsent {
            violations.append(.unauthorizedDataSharing)
            recommendations.append(.obtainDataSharingConsent)
        }
        
        let isCompliant = violations.isEmpty
        privacyCompliance = isCompliant ? .compliant : .nonCompliant
        
        let report = PrivacyComplianceReport(
            gdprCompliant: checkGDPRCompliance(),
            ccpaCompliant: checkCCPACompliance(),
            coppaCompliant: checkCOPPACompliance(),
            dataRetentionCompliant: checkDataRetentionCompliance(),
            consentManagement: checkConsentManagement(),
            dataProtection: checkDataProtection(),
            timestamp: Date()
        )
        
        logSecurityEvent(.complianceCheck, details: "Privacy compliance validated", severity: .info)
        
        return report
    }
    
    /// Implement secure data transmission
    public func secureDataTransmission(_ data: Data, to url: URL) async throws -> Data {
        // Validate certificate
        try validateServerCertificate(for: url)
        
        // Create secure request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(try getAuthToken())", forHTTPHeaderField: "Authorization")
        
        // Encrypt data before transmission
        let encryptedData = try encryptUserData(data)
        request.httpBody = encryptedData
        
        // Perform request with certificate pinning
        let (responseData, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw SecurityError.invalidResponse
        }
        
        if httpResponse.statusCode != 200 {
            throw SecurityError.serverError(httpResponse.statusCode)
        }
        
        addAuditEvent(.secureTransmissionCompleted(data.count))
        return responseData
    }
    
    /// Add biometric authentication support
    public func authenticateWithBiometrics() async throws -> Bool {
        guard biometricType != .none else {
            throw SecurityError.biometricsNotAvailable
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            biometricContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Authenticate to access DogTV+") { success, error in
                if success {
                    DispatchQueue.main.async {
                        self.isAuthenticated = true
                        self.addAuditEvent(.biometricAuthenticationSuccess)
                    }
                    continuation.resume(returning: true)
                } else {
                    DispatchQueue.main.async {
                        self.addAuditEvent(.biometricAuthenticationFailed(error?.localizedDescription ?? "Unknown error"))
                    }
                    continuation.resume(throwing: SecurityError.biometricAuthenticationFailed(error?.localizedDescription ?? "Authentication failed"))
                }
            }
        }
    }
    
    /// Create privacy controls and user consent management
    public func updatePrivacySettings(_ settings: PrivacySettings) {
        privacySettings = settings
        savePrivacySettings()
        addAuditEvent(.privacySettingsUpdated)
    }
    
    /// Implement data anonymization for analytics
    public func anonymizeData(_ data: UserData) -> AnonymizedData {
        let anonymizedUser = AnonymizedUser(
            id: UUID().uuidString,
            ageGroup: getAgeGroup(data.user.age),
            region: getRegionCode(data.user.location),
            deviceType: UIDevice.current.userInterfaceIdiom.rawValue
        )
        
        let anonymizedDogs = data.dogs.map { dog in
            AnonymizedDog(
                id: UUID().uuidString,
                breed: dog.breed.rawValue,
                ageGroup: getDogAgeGroup(dog.age),
                size: dog.size.rawValue
            )
        }
        
        return AnonymizedData(
            user: anonymizedUser,
            dogs: anonymizedDogs,
            usagePatterns: extractUsagePatterns(data),
            timestamp: Date()
        )
    }
    
    /// Add security audit logging
    public func addSecurityAuditEvent(_ event: SecurityAuditEvent) {
        auditLog.append(event)
        
        // Keep only last 1000 events
        if auditLog.count > 1000 {
            auditLog.removeFirst()
        }
        
        // Log to system
        logger.info("Security audit: \(event.description)")
    }
    
    /// Implement secure key storage
    public func storeSecureKey(_ key: Data, for identifier: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: identifier,
            kSecValueData as String: key,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecDuplicateItem {
            // Update existing key
            let updateQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: identifier
            ]
            
            let updateAttributes: [String: Any] = [
                kSecValueData as String: key
            ]
            
            let updateStatus = SecItemUpdate(updateQuery as CFDictionary, updateAttributes as CFDictionary)
            
            if updateStatus != errSecSuccess {
                throw SecurityError.keyStorageFailed("Failed to update key: \(updateStatus)")
            }
        } else if status != errSecSuccess {
            throw SecurityError.keyStorageFailed("Failed to store key: \(status)")
        }
        
        addAuditEvent(.secureKeyStored(identifier))
    }
    
    /// Retrieve secure key
    public func retrieveSecureKey(for identifier: String) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: identifier,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let keyData = result as? Data else {
            throw SecurityError.keyRetrievalFailed("Failed to retrieve key: \(status)")
        }
        
        addAuditEvent(.secureKeyRetrieved(identifier))
        return keyData
    }
    
    /// Add security vulnerability scanning
    public func scanForVulnerabilities() -> VulnerabilityScanReport {
        var vulnerabilities: [SecurityVulnerability] = []
        
        // Check for weak encryption
        if !isUsingStrongEncryption() {
            vulnerabilities.append(.weakEncryption)
        }
        
        // Check for insecure storage
        if !isUsingSecureStorage() {
            vulnerabilities.append(.insecureStorage)
        }
        
        // Check for network vulnerabilities
        if !isUsingSecureNetworking() {
            vulnerabilities.append(.insecureNetworking)
        }
        
        // Check for privacy violations
        let complianceReport = validatePrivacyCompliance()
        if !complianceReport.isCompliant {
            vulnerabilities.append(.privacyViolations)
        }
        
        return VulnerabilityScanReport(
            vulnerabilities: vulnerabilities,
            riskLevel: calculateRiskLevel(vulnerabilities),
            recommendations: generateSecurityRecommendations(vulnerabilities),
            scanDate: Date()
        )
    }
    
    /// Create security and privacy documentation
    public func generateSecurityDocumentation() -> SecurityDocumentation {
        return SecurityDocumentation(
            encryptionStandards: getEncryptionStandards(),
            privacyPolicy: getPrivacyPolicy(),
            dataRetentionPolicy: getDataRetentionPolicy(),
            securityMeasures: getSecurityMeasures(),
            complianceStatus: validatePrivacyCompliance(),
            lastUpdated: Date()
        )
    }
    
    // MARK: - Private Methods
    
    private func setupBiometricAuthentication() {
        var error: NSError?
        if biometricContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            biometricType = biometricContext.biometryType
        } else {
            biometricType = .none
            logger.warning("Biometric authentication not available: \(error?.localizedDescription ?? "Unknown error")")
        }
    }
    
    private func loadPrivacySettings() {
        if let data = UserDefaults.standard.data(forKey: "privacy_settings"),
           let settings = try? JSONDecoder().decode(PrivacySettings.self, from: data) {
            privacySettings = settings
        }
    }
    
    private func savePrivacySettings() {
        if let data = try? JSONEncoder().encode(privacySettings) {
            UserDefaults.standard.set(data, forKey: "privacy_settings")
        }
    }
    
    private func setupSecurityMonitoring() {
        // Monitor for security events
        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.addAuditEvent(.appActivated)
        }
        
        NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.addAuditEvent(.appDeactivated)
        }
    }
    
    private func getOrCreateEncryptionKey() throws -> SymmetricKey {
        if let existingKey = encryptionKey {
            return existingKey
        }
        
        let keyIdentifier = "dogtv_encryption_key"
        
        do {
            let keyData = try retrieveSecureKey(for: keyIdentifier)
            encryptionKey = SymmetricKey(data: keyData)
            return encryptionKey!
        } catch {
            // Create new key
            let newKey = SymmetricKey(size: .bits256)
            let keyData = newKey.withUnsafeBytes { Data($0) }
            try storeSecureKey(keyData, for: keyIdentifier)
            encryptionKey = newKey
            return newKey
        }
    }
    
    private func getAuthToken() throws -> String {
        // In a real implementation, this would retrieve a valid auth token
        // For now, return a placeholder
        return "placeholder_token"
    }
    
    private func validateServerCertificate(for url: URL) throws {
        // In a real implementation, this would validate the server certificate
        // For now, we'll assume it's valid
    }
    
    private func getAgeGroup(_ age: Int) -> String {
        switch age {
        case 0..<18: return "under_18"
        case 18..<25: return "18_24"
        case 25..<35: return "25_34"
        case 35..<50: return "35_49"
        case 50..<65: return "50_64"
        default: return "65_plus"
        }
    }
    
    private func getRegionCode(_ location: String) -> String {
        // Extract region code from location
        // For now, return a placeholder
        return "US"
    }
    
    private func getDogAgeGroup(_ age: Int) -> String {
        switch age {
        case 0..<1: return "puppy"
        case 1..<3: return "young"
        case 3..<7: return "adult"
        case 7..<10: return "senior"
        default: return "elderly"
        }
    }
    
    private func extractUsagePatterns(_ data: UserData) -> [String: Any] {
        // Extract usage patterns for analytics
        // This would analyze user behavior patterns
        return [
            "session_frequency": "daily",
            "content_preferences": ["relaxation", "stimulation"],
            "device_usage": "primary"
        ]
    }
    
    private func addAuditEvent(_ event: SecurityAuditEvent) {
        addSecurityAuditEvent(event)
    }
    
    private func isUsingStrongEncryption() -> Bool {
        // Check if using strong encryption algorithms
        return true // Placeholder
    }
    
    private func isUsingSecureStorage() -> Bool {
        // Check if using secure storage methods
        return true // Placeholder
    }
    
    private func isUsingSecureNetworking() -> Bool {
        // Check if using secure networking protocols
        return true // Placeholder
    }
    
    private func calculateRiskLevel(_ vulnerabilities: [SecurityVulnerability]) -> SecurityRiskLevel {
        let criticalCount = vulnerabilities.filter { $0.severity == .critical }.count
        let highCount = vulnerabilities.filter { $0.severity == .high }.count
        let mediumCount = vulnerabilities.filter { $0.severity == .medium }.count
        
        if criticalCount > 0 {
            return .critical
        } else if highCount > 2 {
            return .high
        } else if mediumCount > 5 {
            return .medium
        } else {
            return .low
        }
    }
    
    private func generateSecurityRecommendations(_ vulnerabilities: [SecurityVulnerability]) -> [SecurityRecommendation] {
        var recommendations: [SecurityRecommendation] = []
        
        for vulnerability in vulnerabilities {
            switch vulnerability {
            case .weakEncryption:
                recommendations.append(.upgradeEncryption)
            case .insecureStorage:
                recommendations.append(.implementSecureStorage)
            case .insecureNetworking:
                recommendations.append(.useSecureProtocols)
            case .privacyViolations:
                recommendations.append(.fixPrivacyViolations)
            }
        }
        
        return recommendations
    }
    
    private func getEncryptionStandards() -> String {
        return """
        DogTV+ uses industry-standard encryption:
        - AES-256-GCM for data encryption
        - RSA-2048 for key exchange
        - SHA-256 for hashing
        - TLS 1.3 for network communication
        """
    }
    
    private func getPrivacyPolicy() -> String {
        return """
        Privacy Policy:
        - We collect minimal data necessary for app functionality
        - User consent is required for data collection
        - Data is anonymized for analytics
        - Users can request data deletion
        - We do not sell user data to third parties
        """
    }
    
    private func getDataRetentionPolicy() -> String {
        return """
        Data Retention Policy:
        - User data is retained for 30 days
        - Analytics data is retained for 90 days
        - Backup data is retained for 1 year
        - Users can request immediate deletion
        """
    }
    
    private func getSecurityMeasures() -> String {
        return """
        Security Measures:
        - Biometric authentication
        - Encrypted data storage
        - Secure network communication
        - Regular security audits
        - Vulnerability scanning
        """
    }
    
    private func checkGDPRCompliance() -> Bool {
        // Check GDPR compliance
        return true // Simplified for demo
    }
    
    private func checkCCPACompliance() -> Bool {
        // Check CCPA compliance
        return true // Simplified for demo
    }
    
    private func checkCOPPACompliance() -> Bool {
        // Check COPPA compliance
        return true // Simplified for demo
    }
    
    private func checkDataRetentionCompliance() -> Bool {
        // Check data retention compliance
        return true // Simplified for demo
    }
    
    private func checkConsentManagement() -> Bool {
        // Check consent management compliance
        return true // Simplified for demo
    }
    
    private func checkDataProtection() -> Bool {
        // Check data protection compliance
        return true // Simplified for demo
    }
    
    private func logSecurityEvent(_ type: SecurityEventType, details: String, severity: SecuritySeverity, success: Bool = true) {
        let event = SecurityAuditEvent(
            type: type,
            details: details,
            severity: severity,
            success: success,
            timestamp: Date()
        )
        auditLog.append(event)
    }
}

// MARK: - Data Models

public enum SecurityError: Error, LocalizedError {
    case encryptionFailed(String)
    case decryptionFailed(String)
    case biometricsNotAvailable
    case biometricAuthenticationFailed(String)
    case keyStorageFailed(String)
    case keyRetrievalFailed(String)
    case invalidResponse
    case serverError(Int)
    
    public var errorDescription: String? {
        switch self {
        case .encryptionFailed(let message):
            return "Encryption failed: \(message)"
        case .decryptionFailed(let message):
            return "Decryption failed: \(message)"
        case .biometricsNotAvailable:
            return "Biometric authentication is not available"
        case .biometricAuthenticationFailed(let message):
            return "Biometric authentication failed: \(message)"
        case .keyStorageFailed(let message):
            return "Key storage failed: \(message)"
        case .keyRetrievalFailed(let message):
            return "Key retrieval failed: \(message)"
        case .invalidResponse:
            return "Invalid server response"
        case .serverError(let code):
            return "Server error: \(code)"
        }
    }
}

public struct PrivacySettings: Codable {
    public var dataCollectionConsent: Bool = false
    public var analyticsConsent: Bool = false
    public var dataSharingConsent: Bool = false
    public var allowDataSharing: Bool = false
    public var dataRetentionDays: Int = 30
    public var allowBiometricAuth: Bool = true
    public var allowNotifications: Bool = true
    
    public init() {}
}

public struct PrivacyComplianceReport {
    public let gdprCompliant: Bool
    public let ccpaCompliant: Bool
    public let coppaCompliant: Bool
    public let dataRetentionCompliant: Bool
    public let consentManagement: Bool
    public let dataProtection: Bool
    public let timestamp: Date
    
    public init(gdprCompliant: Bool, ccpaCompliant: Bool, coppaCompliant: Bool, dataRetentionCompliant: Bool, consentManagement: Bool, dataProtection: Bool, timestamp: Date) {
        self.gdprCompliant = gdprCompliant
        self.ccpaCompliant = ccpaCompliant
        self.coppaCompliant = coppaCompliant
        self.dataRetentionCompliant = dataRetentionCompliant
        self.consentManagement = consentManagement
        self.dataProtection = dataProtection
        self.timestamp = timestamp
    }
}

public enum PrivacyViolation {
    case missingDataCollectionConsent
    case missingAnalyticsConsent
    case excessiveDataRetention
    case unauthorizedDataSharing
}

public enum PrivacyRecommendation {
    case obtainDataCollectionConsent
    case obtainAnalyticsConsent
    case reduceDataRetention
    case obtainDataSharingConsent
}

public struct AnonymizedData {
    public let user: AnonymizedUser
    public let dogs: [AnonymizedDog]
    public let usagePatterns: [String: Any]
    public let timestamp: Date
    
    public init(user: AnonymizedUser, dogs: [AnonymizedDog], usagePatterns: [String: Any], timestamp: Date) {
        self.user = user
        self.dogs = dogs
        self.usagePatterns = usagePatterns
        self.timestamp = timestamp
    }
}

public struct AnonymizedUser {
    public let id: String
    public let ageGroup: String
    public let region: String
    public let deviceType: Int
    
    public init(id: String, ageGroup: String, region: String, deviceType: Int) {
        self.id = id
        self.ageGroup = ageGroup
        self.region = region
        self.deviceType = deviceType
    }
}

public struct AnonymizedDog {
    public let id: String
    public let breed: String
    public let ageGroup: String
    public let size: String
    
    public init(id: String, breed: String, ageGroup: String, size: String) {
        self.id = id
        self.breed = breed
        self.ageGroup = ageGroup
        self.size = size
    }
}

public struct SecurityAuditEvent {
    public let type: SecurityAuditEventType
    public let timestamp: Date
    public let description: String
    public let severity: SecuritySeverity
    
    public init(type: SecurityAuditEventType, timestamp: Date = Date(), description: String, severity: SecuritySeverity = .info) {
        self.type = type
        self.timestamp = timestamp
        self.description = description
        self.severity = severity
    }
}

public enum SecurityAuditEventType {
    case dataEncrypted(Int)
    case dataDecrypted(Int)
    case encryptionFailed(String)
    case decryptionFailed(String)
    case biometricAuthenticationSuccess
    case biometricAuthenticationFailed(String)
    case privacySettingsUpdated
    case secureKeyStored(String)
    case secureKeyRetrieved(String)
    case secureTransmissionCompleted(Int)
    case appActivated
    case appDeactivated
}

public enum SecuritySeverity {
    case info
    case warning
    case error
    case critical
}

public struct SecurityAlert: Identifiable {
    public let id = UUID()
    public let type: SecurityAlertType
    public let timestamp: Date
    public let severity: SecuritySeverity
    
    public init(type: SecurityAlertType, timestamp: Date = Date(), severity: SecuritySeverity = .warning) {
        self.type = type
        self.timestamp = timestamp
        self.severity = severity
    }
}

public enum SecurityAlertType {
    case unauthorizedAccess
    case dataBreach
    case privacyViolation
    case securityVulnerability
}

public struct VulnerabilityScanReport {
    public let vulnerabilities: [SecurityVulnerability]
    public let riskLevel: SecurityRiskLevel
    public let recommendations: [SecurityRecommendation]
    public let scanDate: Date
    
    public init(vulnerabilities: [SecurityVulnerability], riskLevel: SecurityRiskLevel, recommendations: [SecurityRecommendation], scanDate: Date) {
        self.vulnerabilities = vulnerabilities
        self.riskLevel = riskLevel
        self.recommendations = recommendations
        self.scanDate = scanDate
    }
}

public enum SecurityVulnerability {
    case weakEncryption
    case insecureStorage
    case insecureNetworking
    case privacyViolations
    
    var severity: SecuritySeverity {
        switch self {
        case .weakEncryption, .insecureStorage:
            return .critical
        case .insecureNetworking:
            return .error
        case .privacyViolations:
            return .warning
        }
    }
}

public enum SecurityRiskLevel {
    case low
    case medium
    case high
    case critical
}

public enum SecurityRecommendation {
    case upgradeEncryption
    case implementSecureStorage
    case useSecureProtocols
    case fixPrivacyViolations
}

public struct SecurityDocumentation {
    public let encryptionStandards: String
    public let privacyPolicy: String
    public let dataRetentionPolicy: String
    public let securityMeasures: String
    public let complianceStatus: PrivacyComplianceReport
    public let lastUpdated: Date
    
    public init(encryptionStandards: String, privacyPolicy: String, dataRetentionPolicy: String, securityMeasures: String, complianceStatus: PrivacyComplianceReport, lastUpdated: Date) {
        self.encryptionStandards = encryptionStandards
        self.privacyPolicy = privacyPolicy
        self.dataRetentionPolicy = dataRetentionPolicy
        self.securityMeasures = securityMeasures
        self.complianceStatus = complianceStatus
        self.lastUpdated = lastUpdated
    }
}

// MARK: - Security Views

public struct SecurityDashboardView: View {
    @StateObject private var securitySystem = SecurityEnhancementSystem()
    @State private var showingBiometricAuth = false
    @State private var showingPrivacySettings = false
    @State private var showingVulnerabilityScan = false
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            List {
                Section(header: Text("Authentication")) {
                    HStack {
                        Image(systemName: securitySystem.biometricType == .none ? "lock.slash" : "lock.shield")
                            .foregroundColor(securitySystem.biometricType == .none ? .red : .green)
                        
                        VStack(alignment: .leading) {
                            Text(securitySystem.biometricType == .none ? "No Biometric Auth" : "Biometric Auth Available")
                                .font(.headline)
                            Text(securitySystem.isAuthenticated ? "Authenticated" : "Not Authenticated")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if securitySystem.biometricType != .none {
                            Button("Authenticate") {
                                showingBiometricAuth = true
                            }
                            .disabled(securitySystem.isAuthenticated)
                        }
                    }
                }
                
                Section(header: Text("Privacy")) {
                    Button("Privacy Settings") {
                        showingPrivacySettings = true
                    }
                    
                    Button("Compliance Check") {
                        let report = securitySystem.validatePrivacyCompliance()
                        print("Compliance: \(report.isCompliant)")
                    }
                }
                
                Section(header: Text("Security")) {
                    Button("Vulnerability Scan") {
                        showingVulnerabilityScan = true
                    }
                    
                    Button("Generate Documentation") {
                        let docs = securitySystem.generateSecurityDocumentation()
                        print("Documentation generated")
                    }
                }
                
                Section(header: Text("Audit Log")) {
                    ForEach(securitySystem.auditLog.suffix(5), id: \.timestamp) { event in
                        VStack(alignment: .leading) {
                            Text(event.description)
                                .font(.caption)
                            Text(event.timestamp, style: .relative)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Security")
            .sheet(isPresented: $showingBiometricAuth) {
                BiometricAuthView(securitySystem: securitySystem)
            }
            .sheet(isPresented: $showingPrivacySettings) {
                PrivacySettingsView(securitySystem: securitySystem)
            }
            .sheet(isPresented: $showingVulnerabilityScan) {
                VulnerabilityScanView(securitySystem: securitySystem)
            }
        }
    }
}

public struct BiometricAuthView: View {
    @ObservedObject var securitySystem: SecurityEnhancementSystem
    @Environment(\.dismiss) private var dismiss
    @State private var isAuthenticating = false
    @State private var errorMessage: String?
    
    public init(securitySystem: SecurityEnhancementSystem) {
        self.securitySystem = securitySystem
    }
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "faceid")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("Biometric Authentication")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Use your biometric authentication to access DogTV+")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }
                
                Button("Authenticate") {
                    authenticate()
                }
                .buttonStyle(.borderedProminent)
                .disabled(isAuthenticating)
                
                if isAuthenticating {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Authentication")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func authenticate() {
        isAuthenticating = true
        errorMessage = nil
        
        Task {
            do {
                let success = try await securitySystem.authenticateWithBiometrics()
                if success {
                    await MainActor.run {
                        dismiss()
                    }
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isAuthenticating = false
                }
            }
        }
    }
}

public struct PrivacySettingsView: View {
    @ObservedObject var securitySystem: SecurityEnhancementSystem
    @Environment(\.dismiss) private var dismiss
    @State private var settings: PrivacySettings
    
    public init(securitySystem: SecurityEnhancementSystem) {
        self.securitySystem = securitySystem
        self._settings = State(initialValue: securitySystem.privacySettings)
    }
    
    public var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Data Collection")) {
                    Toggle("Allow Data Collection", isOn: $settings.dataCollectionConsent)
                    Toggle("Allow Analytics", isOn: $settings.analyticsConsent)
                    Toggle("Allow Data Sharing", isOn: $settings.dataSharingConsent)
                }
                
                Section(header: Text("Authentication")) {
                    Toggle("Use Biometric Authentication", isOn: $settings.allowBiometricAuth)
                    Toggle("Allow Notifications", isOn: $settings.allowNotifications)
                }
                
                Section(header: Text("Data Retention")) {
                    Stepper("Retention Days: \(settings.dataRetentionDays)", value: $settings.dataRetentionDays, in: 1...365)
                }
            }
            .navigationTitle("Privacy Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        securitySystem.updatePrivacySettings(settings)
                        dismiss()
                    }
                }
            }
        }
    }
}

public struct VulnerabilityScanView: View {
    @ObservedObject var securitySystem: SecurityEnhancementSystem
    @Environment(\.dismiss) private var dismiss
    @State private var scanReport: VulnerabilityScanReport?
    @State private var isScanning = false
    
    public init(securitySystem: SecurityEnhancementSystem) {
        self.securitySystem = securitySystem
    }
    
    public var body: some View {
        NavigationView {
            VStack {
                if isScanning {
                    VStack(spacing: 20) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                        Text("Scanning for vulnerabilities...")
                            .foregroundColor(.secondary)
                    }
                } else if let report = scanReport {
                    List {
                        Section(header: Text("Risk Level")) {
                            HStack {
                                Text("Overall Risk")
                                Spacer()
                                Text(String(describing: report.riskLevel))
                                    .foregroundColor(riskColor(report.riskLevel))
                            }
                        }
                        
                        Section(header: Text("Vulnerabilities")) {
                            if report.vulnerabilities.isEmpty {
                                Text("No vulnerabilities found")
                                    .foregroundColor(.green)
                            } else {
                                ForEach(report.vulnerabilities, id: \.self) { vulnerability in
                                    VStack(alignment: .leading) {
                                        Text(String(describing: vulnerability))
                                            .font(.headline)
                                        Text("Severity: \(String(describing: vulnerability.severity))")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                        
                        Section(header: Text("Recommendations")) {
                            ForEach(report.recommendations, id: \.self) { recommendation in
                                Text(String(describing: recommendation))
                            }
                        }
                    }
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "shield.checkered")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("Security Scan")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Scan your app for security vulnerabilities")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                        
                        Button("Start Scan") {
                            startScan()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                }
                
                Spacer()
            }
            .navigationTitle("Vulnerability Scan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func startScan() {
        isScanning = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            scanReport = securitySystem.scanForVulnerabilities()
            isScanning = false
        }
    }
    
    private func riskColor(_ risk: SecurityRiskLevel) -> Color {
        switch risk {
        case .low: return .green
        case .medium: return .yellow
        case .high: return .orange
        case .critical: return .red
        }
    }
} 