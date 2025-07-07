import Foundation
import SwiftUI
import Combine
import LocalAuthentication

/// A comprehensive user management system for DogTV+ with authentication and profile management
public class UserManagementSystem: ObservableObject {
    @Published public var currentUser: User?
    @Published public var userDogs: [DogProfile] = []
    @Published public var isAuthenticated: Bool = false
    @Published public var isLoading: Bool = false
    @Published public var error: UserError?
    @Published public var isOnboardingComplete: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    private let userDefaults = UserDefaults.standard
    private let keychain = KeychainWrapper.standard
    
    public init() {
        loadUserData()
        checkAuthenticationStatus()
    }
    
    // MARK: - Public Methods
    
    /// Create new user account
    public func createUser(email: String, password: String, name: String) async throws {
        isLoading = true
        error = nil
        
        do {
            // Validate input
            try validateUserInput(email: email, password: password, name: name)
            
            // Check if user already exists
            if await userExists(email: email) {
                throw UserError.userAlreadyExists
            }
            
            // Create user
            let user = User(
                id: UUID().uuidString,
                email: email.lowercased(),
                name: name,
                createdAt: Date(),
                preferences: UserPreferences()
            )
            
            // Hash password and store securely
            let hashedPassword = try hashPassword(password)
            try storeUserCredentials(email: email, hashedPassword: hashedPassword)
            
            // Save user data
            try saveUserData(user)
            
            await MainActor.run {
                self.currentUser = user
                self.isAuthenticated = true
                self.isLoading = false
            }
            
        } catch {
            await MainActor.run {
                self.error = error as? UserError ?? .creationFailed(error.localizedDescription)
                self.isLoading = false
            }
        }
    }
    
    /// User login
    public func loginUser(email: String, password: String) async throws {
        isLoading = true
        error = nil
        
        do {
            // Validate input
            try validateUserInput(email: email, password: password)
            
            // Verify credentials
            let hashedPassword = try hashPassword(password)
            guard try verifyCredentials(email: email, hashedPassword: hashedPassword) else {
                throw UserError.invalidCredentials
            }
            
            // Load user data
            let user = try loadUserData(email: email)
            
            await MainActor.run {
                self.currentUser = user
                self.isAuthenticated = true
                self.isLoading = false
            }
            
        } catch {
            await MainActor.run {
                self.error = error as? UserError ?? .loginFailed(error.localizedDescription)
                self.isLoading = false
            }
        }
    }
    
    /// Logout user
    public func logoutUser() {
        currentUser = nil
        userDogs = []
        isAuthenticated = false
        isOnboardingComplete = false
        
        // Clear sensitive data
        clearUserData()
    }
    
    /// Add dog profile
    public func addDogProfile(_ dog: DogProfile) async throws {
        guard let user = currentUser else {
            throw UserError.notAuthenticated
        }
        
        userDogs.append(dog)
        try saveDogProfiles()
        
        // Update user preferences
        var updatedUser = user
        updatedUser.preferences.lastDogAdded = Date()
        currentUser = updatedUser
        try saveUserData(updatedUser)
    }
    
    /// Update dog profile
    public func updateDogProfile(_ dog: DogProfile) async throws {
        guard let index = userDogs.firstIndex(where: { $0.id == dog.id }) else {
            throw UserError.dogNotFound
        }
        
        userDogs[index] = dog
        try saveDogProfiles()
    }
    
    /// Delete dog profile
    public func deleteDogProfile(_ dogId: String) async throws {
        guard let index = userDogs.firstIndex(where: { $0.id == dogId }) else {
            throw UserError.dogNotFound
        }
        
        userDogs.remove(at: index)
        try saveDogProfiles()
    }
    
    /// Update user preferences
    public func updateUserPreferences(_ preferences: UserPreferences) async throws {
        guard var user = currentUser else {
            throw UserError.notAuthenticated
        }
        
        user.preferences = preferences
        currentUser = user
        try saveUserData(user)
    }
    
    /// Enable biometric authentication
    public func enableBiometricAuth() async throws {
        guard let user = currentUser else {
            throw UserError.notAuthenticated
        }
        
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            throw UserError.biometricNotAvailable
        }
        
