#!/usr/bin/env swift

import Foundation
import Security

/// Advanced security scanner for DogTV+ codebase
struct SecurityScanner {
    
    struct SecurityIssue {
        let file: String
        let line: Int
        let severity: Severity
        let category: Category
        let description: String
        let recommendation: String
        
        enum Severity: String, CaseIterable {
            case critical = "CRITICAL"
            case high = "HIGH"
            case medium = "MEDIUM"
            case low = "LOW"
            case info = "INFO"
            
            var emoji: String {
                switch self {
                case .critical: return "🚨"
                case .high: return "⚠️"
                case .medium: return "⚡"
                case .low: return "💡"
                case .info: return "ℹ️"
                }
            }
        }
        
        enum Category: String, CaseIterable {
            case dataProtection = "Data Protection"
            case authentication = "Authentication"
            case encryption = "Encryption"
            case networking = "Networking"
            case codeQuality = "Code Quality"
            case privacy = "Privacy"
            case permissions = "Permissions"
        }
    }
    
    static func scanProject() -> [SecurityIssue] {
        print("🔒 Starting comprehensive security scan of DogTV+ project...")
        
        var issues: [SecurityIssue] = []
        
        // Scan for various security issues
        issues.append(contentsOf: scanForHardcodedSecrets())
        issues.append(contentsOf: scanForInsecureNetworking())
        issues.append(contentsOf: scanForDataProtectionIssues())
        issues.append(contentsOf: scanForAuthenticationIssues())
        issues.append(contentsOf: scanForPrivacyIssues())
        issues.append(contentsOf: scanForCodeQualityIssues())
        issues.append(contentsOf: scanForPermissionIssues())
        
        generateSecurityReport(issues: issues)
        
        return issues
    }
    
    private static func scanForHardcodedSecrets() -> [SecurityIssue] {
        var issues: [SecurityIssue] = []
        
        let secretPatterns = [
            ("API_KEY", "Potential hardcoded API key"),
            ("password", "Potential hardcoded password"),
            ("secret", "Potential hardcoded secret"),
            ("token", "Potential hardcoded token"),
            ("private_key", "Potential hardcoded private key"),
            ("sk_live_", "Stripe live secret key"),
            ("sk_test_", "Stripe test secret key"),
            ("AKIA[0-9A-Z]{16}", "AWS Access Key ID")
        ]
        
        let swiftFiles = findSwiftFiles()
        
        for file in swiftFiles {
            guard let content = try? String(contentsOfFile: file) else { continue }
            let lines = content.components(separatedBy: .newlines)
            
            for (lineIndex, line) in lines.enumerated() {
                for (pattern, description) in secretPatterns {
                    if line.lowercased().contains(pattern.lowercased()) &&
                       !line.trimmingCharacters(in: .whitespaces).hasPrefix("//") {
                        issues.append(SecurityIssue(
                            file: file,
                            line: lineIndex + 1,
                            severity: .critical,
                            category: .dataProtection,
                            description: description,
                            recommendation: "Use environment variables or secure keychain storage"
                        ))
                    }
                }
            }
        }
        
        return issues
    }
    
    private static func scanForInsecureNetworking() -> [SecurityIssue] {
        var issues: [SecurityIssue] = []
        
        let insecurePatterns = [
            ("http://", "Insecure HTTP connection"),
            ("allowsArbitraryLoads = true", "Allows arbitrary network loads"),
            ("NSAllowsArbitraryLoads", "Network security exception"),
            ("URLSessionConfiguration.default.tlsMinimumSupportedProtocolVersion", "TLS configuration")
        ]
        
        let files = findAllSourceFiles()
        
        for file in files {
            guard let content = try? String(contentsOfFile: file) else { continue }
            let lines = content.components(separatedBy: .newlines)
            
            for (lineIndex, line) in lines.enumerated() {
                for (pattern, description) in insecurePatterns {
                    if line.contains(pattern) {
                        let severity: SecurityIssue.Severity = pattern.contains("http://") ? .high : .medium
                        issues.append(SecurityIssue(
                            file: file,
                            line: lineIndex + 1,
                            severity: severity,
                            category: .networking,
                            description: description,
                            recommendation: "Use HTTPS and proper TLS configuration"
                        ))
                    }
                }
            }
        }
        
        return issues
    }
    
