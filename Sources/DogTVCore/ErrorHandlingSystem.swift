import Foundation
import SwiftUI
import Combine

/// A comprehensive error handling and recovery system for DogTV+
public class ErrorHandlingSystem: ObservableObject {
    @Published public var currentError: AppError?
    @Published public var errorHistory: [AppError] = []
    @Published public var isShowingError: Bool = false
    @Published public var isRecovering: Bool = false
    @Published public var recoverySuggestions: [String] = []
    
    private var cancellables = Set<AnyCancellable>()
    private let maxErrorHistory = 50
    
    public init() {
        setupErrorObservers()
    }
    
    // MARK: - Public Methods
    
    /// Handle and display user-friendly errors
    public func handleError(_ error: Error) {
        let appError = convertToAppError(error)
        
        DispatchQueue.main.async {
            self.currentError = appError
            self.isShowingError = true
            self.addToHistory(appError)
            self.generateRecoverySuggestions(for: appError)
        }
        
        // Log error for analytics
        logError(appError)
    }
    
    /// Dismiss current error
    public func dismissError() {
        isShowingError = false
        currentError = nil
        recoverySuggestions = []
    }
    
    /// Retry the last failed operation
    public func retryLastOperation() {
        guard let error = currentError else { return }
        
        isRecovering = true
        
        // Attempt recovery based on error type
        switch error.type {
        case .network:
            retryNetworkOperation()
        case .authentication:
            retryAuthentication()
        case .data:
            retryDataOperation()
        case .permission:
            retryPermissionRequest()
        case .system:
            retrySystemOperation()
        }
    }
    
    /// Clear error history
    public func clearErrorHistory() {
        errorHistory.removeAll()
    }
    
    /// Get error statistics
    public func getErrorStatistics() -> ErrorStatistics {
        let totalErrors = errorHistory.count
        let errorTypes = Dictionary(grouping: errorHistory, by: { $0.type })
            .mapValues { $0.count }
        
        let mostCommonError = errorHistory
            .map { $0.type }
            .reduce(into: [:]) { counts, type in
                counts[type, default: 0] += 1
            }
            .max(by: { $0.value < $1.value })?.key
        
        return ErrorStatistics(
            totalErrors: totalErrors,
            errorTypes: errorTypes,
            mostCommonError: mostCommonError,
            lastErrorDate: errorHistory.last?.timestamp
        )
    }
    
    // MARK: - Private Methods
    
    private func setupErrorObservers() {
        // Monitor for new errors
        $currentError
            .compactMap { $0 }
            .sink { [weak self] error in
                self?.handleNewError(error)
            }
            .store(in: &cancellables)
    }
    
    private func convertToAppError(_ error: Error) -> AppError {
        if let appError = error as? AppError {
            return appError
        }
        
        // Convert system errors to app errors
        switch error {
        case let networkError as NetworkError:
            return AppError(
                id: UUID().uuidString,
                type: .network,
                title: "Network Error",
                message: networkError.localizedDescription,
                severity: .medium,
                timestamp: Date(),
                originalError: error
            )
        case let userError as UserError:
            return AppError(
                id: UUID().uuidString,
                type: .authentication,
                title: "User Error",
                message: userError.localizedDescription,
                severity: .medium,
                timestamp: Date(),
                originalError: error
            )
        default:
            return AppError(
                id: UUID().uuidString,
                type: .system,
                title: "System Error",
                message: error.localizedDescription,
                severity: .high,
                timestamp: Date(),
                originalError: error
            )
        }
    }
    
    private func addToHistory(_ error: AppError) {
        errorHistory.append(error)
        
        // Keep history size manageable
        if errorHistory.count > maxErrorHistory {
            errorHistory.removeFirst()
        }
    }
    
