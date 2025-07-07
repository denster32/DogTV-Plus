import SwiftUI
import Combine

/// A comprehensive onboarding system for DogTV+ with multi-step flow and user guidance
public class OnboardingSystem: ObservableObject {
    @Published public var currentStep: OnboardingStep = .welcome
    @Published public var userProfile: UserProfile?
    @Published public var isOnboardingComplete: Bool = false
    @Published public var progress: Double = 0.0
    @Published public var canSkip: Bool = false
    @Published public var error: OnboardingError?
    
    private var cancellables = Set<AnyCancellable>()
    private let userDefaults = UserDefaults.standard
    
    public init() {
        loadOnboardingState()
        setupProgressTracking()
    }
    
    // MARK: - Public Methods
    
    /// Complete the onboarding flow
    public func completeOnboarding() async throws {
        guard let profile = userProfile else {
            throw OnboardingError.incompleteProfile
        }
        
        // Save onboarding completion
        userDefaults.set(true, forKey: "onboarding_complete")
        userDefaults.set(Date(), forKey: "onboarding_completed_date")
        
        // Save user profile
        try saveUserProfile(profile)
        
        await MainActor.run {
            isOnboardingComplete = true
            currentStep = .complete
        }
    }
    
    /// Move to next onboarding step
    public func nextStep() {
        guard let nextStep = currentStep.nextStep else {
            // Complete onboarding
            Task {
                try await completeOnboarding()
            }
            return
        }
        
        withAnimation(.easeInOut(duration: 0.5)) {
            currentStep = nextStep
        }
        
        updateProgress()
    }
    
    /// Move to previous onboarding step
    public func previousStep() {
        guard let previousStep = currentStep.previousStep else { return }
        
        withAnimation(.easeInOut(duration: 0.5)) {
            currentStep = previousStep
        }
        
        updateProgress()
    }
    
    /// Skip onboarding (if allowed)
    public func skipOnboarding() {
        guard canSkip else { return }
        
        Task {
            try await completeOnboarding()
        }
    }
    
    /// Update user profile during onboarding
    public func updateUserProfile(_ profile: UserProfile) {
        userProfile = profile
        saveOnboardingState()
    }
    
    /// Reset onboarding (for testing or re-onboarding)
    public func resetOnboarding() {
        userDefaults.removeObject(forKey: "onboarding_complete")
        userDefaults.removeObject(forKey: "onboarding_completed_date")
        userDefaults.removeObject(forKey: "onboarding_step")
        userDefaults.removeObject(forKey: "user_profile")
        
        currentStep = .welcome
        userProfile = nil
        isOnboardingComplete = false
        progress = 0.0
        error = nil
    }
    
    // MARK: - Private Methods
    
    private func loadOnboardingState() {
        isOnboardingComplete = userDefaults.bool(forKey: "onboarding_complete")
        
        if let stepData = userDefaults.data(forKey: "onboarding_step"),
           let step = try? JSONDecoder().decode(OnboardingStep.self, from: stepData) {
            currentStep = step
        }
        
        if let profileData = userDefaults.data(forKey: "user_profile"),
           let profile = try? JSONDecoder().decode(UserProfile.self, from: profileData) {
            userProfile = profile
        }
    }
    
    private func saveOnboardingState() {
        if let stepData = try? JSONEncoder().encode(currentStep) {
            userDefaults.set(stepData, forKey: "onboarding_step")
        }
        
        if let profile = userProfile,
           let profileData = try? JSONEncoder().encode(profile) {
            userDefaults.set(profileData, forKey: "user_profile")
        }
    }
    
    private func setupProgressTracking() {
        $currentStep
            .sink { [weak self] step in
                self?.updateProgress()
            }
            .store(in: &cancellables)
    }
    
    private func updateProgress() {
        let totalSteps = OnboardingStep.allCases.count
        let currentIndex = OnboardingStep.allCases.firstIndex(of: currentStep) ?? 0
        progress = Double(currentIndex) / Double(totalSteps - 1)
    }
    
    private func saveUserProfile(_ profile: UserProfile) throws {
        // Save to persistent storage
        let encoder = JSONEncoder()
        let data = try encoder.encode(profile)
        userDefaults.set(data, forKey: "user_profile_final")
    }
}