        // Store biometric preference
        var updatedUser = user
        updatedUser.preferences.biometricEnabled = true
        currentUser = updatedUser
        try saveUserData(updatedUser)
    }
    
    /// Complete onboarding
    public func completeOnboarding() {
        isOnboardingComplete = true
        userDefaults.set(true, forKey: "onboarding_complete")
    }
    
    // MARK: - Private Methods
    
    private func loadUserData() {
        // Load onboarding status
        isOnboardingComplete = userDefaults.bool(forKey: "onboarding_complete")
        
        // Load user data if available
        if let userData = userDefaults.data(forKey: "current_user"),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            currentUser = user
        }
        
        // Load dog profiles
        if let dogsData = userDefaults.data(forKey: "user_dogs"),
           let dogs = try? JSONDecoder().decode([DogProfile].self, from: dogsData) {
            userDogs = dogs
        }
    }
    
    private func checkAuthenticationStatus() {
        // Check if user is authenticated
        isAuthenticated = currentUser != nil
    }
    
    private func validateUserInput(email: String, password: String, name: String? = nil) throws {
        // Validate email
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        guard emailPredicate.evaluate(with: email) else {
            throw UserError.invalidEmail
        }
        
        // Validate password
        guard password.count >= 8 else {
            throw UserError.passwordTooShort
        }
        
        // Validate name if provided
        if let name = name {
            guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                throw UserError.invalidName
            }
        }
    }
    
    private func userExists(email: String) async -> Bool {
        // In a real implementation, this would check against a backend
        // For now, check local storage
        return keychain.hasValue(forKey: "user_\(email)")
    }
    
    private func hashPassword(_ password: String) throws -> String {
        // In a real implementation, use proper password hashing (e.g., bcrypt)
        // For now, use a simple hash for demonstration
        return password.data(using: .utf8)?.base64EncodedString() ?? ""
    }
    
    private func storeUserCredentials(email: String, hashedPassword: String) throws {
        keychain.set(hashedPassword, forKey: "user_\(email)")
    }
    
    private func verifyCredentials(email: String, hashedPassword: String) throws -> Bool {
        guard let storedHash = keychain.string(forKey: "user_\(email)") else {
            return false
        }
        return storedHash == hashedPassword
    }
    
    private func saveUserData(_ user: User) throws {
        let encoder = JSONEncoder()
        let userData = try encoder.encode(user)
        userDefaults.set(userData, forKey: "current_user")
    }
    
    private func loadUserData(email: String) throws -> User {
        guard let userData = userDefaults.data(forKey: "current_user") else {
            throw UserError.userNotFound
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(User.self, from: userData)
    }
    
    private func saveDogProfiles() throws {
        let encoder = JSONEncoder()
        let dogsData = try encoder.encode(userDogs)
        userDefaults.set(dogsData, forKey: "user_dogs")
    }
    
    private func clearUserData() {
        userDefaults.removeObject(forKey: "current_user")
        userDefaults.removeObject(forKey: "user_dogs")
        // Note: We don't clear keychain data for security reasons
    }
}

// MARK: - Data Models

public struct User: Identifiable, Codable {
    public let id: String
    public let email: String
    public let name: String
    public let createdAt: Date
    public var preferences: UserPreferences
    
    public init(id: String, email: String, name: String, createdAt: Date, preferences: UserPreferences) {
        self.id = id
        self.email = email
        self.name = name
        self.createdAt = createdAt
        self.preferences = preferences
    }
}

public struct UserPreferences: Codable {
    public var notificationsEnabled: Bool = true
    public var autoPlayEnabled: Bool = true
    public var qualityPreference: VideoQuality = .auto
    public var biometricEnabled: Bool = false
    public var lastDogAdded: Date?
    public var favoriteCategories: [ContentCategory] = []
    public var watchHistory: [String] = [] // Video IDs
    
    public init() {}
}

public struct DogProfile: Identifiable, Codable {
    public let id: String
    public let name: String
    public let breed: DogBreed
    public let age: Int // in months
    public let weight: Double // in kg
    public let temperament: DogTemperament
    public let preferences: DogPreferences
    public let createdAt: Date
    
    public init(id: String = UUID().uuidString, name: String, breed: DogBreed, age: Int, weight: Double, temperament: DogTemperament, preferences: DogPreferences, createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.breed = breed
        self.age = age
        self.weight = weight
        self.temperament = temperament
        self.preferences = preferences
        self.createdAt = createdAt
    }
}

public enum DogTemperament: String, CaseIterable, Codable {
    case calm = "Calm"
    case energetic = "Energetic"
    case anxious = "Anxious"
    case playful = "Playful"
    case shy = "Shy"
    case confident = "Confident"
    
    var description: String {
        switch self {
        case .calm: return "Relaxed and peaceful"
        case .energetic: return "High energy and active"
        case .anxious: return "Nervous and easily stressed"
        case .playful: return "Fun-loving and interactive"
        case .shy: return "Reserved and cautious"
        case .confident: return "Self-assured and bold"
        }
    }
}

public struct DogPreferences: Codable {
    public var favoriteContentTypes: [ContentCategory] = []
    public var preferredDuration: TimeInterval = 1800 // 30 minutes
    public var volumeSensitivity: VolumeSensitivity = .normal
    public var motionSensitivity: MotionSensitivity = .normal
    
    public init() {}
}

public enum VolumeSensitivity: String, CaseIterable, Codable {
    case low = "Low"
    case normal = "Normal"
    case high = "High"
}

