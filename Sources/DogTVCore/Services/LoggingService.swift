// swiftlint:disable import_organization mark_usage file_length
import Foundation
import os.log
// swiftlint:enable import_organization

/// Secure logging service for DogTV+ with configurable log levels
@available(iOS 17.0, tvOS 17.0, macOS 10.15, *)
public class LoggingService: ObservableObject {
    
    // MARK: - Shared Instance
    public static let shared = LoggingService()
    
    // MARK: - Log Categories
    
    private let generalLog = OSLog(subsystem: "com.dogtv.app", category: "general")
    private let securityLog = OSLog(subsystem: "com.dogtv.app", category: "security")
    private let audioLog = OSLog(subsystem: "com.dogtv.app", category: "audio")
    private let videoLog = OSLog(subsystem: "com.dogtv.app", category: "video")
    private let analyticsLog = OSLog(subsystem: "com.dogtv.app", category: "analytics")
    private let networkLog = OSLog(subsystem: "com.dogtv.app", category: "network")
    private let errorLog = OSLog(subsystem: "com.dogtv.app", category: "error")
    
    // MARK: - Configuration
    
    @Published public private(set) var logLevel: LogLevel = .info
    @Published public private(set) var isLoggingEnabled: Bool = true
    
    // MARK: - Initialization
    
    private init() {
        configureLogging()
    }
    
    // MARK: - Configuration
    
    private func configureLogging() {
        #if DEBUG
        logLevel = .debug
        #else
        logLevel = .info
        #endif
        
        // Disable logging in production for security
        #if !DEBUG
        isLoggingEnabled = false
        #endif
    }
    
    // MARK: - Public API
    
    /// Log a debug message
    public func debug(_ message: String, category: LogCategory = .general, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .debug, category: category, file: file, function: function, line: line)
    }
    
    /// Log an info message
    public func info(_ message: String, category: LogCategory = .general, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .info, category: category, file: file, function: function, line: line)
    }
    
    /// Log a warning message
    public func warning(_ message: String, category: LogCategory = .general, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .warning, category: category, file: file, function: function, line: line)
    }
    
    /// Log an error message
    public func error(_ message: String, category: LogCategory = .general, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .error, category: category, file: file, function: function, line: line)
    }
    
    /// Log a critical error message
    public func critical(_ message: String, category: LogCategory = .general, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .critical, category: category, file: file, function: function, line: line)
    }
    
    /// Set log level
    public func setLogLevel(_ level: LogLevel) {
        logLevel = level
    }
    
    /// Enable or disable logging
    public func setLoggingEnabled(_ enabled: Bool) {
        isLoggingEnabled = enabled
    }
    
    // MARK: - Private Methods
    
    private func log(_ message: String, level: LogLevel, category: LogCategory, file: String, function: String, line: Int) {
        guard isLoggingEnabled && level.rawValue >= logLevel.rawValue else { return }
        
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        let logMessage = "[\(fileName):\(line)] \(function): \(message)"
        
        let osLog = getOSLog(for: category)
        let osLogType = getOSLogType(for: level)
        
        os_log("%{public}@", log: osLog, type: osLogType, logMessage)
        
        // In debug builds, also print to console for development
        #if DEBUG
        let emoji = getEmoji(for: level)
        print("\(emoji) [\(category.rawValue.uppercased())] \(logMessage)")
        #endif
    }
    
    private func getOSLog(for category: LogCategory) -> OSLog {
        switch category {
        case .general:
            return generalLog
        case .security:
            return securityLog
        case .audio:
            return audioLog
        case .video:
            return videoLog
        case .analytics:
            return analyticsLog
        case .network:
            return networkLog
        case .error:
            return errorLog
        }
    }
    
    private func getOSLogType(for level: LogLevel) -> OSLogType {
        switch level {
        case .debug:
            return .debug
        case .info:
            return .info
        case .warning:
            return .default
        case .error:
            return .error
        case .critical:
            return .fault
        }
    }
    
    private func getEmoji(for level: LogLevel) -> String {
        switch level {
        case .debug:
            return "🔍"
        case .info:
            return "ℹ️"
        case .warning:
            return "⚠️"
        case .error:
            return "❌"
        case .critical:
            return "🚨"
        }
    }
}

// MARK: - Supporting Models

/// Log levels
public enum LogLevel: Int, CaseIterable, Codable, Sendable {
    case debug = 0
    case info = 1
    case warning = 2
    case error = 3
    case critical = 4
    
    public var description: String {
        switch self {
        case .debug: return "Debug"
        case .info: return "Info"
        case .warning: return "Warning"
        case .error: return "Error"
        case .critical: return "Critical"
        }
    }
}

/// Log categories
public enum LogCategory: String, CaseIterable, Codable, Sendable {
    case general = "general"
    case security = "security"
    case audio = "audio"
    case video = "video"
    case analytics = "analytics"
    case network = "network"
    case error = "error"
    
    public var description: String {
        switch self {
        case .general: return "General"
        case .security: return "Security"
        case .audio: return "Audio"
        case .video: return "Video"
        case .analytics: return "Analytics"
        case .network: return "Network"
        case .error: return "Error"
        }
    }
}

// MARK: - Convenience Extensions

/// Convenience logging functions
public func logDebug(_ message: String, category: LogCategory = .general, file: String = #file, function: String = #function, line: Int = #line) {
    LoggingService.shared.debug(message, category: category, file: file, function: function, line: line)
}

public func logInfo(_ message: String, category: LogCategory = .general, file: String = #file, function: String = #function, line: Int = #line) {
    LoggingService.shared.info(message, category: category, file: file, function: function, line: line)
}

public func logWarning(_ message: String, category: LogCategory = .general, file: String = #file, function: String = #function, line: Int = #line) {
    LoggingService.shared.warning(message, category: category, file: file, function: function, line: line)
}

public func logError(_ message: String, category: LogCategory = .general, file: String = #file, function: String = #function, line: Int = #line) {
    LoggingService.shared.error(message, category: category, file: file, function: function, line: line)
}

public func logCritical(_ message: String, category: LogCategory = .general, file: String = #file, function: String = #function, line: Int = #line) {
    LoggingService.shared.critical(message, category: category, file: file, function: function, line: line)
} 