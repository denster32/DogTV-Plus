import SwiftUI
import DogTVCore
import DogTVVision

/// Enhanced ContentView with procedural content generation and canine optimization
public struct EnhancedContentView: View {
    @Binding var currentView: DogTVMainApp.AppView
    @StateObject private var animationSystem = EnhancedAnimationSystem()
    @StateObject private var designSystem = DogTVDesignSystem()
    
    @State private var selectedTab = 0
    @State private var showWelcome = true
    
    public init(currentView: Binding<DogTVMainApp.AppView>) {
        self._currentView = currentView
    }
    
    public var body: some View {
        ZStack {
            if showWelcome {
                welcomeView
                    .transition(.opacity.combined(with: .scale(scale: 0.9)))
            } else {
                mainInterface
                    .transition(.opacity.combined(with: .scale(scale: 1.1)))
            }
        }
        .onAppear {
            startWelcomeAnimation()
        }
    }
    
    // MARK: - Welcome View
    
    private var welcomeView: some View {
        VStack(spacing: 60) {
            // Logo with animation
            VStack(spacing: 24) {
                Image(systemName: "pawprint.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(designSystem.colors.primary)
                    .scaleEffect(animationSystem.isAnimating ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: animationSystem.isAnimating)
                
                Text("DogTV+")
                    .font(designSystem.typography.largeTitle)
                    .foregroundColor(designSystem.colors.primary)
                
                Text("Real-time Procedural Entertainment for Dogs")
                    .font(designSystem.typography.subheadline)
                    .foregroundColor(designSystem.colors.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // Features
            VStack(spacing: 20) {
                FeatureItem(icon: "eye.fill", title: "Canine Vision Optimized", description: "Colors and contrast tailored for dichromatic vision")
                FeatureItem(icon: "waveform.path", title: "Real-time Generation", description: "No videos - everything generated live using Metal")
                FeatureItem(icon: "brain.head.profile", title: "Scientifically Based", description: "Based on canine behavior research")
            }
            .padding(.horizontal, 40)
            
            // Start Experience Button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.8)) {
                    showWelcome = false
                }
            }) {
                Text("Start Experience")
                    .font(designSystem.typography.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(designSystem.colors.primary)
                            .shadow(color: designSystem.colors.primary.opacity(0.3), radius: 10, x: 0, y: 5)
                    )
            }
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(designSystem.backgroundGradient)
    }
    
    // MARK: - Main Interface
    
    private var mainInterface: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            // Tab content
            TabView(selection: $selectedTab) {
                // Main procedural content view
                ProceduralContentView()
                    .tag(0)
                
                // Scene library
                sceneLibraryView
                    .tag(1)
                
                // Settings
                settingsView
                    .tag(2)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            // Bottom navigation
            bottomNavigationView
        }
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        HStack {
            // App title
            HStack(spacing: 12) {
                Image(systemName: "pawprint.circle.fill")
                    .font(.title2)
                    .foregroundColor(designSystem.colors.primary)
                
                Text("DogTV+")
                    .font(designSystem.typography.title2)
                    .foregroundColor(designSystem.colors.primary)
            }
            
            Spacer()
            
            // Back button
            Button("Back") {
                currentView = .welcome
            }
            .foregroundColor(designSystem.colors.secondary)
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.9))
    }
    
    // MARK: - Scene Library View
    
    private var sceneLibraryView: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Procedural Scenes")
                    .font(designSystem.typography.largeTitle)
                    .foregroundColor(designSystem.colors.primary)
                    .padding(.top, 20)
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 20) {
                    ForEach(ProceduralContentGenerator.CanineScene.allCases, id: \.self) { scene in
                        SceneCard(scene: scene)
                    }
                }
                .padding(.horizontal, 30)
            }
        }
        .background(designSystem.backgroundGradient)
    }
    
    // MARK: - Settings View
    
    private var settingsView: some View {
        ScrollView {
            VStack(spacing: 30) {
                Text("Settings")
                    .font(designSystem.typography.largeTitle)
                    .foregroundColor(designSystem.colors.primary)
                    .padding(.top, 20)
                
                VStack(spacing: 20) {
                    SettingItem(icon: "timer", title: "Auto-transition", subtitle: "Automatically change scenes every 5 minutes")
                    SettingItem(icon: "dial.high", title: "Intensity Level", subtitle: "Adjust visual intensity for your dog")
                    SettingItem(icon: "speaker.wave.2", title: "Audio Settings", subtitle: "Configure therapeutic frequencies")
                    SettingItem(icon: "eye", title: "Vision Mode", subtitle: "Optimize for canine dichromatic vision")
                }
                .padding(.horizontal, 30)
            }
        }
        .background(designSystem.backgroundGradient)
    }
    
    // MARK: - Bottom Navigation
    
    private var bottomNavigationView: some View {
        HStack {
            NavigationButton(
                icon: "play.circle.fill",
                title: "Experience",
                isSelected: selectedTab == 0
            ) {
                selectedTab = 0
            }
            
            Spacer()
            
            NavigationButton(
                icon: "square.grid.2x2",
                title: "Scenes",
                isSelected: selectedTab == 1
            ) {
                selectedTab = 1
            }
            
            Spacer()
            
            NavigationButton(
                icon: "gearshape.fill",
                title: "Settings",
                isSelected: selectedTab == 2
            ) {
                selectedTab = 2
            }
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 20)
        .background(Color.white.opacity(0.9))
    }
    
    // MARK: - Private Methods
    
    private func startWelcomeAnimation() {
        animationSystem.startAnimation()
    }
}

// MARK: - Supporting Views

private struct FeatureItem: View {
    let icon: String
    let title: String
    let description: String
    @EnvironmentObject var designSystem: DogTVDesignSystem
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(designSystem.colors.accent)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(designSystem.typography.headline)
                    .foregroundColor(designSystem.colors.primary)
                
                Text(description)
                    .font(designSystem.typography.caption)
                    .foregroundColor(designSystem.colors.secondary)
            }
            
            Spacer()
        }
    }
}

private struct SceneCard: View {
    let scene: ProceduralContentGenerator.CanineScene
    @EnvironmentObject var designSystem: DogTVDesignSystem
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: scene.icon)
                .font(.system(size: 40))
                .foregroundColor(designSystem.colors.primary)
            
            Text(scene.rawValue)
                .font(designSystem.typography.headline)
                .foregroundColor(designSystem.colors.primary)
                .multilineTextAlignment(.center)
            
            Text(scene.description)
                .font(designSystem.typography.caption)
                .foregroundColor(designSystem.colors.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(3)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
}

private struct SettingItem: View {
    let icon: String
    let title: String
    let subtitle: String
    @EnvironmentObject var designSystem: DogTVDesignSystem
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(designSystem.colors.primary)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(designSystem.typography.headline)
                    .foregroundColor(designSystem.colors.primary)
                
                Text(subtitle)
                    .font(designSystem.typography.caption)
                    .foregroundColor(designSystem.colors.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(designSystem.colors.secondary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
}

private struct NavigationButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    @EnvironmentObject var designSystem: DogTVDesignSystem
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? designSystem.colors.primary : designSystem.colors.secondary)
                
                Text(title)
                    .font(designSystem.typography.caption)
                    .foregroundColor(isSelected ? designSystem.colors.primary : designSystem.colors.secondary)
            }
        }
    }
}

#if DEBUG
struct EnhancedContentView_Previews: PreviewProvider {
    static var previews: some View {
        EnhancedContentView(currentView: .constant(.main))
            .environmentObject(DogTVDesignSystem())
            .previewDevice("Apple TV 4K")
    }
}
#endif