// MARK: - Data Models

public enum OnboardingStep: String, CaseIterable, Codable {
    case welcome = "Welcome"
    case introduction = "Introduction"
    case dogBreedSelection = "DogBreedSelection"
    case dogProfile = "DogProfile"
    case preferences = "Preferences"
    case features = "Features"
    case permissions = "Permissions"
    case complete = "Complete"
    
    var title: String {
        switch self {
        case .welcome: return "Welcome to DogTV+"
        case .introduction: return "About DogTV+"
        case .dogBreedSelection: return "Select Your Dog's Breed"
        case .dogProfile: return "Tell Us About Your Dog"
        case .preferences: return "Your Preferences"
        case .features: return "Discover Features"
        case .permissions: return "Permissions"
        case .complete: return "You're All Set!"
        }
    }
    
    var description: String {
        switch self {
        case .welcome: return "The ultimate entertainment and enrichment platform for your furry friend"
        case .introduction: return "Scientifically designed content to keep your dog engaged, relaxed, and happy"
        case .dogBreedSelection: return "Help us personalize content for your dog's specific needs"
        case .dogProfile: return "Let's get to know your dog better for the best experience"
        case .preferences: return "Customize your DogTV+ experience"
        case .features: return "Explore the amazing features that make DogTV+ special"
        case .permissions: return "We need a few permissions to provide the best experience"
        case .complete: return "Your DogTV+ journey begins now!"
        }
    }
    
    var canSkip: Bool {
        switch self {
        case .welcome, .introduction, .features:
            return true
        default:
            return false
        }
    }
    
    var nextStep: OnboardingStep? {
        guard let currentIndex = OnboardingStep.allCases.firstIndex(of: self) else { return nil }
        let nextIndex = currentIndex + 1
        return nextIndex < OnboardingStep.allCases.count ? OnboardingStep.allCases[nextIndex] : nil
    }
    
    var previousStep: OnboardingStep? {
        guard let currentIndex = OnboardingStep.allCases.firstIndex(of: self) else { return nil }
        let previousIndex = currentIndex - 1
        return previousIndex >= 0 ? OnboardingStep.allCases[previousIndex] : nil
    }
}

public struct UserProfile: Codable {
    public var name: String = ""
    public var email: String = ""
    public var selectedBreed: DogBreed?
    public var dogName: String = ""
    public var dogAge: Int = 12
    public var dogTemperament: DogTemperament = .calm
    public var preferences: OnboardingPreferences = OnboardingPreferences()
    public var permissions: OnboardingPermissions = OnboardingPermissions()
    
    public init() {}
}

public struct OnboardingPreferences: Codable {
    public var notificationsEnabled: Bool = true
    public var autoPlayEnabled: Bool = true
    public var qualityPreference: VideoQuality = .auto
    public var favoriteCategories: [ContentCategory] = []
    
    public init() {}
}

public struct OnboardingPermissions: Codable {
    public var cameraPermission: Bool = false
    public var notificationsPermission: Bool = false
    public var analyticsPermission: Bool = true
    
    public init() {}
}

public enum OnboardingError: Error, LocalizedError {
    case incompleteProfile
    case invalidStep
    case saveFailed(String)
    
    public var errorDescription: String? {
        switch self {
        case .incompleteProfile:
            return "Please complete your profile before continuing"
        case .invalidStep:
            return "Invalid onboarding step"
        case .saveFailed(let message):
            return "Failed to save profile: \(message)"
        }
    }
}

// MARK: - Onboarding Views

