import SwiftUI
import DogTVCore

/// Enhanced ContentView with all new animation systems, brand identity, and micro-interactions
public struct EnhancedContentView: View {
    @StateObject private var appCoordinator = DogTVCore.AppCoordinator()
    @StateObject private var animationSystem = EnhancedAnimationSystem()
    @StateObject private var transitionSystem = TransitionSystem.PageTransitionManager()
    @StateObject private var adaptiveInterface = SmartGestureSystem.AdaptiveInterfaceManager()
    
    @State private var selectedTab = 0
    @State private var isAnimating = false
    @State private var showWelcome = true
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // Background with parallax effect
            Color.dogSoft
                .ignoresSafeArea()
                .parallax(depth: .background)
            
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
        VStack(spacing: DogTVDesignSystem.Spacing.xxl) {
            // Logo with wagging tail animation
            VStack(spacing: DogTVDesignSystem.Spacing.lg) {
                Image(systemName: DogTVDesignSystem.Icons.dog)
                    .font(.system(size: 80))
                    .foregroundColor(Color.dogWarm)
                    .waggingTail()
                
                Text("DogTV+")
                    .font(DogTVDesignSystem.Typography.largeTitle)
                    .foregroundColor(Color.dogTextPrimary)
                    .staggeredAnimation(delay: 0.2)
                
                Text("Immersive Experience for Your Best Friend")
                    .font(DogTVDesignSystem.Typography.subheadline)
                    .foregroundColor(Color.dogTextSecondary)
                    .multilineTextAlignment(.center)
                    .staggeredAnimation(delay: 0.4)
            }
            .parallax(depth: .foreground)
            
            // Scientific badge
            EnhancedAnimationSystem.ScientificBadgeView()
                .staggeredAnimation(delay: 0.6)
            
            // Get started button
            Button(action: {
                withAnimation(EnhancedAnimationSystem.naturalSpring) {
                    showWelcome = false
                }
                hapticManager.mediumImpact()
                soundEffectPlayer.playSuccessSound()
            }) {
                Text("Get Started")
                    .font(DogTVDesignSystem.Typography.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, DogTVDesignSystem.Spacing.xl)
                    .padding(.vertical, DogTVDesignSystem.Spacing.lg)
                    .background(
                        RoundedRectangle(cornerRadius: DogTVDesignSystem.Layout.cornerRadius)
                            .fill(Color.dogWarm)
                            .shadow(
                                color: Color.dogWarm.opacity(0.3),
                                radius: 10,
                                x: 0,
                                y: 5
                            )
                    )
            }
            .staggeredAnimation(delay: 0.8)
            .rippleEffect(color: Color.dogWarm)
            .visualFeedback(
                pressedColor: Color.dogWarm,
                pressedScale: 0.95
            )
        }
        .padding(DogTVDesignSystem.Layout.paddingLarge)
    }
    
    // MARK: - Main Interface
    
    private var mainInterface: some View {
        VStack(spacing: 0) {
            // Header with vision mode toggle
            headerView
                .parallax(depth: .foreground)
            
            // Tab content
            TabView(selection: $selectedTab) {
                contentLibraryView
                    .tag(0)
                
                behaviorAnalysisView
                    .tag(1)
                
                settingsView
                    .tag(2)
                
                analyticsView
                    .tag(3)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .animation(transitionSystem.getAnimationForMode(), value: selectedTab)
            
            // Bottom navigation
            bottomNavigationView
                .parallax(depth: .foreground)
        }
        .background(Color.dogSoft)
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        HStack {
            // App title with heart beat animation
            HStack(spacing: DogTVDesignSystem.Spacing.sm) {
                Image(systemName: DogTVDesignSystem.Icons.dog)
                    .font(DogTVDesignSystem.Typography.title2)
                    .foregroundColor(Color.dogWarm)
                    .heartBeat()
                
                Text("DogTV+")
                    .font(DogTVDesignSystem.Typography.title2)
                    .foregroundColor(Color.dogTextPrimary)
            }
            
            Spacer()
            
            // Vision mode toggle
            Button(action: {
                appCoordinator.toggleVisionMode()
                hapticManager.lightImpact()
                soundEffectPlayer.playTapSound()
                adaptiveInterface.recordGesture(.tap)
            }) {
                HStack(spacing: DogTVDesignSystem.Spacing.xs) {
                    Image(systemName: appCoordinator.isVisionModeEnabled ? 
                          DogTVDesignSystem.Icons.vision : "eye.slash")
                        .font(DogTVDesignSystem.Typography.body)
                    
                    Text(appCoordinator.isVisionModeEnabled ? "Dog Vision" : "Human Vision")
                        .font(DogTVDesignSystem.Typography.footnote)
                }
                .foregroundColor(Color.dogWarm)
                .padding(.horizontal, DogTVDesignSystem.Spacing.md)
                .padding(.vertical, DogTVDesignSystem.Spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: DogTVDesignSystem.Layout.cornerRadius)
                        .fill(Color.white)
                        .shadow(
                            color: Color.black.opacity(0.1),
                            radius: 4,
                            x: 0,
                            y: 2
                        )
                )
            }
            .visionModeTransition(isDogVision: appCoordinator.isVisionModeEnabled)
            .rippleEffect(color: Color.dogWarm)
        }
        .padding(DogTVDesignSystem.Layout.paddingLarge)
        .background(
            Color.white
                .shadow(
                    color: Color.black.opacity(0.05),
                    radius: 8,
                    x: 0,
                    y: 4
                )
        )
    }
    
    // MARK: - Content Library View
    
    private var contentLibraryView: some View {
        ScrollView {
            VStack(spacing: DogTVDesignSystem.Spacing.lg) {
                // Featured content
                InformationArchitectureSystem.ContentGroupView(
                    title: "Featured Content",
                    subtitle: "Scientifically designed for your dog"
                ) {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: DogTVDesignSystem.Spacing.md) {
                        ForEach(sampleContentItems, id: \.id) { item in
                            contentCard(item)
                                .staggeredAnimation(delay: Double(sampleContentItems.firstIndex(of: item) ?? 0) * 0.1)
                        }
                    }
                }
                
                // Categories
                InformationArchitectureSystem.ContentGroupView(
                    title: "Categories",
                    subtitle: "Choose what your dog needs"
                ) {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: DogTVDesignSystem.Spacing.md) {
                        ForEach(DogTVCore.ContentCategory.allCases, id: \.self) { category in
                            categoryCard(category)
                                .staggeredAnimation(delay: Double(DogTVCore.ContentCategory.allCases.firstIndex(of: category) ?? 0) * 0.1)
                        }
                    }
                }
            }
            .padding(DogTVDesignSystem.Layout.paddingLarge)
        }
        .visionModeTransition(isDogVision: appCoordinator.isVisionModeEnabled)
    }
    
    // MARK: - Behavior Analysis View
    
    private var behaviorAnalysisView: some View {
        ScrollView {
            VStack(spacing: DogTVDesignSystem.Spacing.lg) {
                // Behavior insights
                InformationArchitectureSystem.ContentGroupView(
                    title: "Behavior Insights",
                    subtitle: "Understanding your dog's responses"
                ) {
                    VStack(spacing: DogTVDesignSystem.Spacing.md) {
                        behaviorInsightCard("Attention Level", "High", Color.dogSuccess)
                        behaviorInsightCard("Stress Level", "Low", Color.dogCalm)
                        behaviorInsightCard("Engagement", "Very High", Color.dogPlayful)
                    }
                }
                
                // Recommendations
                InformationArchitectureSystem.ContentGroupView(
                    title: "Recommendations",
                    subtitle: "Based on recent behavior patterns"
                ) {
                    VStack(spacing: DogTVDesignSystem.Spacing.md) {
                        recommendationCard("Try more stimulation content", "Your dog shows high engagement with active content")
                        recommendationCard("Consider relaxation time", "Balance active and calm content for optimal experience")
                    }
                }
            }
            .padding(DogTVDesignSystem.Layout.paddingLarge)
        }
    }
    
    // MARK: - Settings View
    
    private var settingsView: some View {
        ScrollView {
            VStack(spacing: DogTVDesignSystem.Spacing.lg) {
                // Audio settings
                InformationArchitectureSystem.ProgressiveDisclosureView(
                    title: "Audio Settings",
                    simpleContent: {
                        HStack {
                            Image(systemName: DogTVDesignSystem.Icons.audio)
                                .foregroundColor(Color.dogWarm)
                            Text("Audio Preferences")
                                .font(DogTVDesignSystem.Typography.body)
                            Spacer()
                            Text("Configured")
                                .font(DogTVDesignSystem.Typography.footnote)
                                .foregroundColor(Color.dogTextSecondary)
                        }
                    },
                    detailedContent: {
                        VStack(spacing: DogTVDesignSystem.Spacing.md) {
                            settingRow("Volume", "70%")
                            settingRow("Frequency Range", "Full Range")
                            settingRow("Nature Sounds", "Enabled")
                        }
                    }
                )
                
                // Visual settings
                InformationArchitectureSystem.ProgressiveDisclosureView(
                    title: "Visual Settings",
                    simpleContent: {
                        HStack {
                            Image(systemName: DogTVDesignSystem.Icons.vision)
                                .foregroundColor(Color.dogWarm)
                            Text("Visual Preferences")
                                .font(DogTVDesignSystem.Typography.body)
                            Spacer()
                            Text("Optimized")
                                .font(DogTVDesignSystem.Typography.footnote)
                                .foregroundColor(Color.dogTextSecondary)
                        }
                    },
                    detailedContent: {
                        VStack(spacing: DogTVDesignSystem.Spacing.md) {
                            settingRow("Brightness", "80%")
                            settingRow("Contrast", "60%")
                            settingRow("Motion Sensitivity", "Moderate")
                        }
                    }
                )
            }
            .padding(DogTVDesignSystem.Layout.paddingLarge)
        }
    }
    
    // MARK: - Analytics View
    
    private var analyticsView: some View {
        ScrollView {
            VStack(spacing: DogTVDesignSystem.Spacing.lg) {
                // Usage statistics
                InformationArchitectureSystem.ContentGroupView(
                    title: "Usage Statistics",
                    subtitle: "Your dog's viewing patterns"
                ) {
                    VStack(spacing: DogTVDesignSystem.Spacing.md) {
                        statCard("Total Watch Time", "2h 34m", "Today")
                        statCard("Favorite Category", "Stimulation", "Based on engagement")
                        statCard("Peak Activity", "3:00 PM", "Most active time")
                    }
                }
                
                // Scientific insights
                InformationArchitectureSystem.ContentGroupView(
                    title: "Scientific Insights",
                    subtitle: "Research-backed observations"
                ) {
                    VStack(spacing: DogTVDesignSystem.Spacing.md) {
                        insightCard("Your dog shows 40% higher engagement with nature sounds", "Research-backed")
                        insightCard("Optimal viewing duration is 15-20 minutes per session", "Behavioral study")
                    }
                }
            }
            .padding(DogTVDesignSystem.Layout.paddingLarge)
        }
    }
    
    // MARK: - Bottom Navigation
    
    private var bottomNavigationView: some View {
        HStack(spacing: 0) {
            ForEach(0..<4, id: \.self) { index in
                Button(action: {
                    withAnimation(EnhancedAnimationSystem.naturalSpring) {
                        selectedTab = index
                    }
                    hapticManager.lightImpact()
                    soundEffectPlayer.playTapSound()
                    adaptiveInterface.recordGesture(.tap)
                }) {
                    VStack(spacing: DogTVDesignSystem.Spacing.xs) {
                        Image(systemName: tabIcons[index])
                            .font(DogTVDesignSystem.Typography.body)
                            .foregroundColor(selectedTab == index ? Color.dogWarm : Color.dogTextSecondary)
                        
                        Text(tabTitles[index])
                            .font(DogTVDesignSystem.Typography.caption)
                            .foregroundColor(selectedTab == index ? Color.dogWarm : Color.dogTextSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DogTVDesignSystem.Spacing.sm)
                    .background(
                        Rectangle()
                            .fill(selectedTab == index ? Color.dogWarm.opacity(0.1) : Color.clear)
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .rippleEffect(color: Color.dogWarm)
            }
        }
        .background(
            Color.white
                .shadow(
                    color: Color.black.opacity(0.1),
                    radius: 8,
                    x: 0,
                    y: -4
                )
        )
    }
    
    // MARK: - Helper Views
    
    private func contentCard(_ item: DogTVCore.ContentItem) -> some View {
        VStack(alignment: .leading, spacing: DogTVDesignSystem.Spacing.sm) {
            RoundedRectangle(cornerRadius: DogTVDesignSystem.Layout.cornerRadius)
                .fill(Color.dogGrayLight)
                .frame(height: 120)
                .overlay(
                    Image(systemName: DogTVDesignSystem.Icons.play)
                        .font(.system(size: 30))
                        .foregroundColor(Color.dogWarm)
                )
            
            VStack(alignment: .leading, spacing: DogTVDesignSystem.Spacing.xs) {
                Text(item.title)
                    .font(DogTVDesignSystem.Typography.subheadline)
                    .foregroundColor(Color.dogTextPrimary)
                    .lineLimit(2)
                
                Text(item.category.rawValue)
                    .font(DogTVDesignSystem.Typography.caption)
                    .foregroundColor(Color.dogTextSecondary)
                
                if item.isScientific {
                    EnhancedAnimationSystem.ScientificBadgeView()
                }
            }
        }
        .cardStyle()
        .rippleEffect(color: Color.dogWarm)
        .visualFeedback(pressedColor: Color.dogWarm)
    }
    
    private func categoryCard(_ category: DogTVCore.ContentCategory) -> some View {
        VStack(spacing: DogTVDesignSystem.Spacing.sm) {
            Image(systemName: categoryIcon(for: category))
                .font(.system(size: 30))
                .foregroundColor(Color.dogWarm)
            
            Text(category.rawValue)
                .font(DogTVDesignSystem.Typography.caption)
                .foregroundColor(Color.dogTextPrimary)
                .multilineTextAlignment(.center)
        }
        .frame(height: 80)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: DogTVDesignSystem.Layout.cornerRadius)
                .fill(Color.white)
                .shadow(
                    color: Color.black.opacity(0.05),
                    radius: 4,
                    x: 0,
                    y: 2
                )
        )
        .rippleEffect(color: Color.dogWarm)
    }
    
    private func behaviorInsightCard(_ title: String, _ value: String, _ color: Color) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: DogTVDesignSystem.Spacing.xs) {
                Text(title)
                    .font(DogTVDesignSystem.Typography.footnote)
                    .foregroundColor(Color.dogTextSecondary)
                
                Text(value)
                    .font(DogTVDesignSystem.Typography.headline)
                    .foregroundColor(color)
            }
            
            Spacer()
            
            Circle()
                .fill(color.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "chart.bar.fill")
                        .foregroundColor(color)
                )
        }
        .padding(DogTVDesignSystem.Layout.padding)
        .background(
            RoundedRectangle(cornerRadius: DogTVDesignSystem.Layout.cornerRadius)
                .fill(Color.white)
        )
    }
    
    private func recommendationCard(_ title: String, _ description: String) -> some View {
        VStack(alignment: .leading, spacing: DogTVDesignSystem.Spacing.sm) {
            Text(title)
                .font(DogTVDesignSystem.Typography.subheadline)
                .foregroundColor(Color.dogTextPrimary)
            
            Text(description)
                .font(DogTVDesignSystem.Typography.footnote)
                .foregroundColor(Color.dogTextSecondary)
        }
        .padding(DogTVDesignSystem.Layout.padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: DogTVDesignSystem.Layout.cornerRadius)
                .fill(Color.dogCalm.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: DogTVDesignSystem.Layout.cornerRadius)
                        .stroke(Color.dogCalm.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private func settingRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .font(DogTVDesignSystem.Typography.body)
                .foregroundColor(Color.dogTextPrimary)
            
            Spacer()
            
            Text(value)
                .font(DogTVDesignSystem.Typography.body)
                .foregroundColor(Color.dogTextSecondary)
        }
        .padding(DogTVDesignSystem.Layout.padding)
        .background(Color.dogGrayLight)
        .cornerRadius(DogTVDesignSystem.Layout.cornerRadiusSmall)
    }
    
    private func statCard(_ title: String, _ value: String, _ subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: DogTVDesignSystem.Spacing.xs) {
            Text(title)
                .font(DogTVDesignSystem.Typography.footnote)
                .foregroundColor(Color.dogTextSecondary)
            
            Text(value)
                .font(DogTVDesignSystem.Typography.title3)
                .foregroundColor(Color.dogTextPrimary)
            
            Text(subtitle)
                .font(DogTVDesignSystem.Typography.caption)
                .foregroundColor(Color.dogTextTertiary)
        }
        .padding(DogTVDesignSystem.Layout.padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: DogTVDesignSystem.Layout.cornerRadius)
                .fill(Color.white)
        )
    }
    
    private func insightCard(_ text: String, _ source: String) -> some View {
        VStack(alignment: .leading, spacing: DogTVDesignSystem.Spacing.sm) {
            Text(text)
                .font(DogTVDesignSystem.Typography.body)
                .foregroundColor(Color.dogTextPrimary)
            
            HStack {
                Image(systemName: DogTVDesignSystem.Icons.flask)
                    .font(DogTVDesignSystem.Typography.caption)
                    .foregroundColor(Color.dogCalm)
                
                Text(source)
                    .font(DogTVDesignSystem.Typography.caption)
                    .foregroundColor(Color.dogCalm)
            }
        }
        .padding(DogTVDesignSystem.Layout.padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: DogTVDesignSystem.Layout.cornerRadius)
                .fill(Color.dogCalm.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: DogTVDesignSystem.Layout.cornerRadius)
                        .stroke(Color.dogCalm.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Helper Functions
    
    private func startWelcomeAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(EnhancedAnimationSystem.naturalSpring) {
                isAnimating = true
            }
        }
    }
    
    private func categoryIcon(for category: DogTVCore.ContentCategory) -> String {
        switch category {
        case .relaxation: return "leaf.fill"
        case .stimulation: return "bolt.fill"
        case .training: return "brain.head.profile"
        case .entertainment: return "play.fill"
        case .scientific: return "flask.fill"
        }
    }
    
    // MARK: - Sample Data
    
    private var sampleContentItems: [DogTVCore.ContentItem] {
        [
            DogTVCore.ContentItem(
                title: "Forest Adventure",
                description: "Peaceful nature scenes for relaxation",
                category: .relaxation,
                duration: 900,
                isScientific: true
            ),
            DogTVCore.ContentItem(
                title: "Playful Puppies",
                description: "Energetic play sessions for stimulation",
                category: .stimulation,
                duration: 600,
                isScientific: true
            ),
            DogTVCore.ContentItem(
                title: "Obedience Training",
                description: "Interactive training exercises",
                category: .training,
                duration: 1200,
                isScientific: true
            ),
            DogTVCore.ContentItem(
                title: "Ball Chase",
                description: "Fun ball games for entertainment",
                category: .entertainment,
                duration: 450,
                isScientific: false
            )
        ]
    }
    
    private var tabIcons: [String] {
        [DogTVDesignSystem.Icons.home, "brain.head.profile", DogTVDesignSystem.Icons.settings, DogTVDesignSystem.Icons.analytics]
    }
    
    private var tabTitles: [String] {
        ["Content", "Behavior", "Settings", "Analytics"]
    }
} 