    private func generateRecoverySuggestions(for error: AppError) {
        var suggestions: [String] = []
        
        switch error.type {
        case .network:
            suggestions = [
                "Check your internet connection",
                "Try again in a few moments",
                "Switch between WiFi and cellular",
                "Restart the app"
            ]
        case .authentication:
            suggestions = [
                "Check your login credentials",
                "Try logging in again",
                "Reset your password if needed",
                "Contact support if the problem persists"
            ]
        case .data:
            suggestions = [
                "Try refreshing the content",
                "Check your device storage",
                "Restart the app",
                "Clear app cache if needed"
            ]
        case .permission:
            suggestions = [
                "Grant the required permissions in Settings",
                "Go to Settings > Privacy & Security",
                "Enable the requested features",
                "Contact support for assistance"
            ]
        case .system:
            suggestions = [
                "Restart the app",
                "Update to the latest version",
                "Restart your device",
                "Contact support for technical assistance"
            ]
        }
        
        recoverySuggestions = suggestions
    }
    
    private func handleNewError(_ error: AppError) {
        // Show user-friendly notification
        showErrorNotification(error)
        
        // Track error for analytics
        trackErrorForAnalytics(error)
    }
    
    private func showErrorNotification(_ error: AppError) {
        // In a real implementation, this would show a system notification
        print("Error Notification: \(error.title) - \(error.message)")
    }
    
    private func trackErrorForAnalytics(_ error: AppError) {
        // Send error to analytics service
        let analyticsData = AnalyticsData(
            userId: "current_user_id",
            eventType: "error_occurred",
            eventData: [
                "error_type": error.type.rawValue,
                "error_severity": error.severity.rawValue,
                "error_title": error.title
            ],
            sessionId: "current_session_id"
        )
        
        // In a real implementation, this would be sent to analytics
        print("Error Analytics: \(analyticsData)")
    }
    
    private func logError(_ error: AppError) {
        // Log error to file or remote service
        let logEntry = """
        [\(Date())] Error: \(error.title)
        Type: \(error.type.rawValue)
        Severity: \(error.severity.rawValue)
        Message: \(error.message)
        User ID: current_user_id
        Session ID: current_session_id
        """
        
        print(logEntry)
    }
    
    // MARK: - Recovery Methods
    
    private func retryNetworkOperation() {
        // Simulate network retry
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.isRecovering = false
            self.dismissError()
        }
    }
    
    private func retryAuthentication() {
        // Simulate authentication retry
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isRecovering = false
            self.dismissError()
        }
    }
    
    private func retryDataOperation() {
        // Simulate data operation retry
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.isRecovering = false
            self.dismissError()
        }
    }
    
    private func retryPermissionRequest() {
        // Simulate permission retry
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isRecovering = false
            self.dismissError()
        }
    }
    
    private func retrySystemOperation() {
        // Simulate system operation retry
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.isRecovering = false
            self.dismissError()
        }
    }
}

// MARK: - Data Models

public struct AppError: Identifiable, Codable {
    public let id: String
    public let type: ErrorType
    public let title: String
    public let message: String
    public let severity: ErrorSeverity
    public let timestamp: Date
    public let originalError: Error?
    
    public init(id: String, type: ErrorType, title: String, message: String, severity: ErrorSeverity, timestamp: Date, originalError: Error?) {
        self.id = id
        self.type = type
        self.title = title
        self.message = message
        self.severity = severity
        self.timestamp = timestamp
        self.originalError = originalError
    }
}

public enum ErrorType: String, CaseIterable, Codable {
    case network = "Network"
    case authentication = "Authentication"
    case data = "Data"
    case permission = "Permission"
    case system = "System"
    
    var icon: String {
        switch self {
        case .network: return "wifi.slash"
        case .authentication: return "person.crop.circle.badge.exclamationmark"
        case .data: return "exclamationmark.triangle"
        case .permission: return "lock.shield"
        case .system: return "gear.badge.exclamationmark"
        }
    }
    
    var color: String {
        switch self {
        case .network: return "orange"
        case .authentication: return "red"
        case .data: return "yellow"
        case .permission: return "purple"
        case .system: return "gray"
        }
    }
}