    private static func scanForDataProtectionIssues() -> [SecurityIssue] {
        var issues: [SecurityIssue] = []
        
        let dataProtectionPatterns = [
            ("UserDefaults.standard.set", "Potential sensitive data in UserDefaults"),
            ("NSLog", "Potential data leakage in logs"),
            ("print(", "Potential data leakage in console"),
            ("debugPrint", "Debug information in production"),
            ("FileManager.default.createFile", "File creation without protection")
        ]
        
        let swiftFiles = findSwiftFiles()
        
        for file in swiftFiles {
            guard let content = try? String(contentsOfFile: file) else { continue }
            let lines = content.components(separatedBy: .newlines)
            
            for (lineIndex, line) in lines.enumerated() {
                for (pattern, description) in dataProtectionPatterns {
                    if line.contains(pattern) {
                        let severity: SecurityIssue.Severity = pattern.contains("NSLog") ? .medium : .low
                        issues.append(SecurityIssue(
                            file: file,
                            line: lineIndex + 1,
                            severity: severity,
                            category: .dataProtection,
                            description: description,
                            recommendation: "Use secure storage and avoid logging sensitive data"
                        ))
                    }
                }
            }
        }
        
        return issues
    }
    
    private static func scanForAuthenticationIssues() -> [SecurityIssue] {
        var issues: [SecurityIssue] = []
        
        // Check for weak authentication patterns
        let authPatterns = [
            ("BiometricAuthenticationManager", "Biometric authentication implementation"),
            ("LocalAuthentication", "Local authentication usage"),
            ("TouchID", "Touch ID implementation"),
            ("FaceID", "Face ID implementation")
        ]
        
        let swiftFiles = findSwiftFiles()
        var hasAuthImplementation = false
        
        for file in swiftFiles {
            guard let content = try? String(contentsOfFile: file) else { continue }
            
            for (pattern, _) in authPatterns {
                if content.contains(pattern) {
                    hasAuthImplementation = true
                    break
                }
            }
        }
        
        if !hasAuthImplementation {
            issues.append(SecurityIssue(
                file: "Project",
                line: 0,
                severity: .medium,
                category: .authentication,
                description: "No biometric authentication implementation found",
                recommendation: "Consider implementing biometric authentication for enhanced security"
            ))
        }
        
        return issues
    }
    
    private static func scanForPrivacyIssues() -> [SecurityIssue] {
        var issues: [SecurityIssue] = []
        
        // Check for privacy-related patterns
        let privacyPatterns = [
            ("CLLocationManager", "Location access"),
            ("AVCaptureDevice", "Camera/microphone access"),
            ("CNContactStore", "Contacts access"),
            ("PHPhotoLibrary", "Photo library access"),
            ("HealthKit", "Health data access")
        ]
        
        let swiftFiles = findSwiftFiles()
        
        for file in swiftFiles {
            guard let content = try? String(contentsOfFile: file) else { continue }
            let lines = content.components(separatedBy: .newlines)
            
            for (lineIndex, line) in lines.enumerated() {
                for (pattern, description) in privacyPatterns {
                    if line.contains(pattern) {
                        issues.append(SecurityIssue(
                            file: file,
                            line: lineIndex + 1,
                            severity: .info,
                            category: .privacy,
                            description: description,
                            recommendation: "Ensure proper privacy permissions and usage descriptions"
                        ))
                    }
                }
            }
        }
        
        return issues
    }
    
    private static func scanForCodeQualityIssues() -> [SecurityIssue] {
        var issues: [SecurityIssue] = []
        
        let codeQualityPatterns = [
            ("force unwrap", "!"),
            ("force cast", " as!"),
            ("try!", "Forced try"),
            ("TODO", "Unfinished code"),
            ("FIXME", "Code requiring fixes"),
            ("HACK", "Temporary solution")
        ]
        
        let swiftFiles = findSwiftFiles()
        
        for file in swiftFiles {
            guard let content = try? String(contentsOfFile: file) else { continue }
            let lines = content.components(separatedBy: .newlines)
            
            for (lineIndex, line) in lines.enumerated() {
                for (description, pattern) in codeQualityPatterns {
                    if line.contains(pattern) && !line.trimmingCharacters(in: .whitespaces).hasPrefix("//") {
                        let severity: SecurityIssue.Severity = pattern.contains("!") ? .medium : .low
                        issues.append(SecurityIssue(
                            file: file,
                            line: lineIndex + 1,
                            severity: severity,
                            category: .codeQuality,
                            description: description,
                            recommendation: "Use safe programming practices and complete TODO items"
                        ))
                    }
                }
            }
        }
        
        return issues
    }
    