public struct OnboardingView: View {
    @StateObject private var onboardingSystem = OnboardingSystem()
    @Environment(\.dismiss) private var dismiss
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Progress bar
                ProgressView(value: onboardingSystem.progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    .padding()
                
                // Content area
                TabView(selection: $onboardingSystem.currentStep) {
                    WelcomeStepView(onboardingSystem: onboardingSystem)
                        .tag(OnboardingStep.welcome)
                    
                    IntroductionStepView(onboardingSystem: onboardingSystem)
                        .tag(OnboardingStep.introduction)
                    
                    DogBreedSelectionStepView(onboardingSystem: onboardingSystem)
                        .tag(OnboardingStep.dogBreedSelection)
                    
                    DogProfileStepView(onboardingSystem: onboardingSystem)
                        .tag(OnboardingStep.dogProfile)
                    
                    PreferencesStepView(onboardingSystem: onboardingSystem)
                        .tag(OnboardingStep.preferences)
                    
                    FeaturesStepView(onboardingSystem: onboardingSystem)
                        .tag(OnboardingStep.features)
                    
                    PermissionsStepView(onboardingSystem: onboardingSystem)
                        .tag(OnboardingStep.permissions)
                    
                    CompleteStepView(onboardingSystem: onboardingSystem)
                        .tag(OnboardingStep.complete)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.5), value: onboardingSystem.currentStep)
                
                // Navigation buttons
                OnboardingNavigationView(onboardingSystem: onboardingSystem)
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            onboardingSystem.canSkip = onboardingSystem.currentStep.canSkip
        }
        .onChange(of: onboardingSystem.currentStep) { step in
            onboardingSystem.canSkip = step.canSkip
        }
        .onChange(of: onboardingSystem.isOnboardingComplete) { complete in
            if complete {
                dismiss()
            }
        }
    }
}

// MARK: - Individual Step Views

public struct WelcomeStepView: View {
    @ObservedObject var onboardingSystem: OnboardingSystem
    
    public var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Logo and title
            VStack(spacing: 20) {
                Image(systemName: "pawprint.circle.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.blue)
                
                Text("DogTV+")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("The Ultimate Entertainment for Your Dog")
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
            }
            
            // Features preview
            VStack(spacing: 15) {
                FeatureRow(icon: "play.circle.fill", title: "Scientifically Designed Content", description: "Content tailored to your dog's needs")
                FeatureRow(icon: "brain.head.profile", title: "Behavior Analysis", description: "Understand your dog's reactions")
                FeatureRow(icon: "heart.fill", title: "Personalized Experience", description: "Adapts to your dog's preferences")
            }
            .padding()
            
            Spacer()
        }
        .padding()
    }
}

public struct IntroductionStepView: View {
    @ObservedObject var onboardingSystem: OnboardingSystem
    