public enum ErrorSeverity: String, CaseIterable, Codable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case critical = "Critical"
    
    var shouldShowUser: Bool {
        switch self {
        case .low: return false
        case .medium, .high, .critical: return true
        }
    }
    
    var requiresImmediateAction: Bool {
        switch self {
        case .low, .medium: return false
        case .high, .critical: return true
        }
    }
}

public struct ErrorStatistics {
    public let totalErrors: Int
    public let errorTypes: [ErrorType: Int]
    public let mostCommonError: ErrorType?
    public let lastErrorDate: Date?
    
    public init(totalErrors: Int, errorTypes: [ErrorType: Int], mostCommonError: ErrorType?, lastErrorDate: Date?) {
        self.totalErrors = totalErrors
        self.errorTypes = errorTypes
        self.mostCommonError = mostCommonError
        self.lastErrorDate = lastErrorDate
    }
}

// MARK: - Error Views

public struct ErrorAlertView: View {
    @ObservedObject var errorHandler: ErrorHandlingSystem
    let error: AppError
    
    public init(errorHandler: ErrorHandlingSystem, error: AppError) {
        self.errorHandler = errorHandler
        self.error = error
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            // Error icon
            Image(systemName: error.type.icon)
                .font(.system(size: 50))
                .foregroundColor(Color(error.type.color))
            
            // Error title
            Text(error.title)
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            // Error message
            Text(error.message)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            // Recovery suggestions
            if !errorHandler.recoverySuggestions.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Try these solutions:")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    ForEach(errorHandler.recoverySuggestions, id: \.self) { suggestion in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.caption)
                            
                            Text(suggestion)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
            
            // Action buttons
            HStack(spacing: 15) {
                Button("Dismiss") {
                    errorHandler.dismissError()
                }
                .foregroundColor(.secondary)
                
                Button("Retry") {
                    errorHandler.retryLastOperation()
                }
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.blue)
                .cornerRadius(8)
                .disabled(errorHandler.isRecovering)
            }
            
            if errorHandler.isRecovering {
                ProgressView("Recovering...")
                    .progressViewStyle(CircularProgressViewStyle())
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 10)
    }
}

public struct ErrorHistoryView: View {
    @ObservedObject var errorHandler: ErrorHandlingSystem
    
    public init(errorHandler: ErrorHandlingSystem) {
        self.errorHandler = errorHandler
    }
    
    public var body: some View {
        NavigationView {
            List {
                ForEach(errorHandler.errorHistory) { error in
                    ErrorHistoryRow(error: error)
                }
            }
            .navigationTitle("Error History")
            .navigationBarItems(trailing: Button("Clear") {
                errorHandler.clearErrorHistory()
            })
        }
    }
}

public struct ErrorHistoryRow: View {
    let error: AppError
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: error.type.icon)
                    .foregroundColor(Color(error.type.color))
                
                Text(error.title)
                    .font(.headline)
                
                Spacer()
                
                Text(error.timestamp, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(error.message)
                .font(.body)
                .foregroundColor(.secondary)
            
            HStack {
                Text(error.type.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(error.type.color).opacity(0.2))
                    .cornerRadius(4)
                
                Text(error.severity.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(error.severity == .critical ? "red" : "orange").opacity(0.2))
                    .cornerRadius(4)
                
                Spacer()
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Error Modifiers

public extension View {
    func handleErrors(with errorHandler: ErrorHandlingSystem) -> some View {
        self
            .alert(isPresented: $errorHandler.isShowingError) {
                Alert(
                    title: Text(errorHandler.currentError?.title ?? "Error"),
                    message: Text(errorHandler.currentError?.message ?? "An unknown error occurred"),
                    primaryButton: .default(Text("Retry")) {
                        errorHandler.retryLastOperation()
                    },
                    secondaryButton: .cancel(Text("Dismiss")) {
                        errorHandler.dismissError()
                    }
                )
            }
    }
} 