    private static func scanForPermissionIssues() -> [SecurityIssue] {
        var issues: [SecurityIssue] = []
        
        // Check Info.plist for permission usage descriptions
        let requiredPermissions = [
            "NSCameraUsageDescription",
            "NSMicrophoneUsageDescription",
            "NSLocationWhenInUseUsageDescription",
            "NSPhotoLibraryUsageDescription"
        ]
        
        // This would require parsing Info.plist in a real implementation
        issues.append(SecurityIssue(
            file: "Info.plist",
            line: 0,
            severity: .info,
            category: .permissions,
            description: "Verify all required permission usage descriptions are present",
            recommendation: "Ensure Info.plist contains appropriate usage descriptions for all permissions"
        ))
        
        return issues
    }
    
    private static func findSwiftFiles() -> [String] {
        let result = executeShellCommand("find Sources -name '*.swift' -type f")
        return result.output.components(separatedBy: .newlines).filter { !$0.isEmpty }
    }
    
    private static func findAllSourceFiles() -> [String] {
        let result = executeShellCommand("find . -name '*.swift' -o -name '*.plist' -o -name '*.xcconfig' | grep -v .build")
        return result.output.components(separatedBy: .newlines).filter { !$0.isEmpty }
    }
    
    private static func executeShellCommand(_ command: String) -> (output: String, exitCode: Int32) {
        let process = Process()
        let pipe = Pipe()
        
        process.standardOutput = pipe
        process.standardError = pipe
        process.arguments = ["-c", command]
        process.launchPath = "/bin/bash"
        
        process.launch()
        process.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""
        
        return (output, process.terminationStatus)
    }
    
    private static func generateSecurityReport(issues: [SecurityIssue]) {
        let groupedIssues = Dictionary(grouping: issues) { $0.severity }
        
        let report = """
        
        🔒 SECURITY SCAN REPORT - DogTV+
        ════════════════════════════════════════════════════════════════
        
        📊 SUMMARY:
        \(SecurityIssue.Severity.allCases.map { severity in
            let count = groupedIssues[severity]?.count ?? 0
            return "   \(severity.emoji) \(severity.rawValue): \(count)"
        }.joined(separator: "\n"))
        
        Total Issues: \(issues.count)
        
        ════════════════════════════════════════════════════════════════
        
        📝 DETAILED FINDINGS:
        
        \(issues.map { formatIssue($0) }.joined(separator: "\n\n"))
        
        ════════════════════════════════════════════════════════════════
        
        🎯 SECURITY SCORE: \(calculateSecurityScore(issues))/100
        
        """
        
        print(report)
        
        // Save report to file
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let fileName = "security_scan_\(formatter.string(from: Date())).txt"
        try? report.write(toFile: fileName, atomically: true, encoding: .utf8)
        
        print("💾 Security report saved to: \(fileName)")
    }
    
    private static func formatIssue(_ issue: SecurityIssue) -> String {
        return """
        \(issue.severity.emoji) [\(issue.severity.rawValue)] \(issue.category.rawValue)
        File: \(issue.file):\(issue.line)
        Issue: \(issue.description)
        Fix: \(issue.recommendation)
        """
    }
    
    private static func calculateSecurityScore(_ issues: [SecurityIssue]) -> Int {
        let weights = [
            SecurityIssue.Severity.critical: 25,
            SecurityIssue.Severity.high: 15,
            SecurityIssue.Severity.medium: 8,
            SecurityIssue.Severity.low: 3,
            SecurityIssue.Severity.info: 1
        ]
        
        let totalDeductions = issues.reduce(0) { sum, issue in
            sum + (weights[issue.severity] ?? 0)
        }
        
        return max(0, 100 - totalDeductions)
    }
}

// Execute security scan
let issues = SecurityScanner.scanProject()
let criticalIssues = issues.filter { $0.severity == .critical }

if !criticalIssues.isEmpty {
    print("\n🚨 CRITICAL SECURITY ISSUES FOUND!")
    print("Please address these issues before deployment.")
    exit(1)
} else {
    print("\n✅ No critical security issues found.")
    exit(0)
}