    public var body: some View {
        VStack(spacing: 30) {
            ScrollView {
                VStack(spacing: 25) {
                    // Introduction content
                    VStack(spacing: 15) {
                        Text("What is DogTV+?")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("DogTV+ is a revolutionary platform that combines entertainment, education, and behavioral science to provide your dog with the ultimate viewing experience.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                    }
                    
                    // Benefits
                    VStack(spacing: 20) {
                        BenefitCard(
                            icon: "leaf.fill",
                            title: "Relaxation",
                            description: "Calming content to reduce anxiety and stress"
                        )
                        
                        BenefitCard(
                            icon: "bolt.fill",
                            title: "Stimulation",
                            description: "Engaging content to keep your dog active and alert"
                        )
                        
                        BenefitCard(
                            icon: "graduationcap.fill",
                            title: "Education",
                            description: "Training and learning content for behavioral development"
                        )
                    }
                }
                .padding()
            }
        }
    }
}

public struct DogBreedSelectionStepView: View {
    @ObservedObject var onboardingSystem: OnboardingSystem
    @State private var searchText = ""
    
    public var body: some View {
        VStack(spacing: 20) {
            Text("Select Your Dog's Breed")
                .font(.title)
                .fontWeight(.bold)
            
            Text("This helps us personalize content for your dog's specific needs and characteristics.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            // Search bar
            TextField("Search breeds...", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            // Breed list
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
                    ForEach(filteredBreeds, id: \.self) { breed in
                        BreedCard(
                            breed: breed,
                            isSelected: onboardingSystem.userProfile?.selectedBreed == breed
                        ) {
                            var profile = onboardingSystem.userProfile ?? UserProfile()
                            profile.selectedBreed = breed
                            onboardingSystem.updateUserProfile(profile)
                        }
                    }
                }
                .padding()
            }
        }
    }
    
    private var filteredBreeds: [DogBreed] {
        if searchText.isEmpty {
            return DogBreed.allCases
        } else {
            return DogBreed.allCases.filter { $0.rawValue.localizedCaseInsensitiveContains(searchText) }
        }
    }
}

public struct DogProfileStepView: View {
    @ObservedObject var onboardingSystem: OnboardingSystem
    
    public var body: some View {
        VStack(spacing: 20) {
            Text("Tell Us About Your Dog")
                .font(.title)
                .fontWeight(.bold)
            
            ScrollView {
                VStack(spacing: 20) {
                    // Dog name
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Dog's Name")
                            .font(.headline)
                        TextField("Enter your dog's name", text: Binding(
                            get: { onboardingSystem.userProfile?.dogName ?? "" },
                            set: { name in
                                var profile = onboardingSystem.userProfile ?? UserProfile()
                                profile.dogName = name
                                onboardingSystem.updateUserProfile(profile)
                            }
                        ))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    // Dog age
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Age (months)")
                            .font(.headline)
                        Stepper("\(onboardingSystem.userProfile?.dogAge ?? 12) months", value: Binding(
                            get: { onboardingSystem.userProfile?.dogAge ?? 12 },
                            set: { age in
                                var profile = onboardingSystem.userProfile ?? UserProfile()
                                profile.dogAge = age
                                onboardingSystem.updateUserProfile(profile)
                            }
                        ), in: 1...240)
                    }
                    
                    // Temperament
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Temperament")
                            .font(.headline)
                        Picker("Temperament", selection: Binding(
                            get: { onboardingSystem.userProfile?.dogTemperament ?? .calm },
                            set: { temperament in
                                var profile = onboardingSystem.userProfile ?? UserProfile()
                                profile.dogTemperament = temperament
                                onboardingSystem.updateUserProfile(profile)
                            }
                        )) {
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
                }
                .padding()
            }
        }
    }
}

// MARK: - Supporting Views

public struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    public var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

public struct BenefitCard: View {
    let icon: String
    let title: String
    let description: String
    
    public var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(.blue)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

public struct BreedCard: View {
    let breed: DogBreed
    let isSelected: Bool
    let action: () -> Void
    
    public var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: "pawprint.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(isSelected ? .white : .blue)
                
                Text(breed.rawValue)
                    .font(.headline)
                    .foregroundColor(isSelected ? .white : .primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isSelected ? Color.blue : Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

public struct OnboardingNavigationView: View {
    @ObservedObject var onboardingSystem: OnboardingSystem
    
    public var body: some View {
        HStack {
            // Back button
            if onboardingSystem.currentStep.previousStep != nil {
                Button("Back") {
                    onboardingSystem.previousStep()
                }
                .foregroundColor(.blue)
            }
            
            Spacer()
            
            // Skip button
            if onboardingSystem.canSkip {
                Button("Skip") {
                    onboardingSystem.skipOnboarding()
                }
                .foregroundColor(.secondary)
            }
            
            // Next button
            Button(onboardingSystem.currentStep == .complete ? "Get Started" : "Next") {
                onboardingSystem.nextStep()
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color.blue)
            .cornerRadius(8)
        }
        .padding()
    }
}

// Additional step views would be implemented similarly...
public struct PreferencesStepView: View {
    @ObservedObject var onboardingSystem: OnboardingSystem
    
    public var body: some View {
        Text("Preferences Step")
            .font(.title)
    }
}

public struct FeaturesStepView: View {
    @ObservedObject var onboardingSystem: OnboardingSystem
    
    public var body: some View {
        Text("Features Step")
            .font(.title)
    }
}

public struct PermissionsStepView: View {
    @ObservedObject var onboardingSystem: OnboardingSystem
    
    public var body: some View {
        Text("Permissions Step")
            .font(.title)
    }
}

public struct CompleteStepView: View {
    @ObservedObject var onboardingSystem: OnboardingSystem
    
    public var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 100))
                .foregroundColor(.green)
            
            Text("You're All Set!")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Your DogTV+ experience is ready. Let's start entertaining your furry friend!")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Spacer()
        }
        .padding()
    }
} 