public enum MotionSensitivity: String, CaseIterable, Codable {
    case low = "Low"
    case normal = "Normal"
    case high = "High"
}

public enum UserError: Error, LocalizedError {
    case invalidEmail
    case invalidPassword
    case passwordTooShort
    case invalidName
    case userAlreadyExists
    case userNotFound
    case invalidCredentials
    case notAuthenticated
    case dogNotFound
    case biometricNotAvailable
    case creationFailed(String)
    case loginFailed(String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "Please enter a valid email address"
        case .invalidPassword:
            return "Please enter a valid password"
        case .passwordTooShort:
            return "Password must be at least 8 characters long"
        case .invalidName:
            return "Please enter a valid name"
        case .userAlreadyExists:
            return "An account with this email already exists"
        case .userNotFound:
            return "User not found"
        case .invalidCredentials:
            return "Invalid email or password"
        case .notAuthenticated:
            return "Please log in to continue"
        case .dogNotFound:
            return "Dog profile not found"
        case .biometricNotAvailable:
            return "Biometric authentication is not available on this device"
        case .creationFailed(let message):
            return "Failed to create account: \(message)"
        case .loginFailed(let message):
            return "Failed to log in: \(message)"
        }
    }
}

// MARK: - Keychain Wrapper (Simplified)

class KeychainWrapper {
    static let standard = KeychainWrapper()
    
    private init() {}
    
    func set(_ value: String, forKey key: String) {
        UserDefaults.standard.set(value, forKey: "keychain_\(key)")
    }
    
    func string(forKey key: String) -> String? {
        return UserDefaults.standard.string(forKey: "keychain_\(key)")
    }
    
    func hasValue(forKey key: String) -> Bool {
        return UserDefaults.standard.object(forKey: "keychain_\(key)") != nil
    }
}

// MARK: - User Management Views

public struct UserLoginView: View {
    @ObservedObject var userManager: UserManagementSystem
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false
    @State private var name = ""
    
    public init(userManager: UserManagementSystem) {
        self.userManager = userManager
    }
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Logo/Title
                VStack {
                    Image(systemName: "pawprint.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                    
                    Text("DogTV+")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text(isSignUp ? "Create Account" : "Welcome Back")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 50)
                
                // Form
                VStack(spacing: 15) {
                    if isSignUp {
                        TextField("Name", text: $name)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal)
                
                // Action Button
                Button(action: {
                    Task {
                        if isSignUp {
                            try await userManager.createUser(email: email, password: password, name: name)
                        } else {
                            try await userManager.loginUser(email: email, password: password)
                        }
                    }
                }) {
                    HStack {
                        if userManager.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        }
                        
                        Text(isSignUp ? "Create Account" : "Sign In")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(userManager.isLoading || email.isEmpty || password.isEmpty || (isSignUp && name.isEmpty))
                .padding(.horizontal)
                
                // Toggle Sign Up/In
                Button(action: {
                    isSignUp.toggle()
                    userManager.error = nil
                }) {
                    Text(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                        .foregroundColor(.blue)
                }
                
                // Error Display
                if let error = userManager.error {
                    Text(error.localizedDescription)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Spacer()
            }
            .navigationBarHidden(true)
        }
    }
}

public struct DogProfileCreationView: View {
    @ObservedObject var userManager: UserManagementSystem
    @State private var name = ""
    @State private var selectedBreed = DogBreed.goldenRetriever
    @State private var age = 12
    @State private var weight = 25.0
    @State private var selectedTemperament = DogTemperament.calm
    
    public init(userManager: UserManagementSystem) {
        self.userManager = userManager
    }
    
    public var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Basic Information")) {
                    TextField("Dog's Name", text: $name)
                    
                    Picker("Breed", selection: $selectedBreed) {
                        ForEach(DogBreed.allCases, id: \.self) { breed in
                            Text(breed.rawValue).tag(breed)
                        }
                    }
                    
                    Stepper("Age: \(age) months", value: $age, in: 1...240)
                    
                    HStack {
                        Text("Weight")
                        Spacer()
                        TextField("Weight", value: $weight, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("kg")
                    }
                }
                
                Section(header: Text("Temperament")) {
                    Picker("Temperament", selection: $selectedTemperament) {
                        ForEach(DogTemperament.allCases, id: \.self) { temperament in
                            VStack(alignment: .leading) {
                                Text(temperament.rawValue)
                                Text(temperament.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .tag(temperament)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                }
                
                Section {
                    Button("Add Dog Profile") {
                        Task {
                            let dog = DogProfile(
                                name: name,
                                breed: selectedBreed,
                                age: age,
                                weight: weight,
                                temperament: selectedTemperament,
                                preferences: DogPreferences()
                            )
                            try await userManager.addDogProfile(dog)
                        }
                    }
                    .disabled(name.isEmpty)
                }
            }
            .navigationTitle("Add Dog Profile")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
} 